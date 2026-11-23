import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/monetization_config.dart';
import '../../domain/services/safe_url_validator.dart';
import '../local/app_database.dart';
import 'subscription_service.dart';

/// Resolved ad slot outcome from the local-first cascade.
enum AdSlotSource { none, localAd, admob }

class AdCascadeDecision {
  const AdCascadeDecision.none() : source = AdSlotSource.none, localAd = null;
  const AdCascadeDecision.local(CachedAdEntity ad)
    : source = AdSlotSource.localAd,
      localAd = ad;
  const AdCascadeDecision.admob() : source = AdSlotSource.admob, localAd = null;

  final AdSlotSource source;
  final CachedAdEntity? localAd;
}

/// Pure, deterministic cascade selector:
/// - Paid tiers (`basic_2usd`, `pro_3usd`) NEVER see ads.
/// - Free users see local active, non-expired ads matching their city (or `'Todas'`),
///   always prioritizing `featured_5usd` over `banner_3usd` and exact city over `'Todas'`.
/// - Falls back to Google AdMob when no matching local ad is cached/active.
class AdsCascadeSelector {
  AdsCascadeSelector._();

  static const String tierFeatured = 'featured_5usd';
  static const String tierBanner = 'banner_3usd';
  static const String allCitiesKey = 'Todas';

  static bool shouldShowAds(String planTier) =>
      planTier == KarritoPlanTier.free;

  static String _fold(String input) {
    const accents = 'áéíóúüñÁÉÍÓÚÜÑ';
    const plain = 'aeiouunAEIOUUN';
    final sb = StringBuffer();
    for (final rune in input.trim().runes) {
      final ch = String.fromCharCode(rune);
      final idx = accents.indexOf(ch);
      sb.write(idx >= 0 ? plain[idx] : ch);
    }
    return sb.toString().toLowerCase();
  }

  static bool _matchesCity(String adCity, String userCity) {
    final fAd = _fold(adCity);
    return fAd == _fold(userCity) || fAd == _fold(allCitiesKey);
  }

  static int _rankAd(CachedAdEntity ad, String userCity) {
    final isFeatured = ad.tier == tierFeatured;
    final isExactCity = _fold(ad.city) == _fold(userCity);
    if (isFeatured && isExactCity) return 0;
    if (isFeatured) return 1;
    if (isExactCity) return 2;
    return 3;
  }

  static AdCascadeDecision resolveBanner({
    required List<CachedAdEntity> cachedAds,
    required String userCity,
    required String planTier,
    DateTime? now,
  }) {
    if (!shouldShowAds(planTier)) {
      return const AdCascadeDecision.none();
    }

    final reference = (now ?? DateTime.now()).toUtc();
    final eligible = cachedAds.where((ad) {
      final hasBanner = ad.bannerUrl != null && ad.bannerUrl!.trim().isNotEmpty;
      return ad.isActive &&
          hasBanner &&
          ad.expiresAt.toUtc().isAfter(reference) &&
          _matchesCity(ad.city, userCity);
    }).toList();

    if (eligible.isEmpty) {
      return const AdCascadeDecision.admob();
    }

    eligible.sort((a, b) {
      final rankCmp = _rankAd(a, userCity).compareTo(_rankAd(b, userCity));
      if (rankCmp != 0) return rankCmp;
      return b.cachedAt.compareTo(a.cachedAt);
    });

    return AdCascadeDecision.local(eligible.first);
  }

  static AdCascadeDecision resolveInterstitial({
    required List<CachedAdEntity> cachedAds,
    required String userCity,
    required String planTier,
    DateTime? now,
  }) {
    if (!shouldShowAds(planTier)) {
      return const AdCascadeDecision.none();
    }

    final reference = (now ?? DateTime.now()).toUtc();
    final eligible = cachedAds.where((ad) {
      final hasFlyer =
          ad.interstitialUrl != null && ad.interstitialUrl!.trim().isNotEmpty;
      return ad.isActive &&
          ad.tier == tierFeatured &&
          hasFlyer &&
          ad.expiresAt.toUtc().isAfter(reference) &&
          _matchesCity(ad.city, userCity);
    }).toList();

    if (eligible.isEmpty) {
      return const AdCascadeDecision.admob();
    }

    eligible.sort((a, b) {
      final rankCmp = _rankAd(a, userCity).compareTo(_rankAd(b, userCity));
      if (rankCmp != 0) return rankCmp;
      return b.cachedAt.compareTo(a.cachedAt);
    });

    return AdCascadeDecision.local(eligible.first);
  }
}

abstract interface class AdsCascadeService {
  Future<void> initializeMobileAdsSafely();
  Stream<List<CachedAdEntity>> watchCachedAds();
  Future<void> refreshLocalAds(String userCity);
  Future<void> recordImpression(String adId);
  Future<void> recordClick(String adId);
  Future<void> preloadAdMobInterstitial();
  Future<bool> showAdMobInterstitialIfReady();
  Future<void> dispose();
}

/// Downloads active local ads from `karrito.local_ads`, caches metadata in Drift
/// (`local_cached_ads`) and artwork files on disk (`DefaultCacheManager`) for
/// offline availability inside supermarkets, records impressions/clicks via RPC,
/// and manages AdMob fallback interstitials.
class SupabaseAdsCascadeService implements AdsCascadeService {
  SupabaseAdsCascadeService({required this.db, required this.client});

  final AppDatabase db;
  final SupabaseClient? client;
  bool _mobileAdsInitialized = false;
  InterstitialAd? _cachedAdMobInterstitial;
  bool _loadingInterstitial = false;

  @override
  Future<void> initializeMobileAdsSafely() async {
    if (_mobileAdsInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _mobileAdsInitialized = true;
    } catch (e) {
      debugPrint('Karrito MobileAds init skipped in current environment: $e');
    }
  }

  @override
  Stream<List<CachedAdEntity>> watchCachedAds() {
    return db.select(db.localCachedAds).watch();
  }

  @override
  Future<void> refreshLocalAds(String userCity) async {
    final activeClient = client;
    if (activeClient == null) return;
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final rows = List<Map<String, dynamic>>.from(
        await activeClient
            .from('local_ads')
            .select(
              'id, business_name, city, tier, banner_url, interstitial_url, action_url, expires_at, is_active',
            )
            .eq('is_active', true)
            .gt('expires_at', nowIso),
      );

      final now = DateTime.now();
      final companions = <LocalCachedAdsCompanion>[];
      final urlsToPrefetch = <String>[];

      for (final row in rows) {
        final id = row['id']?.toString() ?? '';
        final businessName = row['business_name']?.toString().trim() ?? '';
        final city = row['city']?.toString().trim() ?? '';
        final tier = row['tier']?.toString().trim() ?? 'banner_3usd';
        final actionUrl = row['action_url']?.toString().trim() ?? '';
        final expiresAt = DateTime.tryParse(
          row['expires_at']?.toString() ?? '',
        );
        if (id.isEmpty ||
            businessName.isEmpty ||
            city.isEmpty ||
            SafeUrlValidator.parseSafeAdUri(actionUrl) == null ||
            expiresAt == null) {
          continue;
        }
        final rawBannerUrl = row['banner_url']?.toString().trim();
        final rawInterstitialUrl = row['interstitial_url']?.toString().trim();
        final bannerUrl = SafeUrlValidator.isSafeHttpsImageUrl(rawBannerUrl)
            ? rawBannerUrl
            : null;
        final interstitialUrl =
            SafeUrlValidator.isSafeHttpsImageUrl(rawInterstitialUrl)
            ? rawInterstitialUrl
            : null;

        companions.add(
          LocalCachedAdsCompanion.insert(
            id: id,
            businessName: businessName,
            city: city,
            tier: tier,
            bannerUrl: Value(
              bannerUrl != null && bannerUrl.isNotEmpty ? bannerUrl : null,
            ),
            interstitialUrl: Value(
              interstitialUrl != null && interstitialUrl.isNotEmpty
                  ? interstitialUrl
                  : null,
            ),
            actionUrl: actionUrl,
            expiresAt: expiresAt,
            isActive: Value(row['is_active'] == true),
            cachedAt: now,
          ),
        );

        if (bannerUrl != null && bannerUrl.isNotEmpty) {
          urlsToPrefetch.add(bannerUrl);
        }
        if (interstitialUrl != null && interstitialUrl.isNotEmpty) {
          urlsToPrefetch.add(interstitialUrl);
        }
      }

      await db.transaction(() async {
        await db.delete(db.localCachedAds).go();
        if (companions.isNotEmpty) {
          await db.batch((b) => b.insertAll(db.localCachedAds, companions));
        }
      });

      // Prefetch artwork to disk cache so local ads stay visible without signal.
      for (final url in urlsToPrefetch) {
        unawaited(
          DefaultCacheManager().downloadFile(url).then<void>((_) {}).catchError(
            (Object e) {
              debugPrint('Karrito local ad image prefetch skipped: $e');
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Karrito refreshLocalAds skipped (keeping cached ads): $e');
    }
  }

  @override
  Future<void> recordImpression(String adId) async {
    final activeClient = client;
    if (activeClient == null) return;
    try {
      await activeClient.rpc(
        'increment_ad_impression',
        params: <String, dynamic>{'p_ad_id': adId},
      );
    } catch (e) {
      debugPrint('Karrito increment_ad_impression skipped: $e');
    }
  }

  @override
  Future<void> recordClick(String adId) async {
    final activeClient = client;
    if (activeClient == null) return;
    try {
      await activeClient.rpc(
        'increment_ad_click',
        params: <String, dynamic>{'p_ad_id': adId},
      );
    } catch (e) {
      debugPrint('Karrito increment_ad_click skipped: $e');
    }
  }

  @override
  Future<void> preloadAdMobInterstitial() async {
    if (_loadingInterstitial || _cachedAdMobInterstitial != null) return;
    await initializeMobileAdsSafely();
    if (!_mobileAdsInitialized) return;

    _loadingInterstitial = true;
    try {
      await InterstitialAd.load(
        adUnitId: MonetizationConfig.admobInterstitialUnitIdAndroid,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _loadingInterstitial = false;
            _cachedAdMobInterstitial = ad;
          },
          onAdFailedToLoad: (error) {
            _loadingInterstitial = false;
            debugPrint('Karrito AdMob interstitial preload failed: $error');
          },
        ),
      );
    } catch (e) {
      _loadingInterstitial = false;
      debugPrint('Karrito AdMob interstitial load skipped: $e');
    }
  }

  @override
  Future<bool> showAdMobInterstitialIfReady() async {
    final ad = _cachedAdMobInterstitial;
    if (ad == null) {
      unawaited(preloadAdMobInterstitial());
      return false;
    }

    _cachedAdMobInterstitial = null;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(preloadAdMobInterstitial());
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(preloadAdMobInterstitial());
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    try {
      await ad.show();
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => true,
      );
    } catch (e) {
      ad.dispose();
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _cachedAdMobInterstitial?.dispose();
    _cachedAdMobInterstitial = null;
  }
}
