import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/monetization_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/services/ads_cascade_service.dart';
import '../../domain/services/safe_url_validator.dart';
import '../../providers/core_providers.dart';
import '../../providers/shopping_providers.dart';

/// Fixed bottom banner slot on `ShoppingListScreen`:
/// - Completely hidden for `basic_2usd` and `pro_3usd`.
/// - For `free`, shows the highest-priority active local ad (cached offline via
///   `CachedNetworkImage`) with impression & click RPC tracking.
/// - Falls back to Google AdMob banner when no active local ad exists.
class KarritoAdsBannerBar extends ConsumerStatefulWidget {
  const KarritoAdsBannerBar({super.key});

  @override
  ConsumerState<KarritoAdsBannerBar> createState() =>
      _KarritoAdsBannerBarState();
}

class _KarritoAdsBannerBarState extends ConsumerState<KarritoAdsBannerBar> {
  String? _lastImpressionAdId;
  BannerAd? _adMobBanner;
  bool _adMobLoaded = false;
  bool _adMobRequested = false;

  @override
  void dispose() {
    _adMobBanner?.dispose();
    super.dispose();
  }

  void _ensureAdMobBannerLoaded() {
    if (_adMobRequested) return;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _adMobRequested = true;

    try {
      final ad = BannerAd(
        adUnitId: MonetizationConfig.admobBannerUnitIdAndroid,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted) {
              loadedAd.dispose();
              return;
            }
            setState(() {
              _adMobBanner = loadedAd as BannerAd;
              _adMobLoaded = true;
            });
          },
          onAdFailedToLoad: (failedAd, error) {
            failedAd.dispose();
            debugPrint('Karrito AdMob banner load skipped: $error');
          },
        ),
      );
      unawaited(ad.load());
    } catch (e) {
      debugPrint('Karrito AdMob banner unavailable: $e');
    }
  }

  Future<void> _handleLocalAdTap(CachedAdEntity ad) async {
    final uri = SafeUrlValidator.parseSafeAdUri(ad.actionUrl);
    if (uri == null) {
      debugPrint('Karrito blocked unsafe local ad action_url.');
      return;
    }
    unawaited(ref.read(adsCascadeServiceProvider).recordClick(ad.id));
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Karrito could not open ad action_url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final decision = ref.watch(activeBannerDecisionProvider);
    if (decision.source == AdSlotSource.none) {
      return const SizedBox.shrink();
    }

    if (decision.source == AdSlotSource.localAd && decision.localAd != null) {
      final ad = decision.localAd!;
      if (_lastImpressionAdId != ad.id) {
        _lastImpressionAdId = ad.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(
              ref.read(adsCascadeServiceProvider).recordImpression(ad.id),
            );
          }
        });
      }

      final theme = Theme.of(context);
      final karritoColors = theme.extension<KarritoColors>()!;

      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: karritoColors.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Semantics(
            button: true,
            label: 'Anuncio local de ${ad.businessName}',
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _handleLocalAdTap(ad),
              child: Container(
                height: 54,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: karritoColors.fieldSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: karritoColors.border, width: 1),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (ad.bannerUrl != null && ad.bannerUrl!.trim().isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: ad.bannerUrl!.trim(),
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _LocalBannerFallback(ad: ad),
                        placeholder: (_, _) => _LocalBannerFallback(ad: ad),
                      )
                    else
                      _LocalBannerFallback(ad: ad),
                    Positioned(
                      top: 4,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Comercio local',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fallback: Google AdMob banner (for Free tier when no local ad matches city).
    _ensureAdMobBannerLoaded();
    if (!_adMobLoaded || _adMobBanner == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: _adMobBanner!.size.height.toDouble() + 8,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).extension<KarritoColors>()!.border,
            ),
          ),
        ),
        child: SizedBox(
          width: _adMobBanner!.size.width.toDouble(),
          height: _adMobBanner!.size.height.toDouble(),
          child: AdWidget(ad: _adMobBanner!),
        ),
      ),
    );
  }
}

class _LocalBannerFallback extends StatelessWidget {
  const _LocalBannerFallback({required this.ad});

  final CachedAdEntity ad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.storefront_rounded,
            size: 20,
            color: karritoColors.accentSoft,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ad.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: karritoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded, size: 17, color: karritoColors.cta),
        ],
      ),
    );
  }
}
