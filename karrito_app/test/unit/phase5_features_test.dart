import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/config/monetization_config.dart';
import 'package:karrito_app/core/constants/store_hierarchy.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/repositories/shopping_repository.dart';
import 'package:karrito_app/data/services/ads_cascade_service.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/data/services/media_capture_service.dart';
import 'package:karrito_app/data/services/subscription_service.dart';
import 'package:karrito_app/domain/services/currency_formatter.dart';
import 'package:karrito_app/ui/widgets/karrito_asset_icon.dart';
import 'package:karrito_app/ui/widgets/profile_avatar_widget.dart';

class _NoopAi implements AiClassifierService {
  @override
  Future<ProcesarListaResponse> classifyText(String text) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }

  @override
  Future<ProcesarListaResponse> classifyAudio({
    required String audioBase64,
    String mimeType = 'audio/m4a',
  }) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }

  @override
  Future<ProcesarListaResponse> classifyImage({
    required String imageBase64,
    String mimeType = 'image/jpeg',
  }) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }
}

void main() {
  group('12 avatars and custom assets', () {
    test(
      'KarritoAvatars exposes all 12 avatars and all PNG files exist on disk',
      () {
        expect(KarritoAvatars.localChoices, hasLength(12));
        for (var i = 1; i <= 12; i++) {
          final choice = 'avatar_$i';
          expect(KarritoAvatars.localChoices[i - 1], choice);
          final path = KarritoAvatars.assetPathFor(choice);
          expect(path, 'assets/avatars/avatar_$i.png');
          expect(
            File(path).existsSync(),
            isTrue,
            reason: 'Expected custom user avatar asset at $path',
          );
        }

        // Verify custom brand logos and store icons added by the user exist.
        expect(File('assets/brand/logo_light.png').existsSync(), isTrue);
        expect(File('assets/brand/logo_dark.png').existsSync(), isTrue);
        for (final store in StoreHierarchy.storeOrder) {
          final slug = KarritoAssetIcon.slugify(store);
          final path = 'assets/icons/stores/$slug.png';
          expect(
            File(path).existsSync(),
            isTrue,
            reason: 'Expected store PNG asset at $path for "$store"',
          );
        }
      },
    );
  });

  group('Ads cascade selector (Local ads vs Google AdMob)', () {
    final now = DateTime.utc(2026, 11, 22, 15, 0);

    CachedAdEntity makeAd({
      required String id,
      required String city,
      required String tier,
      bool isActive = true,
      DateTime? expiresAt,
      String? bannerUrl = 'https://cdn.karrito.test/banner.png',
      String? interstitialUrl,
    }) {
      return CachedAdEntity(
        id: id,
        businessName: 'Comercio $id',
        city: city,
        tier: tier,
        bannerUrl: bannerUrl,
        interstitialUrl: interstitialUrl,
        actionUrl: 'https://wa.me/5493835000000',
        expiresAt: expiresAt ?? now.add(const Duration(days: 5)),
        isActive: isActive,
        cachedAt: now,
      );
    }

    test(
      'paid tiers (basic_2usd, pro_3usd) never see banners or interstitials',
      () {
        final ads = <CachedAdEntity>[
          makeAd(
            id: 'feat-andalgala',
            city: 'Andalgalá',
            tier: AdsCascadeSelector.tierFeatured,
            interstitialUrl: 'https://cdn.karrito.test/flyer.png',
          ),
        ];

        for (final tier in <String>[
          KarritoPlanTier.basic,
          KarritoPlanTier.pro,
        ]) {
          expect(
            AdsCascadeSelector.resolveBanner(
              cachedAds: ads,
              userCity: 'Andalgalá',
              planTier: tier,
              now: now,
            ).source,
            AdSlotSource.none,
          );
          expect(
            AdsCascadeSelector.resolveInterstitial(
              cachedAds: ads,
              userCity: 'Andalgalá',
              planTier: tier,
              now: now,
            ).source,
            AdSlotSource.none,
          );
        }
      },
    );

    test(
      'prioritizes featured_5usd over banner_3usd and exact city over Todas',
      () {
        final ads = <CachedAdEntity>[
          makeAd(
            id: 'banner-todas',
            city: 'Todas',
            tier: AdsCascadeSelector.tierBanner,
          ),
          makeAd(
            id: 'banner-andalgala',
            city: 'Andalgalá',
            tier: AdsCascadeSelector.tierBanner,
          ),
          makeAd(
            id: 'featured-todas',
            city: 'Todas',
            tier: AdsCascadeSelector.tierFeatured,
            interstitialUrl: 'https://cdn.karrito.test/flyer-todas.png',
          ),
          makeAd(
            id: 'featured-andalgala',
            city: 'Andalgalá',
            tier: AdsCascadeSelector.tierFeatured,
            interstitialUrl: 'https://cdn.karrito.test/flyer-andalgala.png',
          ),
          makeAd(
            id: 'expired-featured',
            city: 'Andalgalá',
            tier: AdsCascadeSelector.tierFeatured,
            expiresAt: now.subtract(const Duration(minutes: 1)),
            interstitialUrl: 'https://cdn.karrito.test/expired.png',
          ),
        ];

        final bannerAndalgala = AdsCascadeSelector.resolveBanner(
          cachedAds: ads,
          userCity: 'Andalgala', // accent-insensitive match
          planTier: KarritoPlanTier.free,
          now: now,
        );
        expect(bannerAndalgala.source, AdSlotSource.localAd);
        expect(bannerAndalgala.localAd?.id, 'featured-andalgala');

        final bannerBelen = AdsCascadeSelector.resolveBanner(
          cachedAds: ads,
          userCity: 'Belén',
          planTier: KarritoPlanTier.free,
          now: now,
        );
        expect(bannerBelen.source, AdSlotSource.localAd);
        expect(bannerBelen.localAd?.id, 'featured-todas');

        final interstitialBelen = AdsCascadeSelector.resolveInterstitial(
          cachedAds: ads,
          userCity: 'Belén',
          planTier: KarritoPlanTier.free,
          now: now,
        );
        expect(interstitialBelen.source, AdSlotSource.localAd);
        expect(interstitialBelen.localAd?.id, 'featured-todas');
      },
    );

    test('falls back to Google AdMob when no active local ad matches city', () {
      final onlyOtherCityAndExpired = <CachedAdEntity>[
        makeAd(
          id: 'only-saujil',
          city: 'Saujil',
          tier: AdsCascadeSelector.tierFeatured,
          interstitialUrl: 'https://cdn.karrito.test/flyer.png',
        ),
        makeAd(
          id: 'expired-belen',
          city: 'Belén',
          tier: AdsCascadeSelector.tierBanner,
          expiresAt: now.subtract(const Duration(hours: 2)),
        ),
        makeAd(
          id: 'inactive-belen',
          city: 'Belén',
          tier: AdsCascadeSelector.tierBanner,
          isActive: false,
        ),
      ];

      expect(
        AdsCascadeSelector.resolveBanner(
          cachedAds: onlyOtherCityAndExpired,
          userCity: 'Belén',
          planTier: KarritoPlanTier.free,
          now: now,
        ).source,
        AdSlotSource.admob,
      );
      expect(
        AdsCascadeSelector.resolveInterstitial(
          cachedAds: onlyOtherCityAndExpired,
          userCity: 'Belén',
          planTier: KarritoPlanTier.free,
          now: now,
        ).source,
        AdSlotSource.admob,
      );
    });
  });

  group('Cart price calculator, currency formatting, and expense history', () {
    test('CurrencyFormatter formats and parses Argentine ARS values', () {
      expect(CurrencyFormatter.formatArs(3800), '\$ 3.800');
      expect(CurrencyFormatter.formatArs(12500.5), '\$ 12.500,50');
      expect(CurrencyFormatter.parseArs('3.800'), 3800.0);
      expect(CurrencyFormatter.parseArs('\$ 12.500,50'), 12500.5);
      expect(CurrencyFormatter.parseArs('4500,25'), 4500.25);
      expect(CurrencyFormatter.parseArs('0'), isNull);
      expect(CurrencyFormatter.parseArs('-100'), isNull);
    });

    test(
      'CartPriceCalculator summarizes store subtotal and cart total and saves expense history',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final repo = ShoppingRepository(db: db, aiClassifier: _NoopAi());

        final list = (await repo.watchLists().first).first;
        final now = DateTime.now();

        final items = <ShoppingItemEntity>[
          ShoppingItemEntity(
            id: 'i1',
            listId: list.id,
            rawText: 'papa',
            cleanName: 'Papa',
            quantity: 2,
            unit: 'kg',
            storeCategory: 'Supermercado',
            aisleName: 'Verdulería y Frutería',
            price: 3800,
            isChecked: true,
            position: 0,
            updatedAt: now,
            syncStatus: 'pending',
          ),
          ShoppingItemEntity(
            id: 'i2',
            listId: list.id,
            rawText: 'leche',
            cleanName: 'Leche',
            quantity: 1,
            unit: 'l',
            storeCategory: 'Supermercado',
            aisleName: 'Lácteos y Refrigerados',
            price: 1650.5,
            isChecked: false,
            position: 1,
            updatedAt: now,
            syncStatus: 'pending',
          ),
          ShoppingItemEntity(
            id: 'i3',
            listId: list.id,
            rawText: 'ibuprofeno',
            cleanName: 'Ibuprofeno',
            quantity: 1,
            unit: 'caja',
            storeCategory: 'Farmacia',
            aisleName: 'Medicamentos',
            price: 4200,
            isChecked: true,
            position: 2,
            updatedAt: now,
            syncStatus: 'pending',
          ),
        ];

        final summary = CartPriceCalculator.summarize(
          items: items,
          activeStore: 'Supermercado',
        );
        expect(summary.storeAmount, 5450.5);
        expect(summary.totalAmount, 9650.5);
        expect(summary.checkedAmount, 8000.0);
        expect(summary.pricedCount, 3);
        expect(summary.unpricedCount, 0);

        final saved = await repo.recordShoppingExpenses(
          list: list,
          items: items,
        );
        expect(saved.storesRecorded, 2);
        expect(saved.totalRecorded, 9650.5);

        final history = await repo.watchExpenseHistory().first;
        expect(history, hasLength(2));
        expect(
          history.map((e) => e.storeCategory).toSet(),
          containsAll(<String>['Supermercado', 'Farmacia']),
        );
      },
    );
  });

  group('Media guard & RevenueCat entitlements', () {
    test('karrito-media-guard rejects voice clips over 60s or over 500 KB', () {
      expect(
        () => KarritoMediaCaptureService.validateVoiceLimits(
          durationSeconds: 60,
          byteLength: MonetizationConfig.maxVoiceBytes,
        ),
        returnsNormally,
      );
      expect(
        () => KarritoMediaCaptureService.validateVoiceLimits(
          durationSeconds: 61,
          byteLength: 120000,
        ),
        throwsA(isA<MediaGuardException>()),
      );
      expect(
        () => KarritoMediaCaptureService.validateVoiceLimits(
          durationSeconds: 20,
          byteLength: MonetizationConfig.maxVoiceBytes + 1,
        ),
        throwsA(isA<MediaGuardException>()),
      );
    });

    test(
      'RevenueCat entitlement resolver prioritizes pro_access over basic_access',
      () {
        expect(
          RevenueCatSubscriptionService.resolveTierFromEntitlements(<String>{}),
          KarritoPlanTier.free,
        );
        expect(
          RevenueCatSubscriptionService.resolveTierFromEntitlements(<String>{
            MonetizationConfig.entitlementBasic,
          }),
          KarritoPlanTier.basic,
        );
        expect(
          RevenueCatSubscriptionService.resolveTierFromEntitlements(<String>{
            MonetizationConfig.entitlementBasic,
            MonetizationConfig.entitlementPro,
          }),
          KarritoPlanTier.pro,
        );
      },
    );
  });

  group('Drift v5 -> v6 migration', () {
    test(
      'preserves v5 items and preferences while adding price, plan limits, ads cache, and expense history',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'karrito_v5_mig_',
        );
        final dbFile = File(
          '${tempDir.path}${Platform.pathSeparator}test_v5.db',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final db = AppDatabase(
          NativeDatabase(
            dbFile,
            setup: (raw) {
              if (raw.userVersion != 0) return;
              raw.execute('''
                CREATE TABLE local_lists (
                  id TEXT NOT NULL PRIMARY KEY,
                  title TEXT NOT NULL,
                  owner_id TEXT,
                  is_shared INTEGER NOT NULL DEFAULT 0,
                  share_code TEXT,
                  is_joined_remote INTEGER NOT NULL DEFAULT 0,
                  created_at INTEGER NOT NULL,
                  updated_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT 'pending'
                );
              ''');
              raw.execute('''
                CREATE TABLE local_items (
                  id TEXT NOT NULL PRIMARY KEY,
                  list_id TEXT NOT NULL REFERENCES local_lists(id) ON DELETE CASCADE,
                  raw_text TEXT NOT NULL,
                  clean_name TEXT NOT NULL,
                  quantity REAL NOT NULL DEFAULT 1.0,
                  unit TEXT NOT NULL DEFAULT 'u',
                  store_category TEXT NOT NULL,
                  aisle_name TEXT NOT NULL,
                  is_checked INTEGER NOT NULL DEFAULT 0,
                  position INTEGER NOT NULL DEFAULT 0,
                  updated_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT 'pending'
                );
              ''');
              raw.execute('''
                CREATE TABLE local_aisle_order (
                  store_category TEXT NOT NULL,
                  aisle_name TEXT NOT NULL,
                  sort_order INTEGER NOT NULL,
                  updated_at INTEGER,
                  sync_status TEXT NOT NULL DEFAULT 'seeded',
                  PRIMARY KEY (store_category, aisle_name)
                );
              ''');
              raw.execute('''
                CREATE TABLE local_learned_items (
                  normalized_name TEXT NOT NULL PRIMARY KEY,
                  display_name TEXT,
                  preferred_store TEXT NOT NULL,
                  preferred_aisle TEXT NOT NULL,
                  use_count INTEGER NOT NULL DEFAULT 1,
                  updated_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT 'pending'
                );
              ''');
              raw.execute('''
                CREATE TABLE local_preferences (
                  id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
                  city TEXT NOT NULL DEFAULT 'Andalgalá',
                  theme_mode TEXT NOT NULL DEFAULT 'system',
                  onboarding_completed INTEGER NOT NULL DEFAULT 0,
                  keep_screen_on INTEGER NOT NULL DEFAULT 1,
                  sound_enabled INTEGER NOT NULL DEFAULT 1,
                  vibration_enabled INTEGER NOT NULL DEFAULT 1,
                  avatar_choice TEXT NOT NULL DEFAULT 'avatar_1',
                  google_photo_url TEXT,
                  last_synced_at INTEGER
                );
              ''');
              raw.execute('''
                CREATE TABLE local_pending_deletions (
                  id TEXT NOT NULL PRIMARY KEY,
                  entity_type TEXT NOT NULL,
                  entity_key TEXT NOT NULL,
                  is_leave_only INTEGER NOT NULL DEFAULT 0,
                  deleted_at INTEGER NOT NULL
                );
              ''');
              raw.execute(
                'INSERT INTO local_preferences (id, city, theme_mode, onboarding_completed, avatar_choice) '
                "VALUES (1, 'Santa María', 'dark', 1, 'avatar_9');",
              );
              raw.execute(
                'INSERT INTO local_lists (id, title, created_at, updated_at) '
                "VALUES ('l-v5', 'Asado', 1730000000, 1730000000);",
              );
              raw.execute(
                'INSERT INTO local_items (id, list_id, raw_text, clean_name, store_category, aisle_name, updated_at) '
                "VALUES ('it-v5', 'l-v5', '2 kg vacío', 'Vacío', 'Supermercado', 'Carnicería', 1730000000);",
              );
              raw.execute('PRAGMA user_version = 5;');
            },
          ),
        );
        addTearDown(db.close);

        final repo = ShoppingRepository(db: db, aiClassifier: _NoopAi());
        final prefs = await repo.watchPreferences().first;
        expect(prefs.city, 'Santa María');
        expect(prefs.avatarChoice, 'avatar_9');
        expect(prefs.planTier, KarritoPlanTier.free);
        expect(prefs.freeMaxLists, 3);
        expect(prefs.basicMaxLists, 10);
        expect(prefs.proMaxLists, 999);
        expect(prefs.monthlyBudgetArs, isNull);

        final items = await repo.watchItemsForList('l-v5').first;
        expect(items, hasLength(1));
        expect(items.single.cleanName, 'Vacío');
        expect(items.single.price, isNull);

        await repo.updateItemPrice(item: items.single, price: 18500);
        final updatedItem = (await repo.watchItemsForList('l-v5').first).single;
        expect(updatedItem.price, 18500.0);

        // Verify new Phase 5 tables & indexes exist.
        final adsIndexes =
            (await db
                    .customSelect("PRAGMA index_list('local_cached_ads')")
                    .get())
                .map((r) => r.read<String>('name'))
                .toSet();
        final expIndexes =
            (await db
                    .customSelect("PRAGMA index_list('local_expense_history')")
                    .get())
                .map((r) => r.read<String>('name'))
                .toSet();
        expect(adsIndexes, contains('idx_local_cached_ads_city_tier'));
        expect(expIndexes, contains('idx_local_expense_history_recorded'));
      },
    );

    test(
      'handles partially migrated v5 -> v6 databases idempotently without duplicate column errors',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'karrito_v5_partial_',
        );
        final dbFile = File(
          '${tempDir.path}${Platform.pathSeparator}test_partial.db',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final db = AppDatabase(
          NativeDatabase(
            dbFile,
            setup: (raw) {
              if (raw.userVersion != 0) return;
              raw.execute('''
                CREATE TABLE local_lists (
                  id TEXT NOT NULL PRIMARY KEY,
                  title TEXT NOT NULL,
                  owner_id TEXT,
                  is_shared INTEGER NOT NULL DEFAULT 0,
                  share_code TEXT,
                  is_joined_remote INTEGER NOT NULL DEFAULT 0,
                  created_at INTEGER NOT NULL,
                  updated_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT 'pending'
                );
              ''');
              // Already has `price` column even though user_version is still 5!
              raw.execute('''
                CREATE TABLE local_items (
                  id TEXT NOT NULL PRIMARY KEY,
                  list_id TEXT NOT NULL REFERENCES local_lists(id) ON DELETE CASCADE,
                  raw_text TEXT NOT NULL,
                  clean_name TEXT NOT NULL,
                  quantity REAL NOT NULL DEFAULT 1.0,
                  unit TEXT NOT NULL DEFAULT 'u',
                  store_category TEXT NOT NULL,
                  aisle_name TEXT NOT NULL,
                  price REAL,
                  is_checked INTEGER NOT NULL DEFAULT 0,
                  position INTEGER NOT NULL DEFAULT 0,
                  updated_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT 'pending'
                );
              ''');
              raw.execute('''
                CREATE TABLE local_aisle_order (
                  store_category TEXT NOT NULL,
                  aisle_name TEXT NOT NULL,
                  sort_order INTEGER NOT NULL,
                  updated_at INTEGER,
                  sync_status TEXT NOT NULL DEFAULT 'seeded',
                  PRIMARY KEY (store_category, aisle_name)
                );
              ''');
              raw.execute('''
                CREATE TABLE local_learned_items (
                  normalized_name TEXT NOT NULL PRIMARY KEY,
                  display_name TEXT,
                  preferred_store TEXT NOT NULL,
                  preferred_aisle TEXT NOT NULL,
                  use_count INTEGER NOT NULL DEFAULT 1,
                  updated_at INTEGER NOT NULL,
                  sync_status TEXT NOT NULL DEFAULT 'pending'
                );
              ''');
              // Already has `plan_tier` column even though user_version is 5!
              raw.execute('''
                CREATE TABLE local_preferences (
                  id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
                  city TEXT NOT NULL DEFAULT 'Andalgalá',
                  theme_mode TEXT NOT NULL DEFAULT 'system',
                  onboarding_completed INTEGER NOT NULL DEFAULT 0,
                  keep_screen_on INTEGER NOT NULL DEFAULT 1,
                  sound_enabled INTEGER NOT NULL DEFAULT 1,
                  vibration_enabled INTEGER NOT NULL DEFAULT 1,
                  avatar_choice TEXT NOT NULL DEFAULT 'avatar_1',
                  google_photo_url TEXT,
                  plan_tier TEXT NOT NULL DEFAULT 'free',
                  last_synced_at INTEGER
                );
              ''');
              raw.execute('''
                CREATE TABLE local_pending_deletions (
                  id TEXT NOT NULL PRIMARY KEY,
                  entity_type TEXT NOT NULL,
                  entity_key TEXT NOT NULL,
                  is_leave_only INTEGER NOT NULL DEFAULT 0,
                  deleted_at INTEGER NOT NULL
                );
              ''');
              // Already has `local_cached_ads` table!
              raw.execute('''
                CREATE TABLE local_cached_ads (
                  id TEXT NOT NULL PRIMARY KEY,
                  business_name TEXT NOT NULL,
                  city TEXT NOT NULL,
                  tier TEXT NOT NULL,
                  banner_url TEXT,
                  interstitial_url TEXT,
                  action_url TEXT NOT NULL,
                  expires_at INTEGER NOT NULL,
                  is_active INTEGER NOT NULL DEFAULT 1,
                  cached_at INTEGER NOT NULL
                );
              ''');
              raw.execute(
                'INSERT INTO local_preferences (id, city, plan_tier) '
                "VALUES (1, 'Belén', 'pro_3usd');",
              );
              raw.execute('PRAGMA user_version = 5;');
            },
          ),
        );
        addTearDown(db.close);

        final repo = ShoppingRepository(db: db, aiClassifier: _NoopAi());
        final prefs = await repo.watchPreferences().first;
        expect(prefs.city, 'Belén');
        expect(prefs.planTier, KarritoPlanTier.pro);
        expect(prefs.freeMaxLists, 3);
        expect(prefs.basicMaxLists, 10);
        expect(prefs.proMaxLists, 999);
      },
    );
  });
}
