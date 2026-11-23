import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karrito_app/core/constants/app_strings.dart';
import 'package:karrito_app/core/theme/app_theme.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/services/ads_cascade_service.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/data/services/auth_service.dart';
import 'package:karrito_app/data/services/media_capture_service.dart';
import 'package:karrito_app/data/services/push_notification_service.dart';
import 'package:karrito_app/data/services/sound_service.dart';
import 'package:karrito_app/data/services/subscription_service.dart';
import 'package:karrito_app/data/services/sync_service.dart';
import 'package:karrito_app/data/services/wakelock_service.dart';
import 'package:karrito_app/main.dart';
import 'package:karrito_app/providers/core_providers.dart';
import 'package:karrito_app/ui/screens/plans_screen.dart';
import 'package:karrito_app/ui/widgets/aisle_reorder_sheet.dart';
import 'package:karrito_app/ui/widgets/karrito_asset_icon.dart';
import 'package:karrito_app/ui/widgets/karrito_toast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _TestAuthService implements AuthService {
  bool _isAnon = true;
  String? _email;
  String? _displayName;
  String? _photoUrl;
  final _authController = StreamController<AuthState>.broadcast();

  @override
  Session? get currentSession => null;

  @override
  String? get currentUserId => _isAnon ? 'guest-user-id' : 'google-user-id';

  @override
  bool get isAnonymous => _isAnon;

  @override
  String? get currentEmail => _email;

  @override
  String? get currentPhotoUrl => _photoUrl;

  @override
  String? get currentDisplayName => _displayName;

  @override
  Stream<AuthState> get onAuthStateChange => _authController.stream;

  @override
  Future<bool> ensureSignedInSilently() async => true;

  @override
  Future<GoogleLinkOutcome?> linkOrSignInWithGoogle() async {
    _isAnon = false;
    _email = 'vecino@catamarca.test';
    _displayName = 'Vecino de Belén';
    _photoUrl = null;
    return const GoogleLinkOutcome(
      userId: 'google-user-id',
      email: 'vecino@catamarca.test',
      switchedUid: false,
      displayName: 'Vecino de Belén',
    );
  }

  @override
  Future<void> signOutToGuest() async {
    _isAnon = true;
    _email = null;
    _displayName = null;
    _photoUrl = null;
  }

  bool deleteAccountCalled = false;

  @override
  Future<void> deleteAccountPermanently() async {
    deleteAccountCalled = true;
    await signOutToGuest();
  }

  void dispose() {
    _authController.close();
  }
}

class _TestAdsCascadeService implements AdsCascadeService {
  _TestAdsCascadeService(this.db);

  final AppDatabase db;
  int interstitialShows = 0;

  @override
  Future<void> initializeMobileAdsSafely() async {}

  @override
  Stream<List<CachedAdEntity>> watchCachedAds() =>
      db.select(db.localCachedAds).watch();

  @override
  Future<void> refreshLocalAds(String userCity) async {}

  @override
  Future<void> recordImpression(String adId) async {}

  @override
  Future<void> recordClick(String adId) async {}

  @override
  Future<void> preloadAdMobInterstitial() async {}

  @override
  Future<bool> showAdMobInterstitialIfReady() async {
    interstitialShows++;
    return true;
  }

  @override
  Future<void> dispose() async {}
}

class _TestSubscriptionService implements SubscriptionService {
  @override
  bool get isConfigured => false;

  @override
  Future<void> configure({String? appUserId}) async {}

  @override
  Future<void> identifyUser(String? appUserId) async {}

  @override
  Future<String?> fetchActivePlanTier() async => null;

  @override
  Future<List<SubscriptionPlanOffer>> fetchMonthlyOffers() async =>
      RevenueCatSubscriptionService.defaultFallbackOffers();

  @override
  Future<SubscriptionActionOutcome> purchaseMonthlyPlan(
    String targetTier,
  ) async {
    return SubscriptionActionOutcome(
      planTier: targetTier,
      succeeded: true,
      message: 'Plan actualizado.',
    );
  }

  @override
  Future<SubscriptionActionOutcome> restorePurchases() async {
    return const SubscriptionActionOutcome(
      planTier: KarritoPlanTier.free,
      succeeded: false,
      message: 'Sin compras previas.',
    );
  }
}

class _TestMediaCaptureService implements MediaCaptureService {
  @override
  Future<bool> startVoiceRecording() async => true;

  @override
  Future<EncodedVoicePayload?> stopVoiceRecording({
    required int durationSeconds,
  }) async => null;

  @override
  Future<void> cancelVoiceRecording() async {}

  @override
  Future<EncodedImagePayload?> pickAndCompressImage(ImageSource source) async =>
      null;

  @override
  Future<void> dispose() async {}
}

class _TestPushNotificationService implements PushNotificationService {
  bool grantLocalPermission = true;
  int scheduledCount = 0;
  int cancelledCount = 0;

  @override
  Future<void> initializeSafely() async {}

  @override
  Future<String?> requestPermissionAndRegisterToken(String? userId) async =>
      null;

  @override
  Future<bool> requestLocalNotificationPermission() async =>
      grantLocalPermission;

  @override
  Future<void> schedulePendingItemsReminder({
    required int pendingCount,
    required String listTitle,
    Duration delay = const Duration(hours: 24),
  }) async {
    scheduledCount++;
  }

  @override
  Future<void> cancelPendingItemsReminder() async {
    cancelledCount++;
  }

  @override
  Future<void> dispose() async {}
}

class _TestWakelockService implements WakelockService {
  @override
  Future<void> setEnabled(bool enabled) async {}
}

class _TestSoundFeedbackService implements SoundFeedbackService {
  int playCalls = 0;

  @override
  Future<void> playItemCheckedFeedback({
    bool playSound = true,
    bool triggerVibration = true,
  }) async {
    playCalls++;
  }

  @override
  Future<void> dispose() async {}
}

class _TestSyncService implements SyncService {
  _TestSyncService(this.db);

  final AppDatabase db;
  bool simulatePro = false;
  int syncCalls = 0;

  @override
  Future<void> syncAll() async {
    syncCalls++;
  }

  @override
  Future<void> refreshAccountPlanAndConfig() async {}

  int stopLiveShareCalls = 0;

  @override
  Future<LiveShareOutcome> enableLiveShare(ShoppingListEntity list) async {
    if (!simulatePro) {
      return const LiveShareOutcome.requiresPro();
    }
    await (db.update(db.localLists)..where((t) => t.id.equals(list.id))).write(
      const LocalListsCompanion(
        isShared: Value(true),
        shareCode: Value('K7M4P9'),
      ),
    );
    return const LiveShareOutcome.ready('K7M4P9');
  }

  @override
  Future<void> stopLiveShare(ShoppingListEntity list) async {
    stopLiveShareCalls++;
    await (db.update(db.localLists)..where((t) => t.id.equals(list.id))).write(
      const LocalListsCompanion(isShared: Value(false), shareCode: Value(null)),
    );
  }

  @override
  Future<JoinedListResult> joinSharedListByCode(String rawCode) async {
    const joinedId = 'joined-live-list-id';
    final now = DateTime.now();
    await db
        .into(db.localLists)
        .insertOnConflictUpdate(
          LocalListsCompanion.insert(
            id: joinedId,
            title: 'Asado compartido',
            ownerId: const Value('other-pro-owner'),
            isShared: const Value(true),
            shareCode: Value(rawCode),
            isJoinedRemote: const Value(true),
            createdAt: now,
            updatedAt: now,
            syncStatus: const Value('synced'),
          ),
        );
    return const JoinedListResult(listId: joinedId, title: 'Asado compartido');
  }

  @override
  RealtimeChannel? subscribeToSharedList(String listId) => null;

  @override
  Future<void> unsubscribeChannel(RealtimeChannel? channel) async {}
}

class _TestAiClassifier implements AiClassifierService {
  int callCount = 0;

  @override
  Future<ProcesarListaResponse> classifyText(
    String text, {
    bool isRecipe = false,
  }) async {
    callCount++;
    if (isRecipe) {
      return const ProcesarListaResponse(
        items: <ProcessedAiItem>[
          ProcessedAiItem(
            cleanName: 'Azúcar',
            quantity: 100,
            unit: 'g',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
            recipeNote: '100 g para el flan',
          ),
          ProcessedAiItem(
            cleanName: 'Aceite de girasol',
            quantity: 150,
            unit: 'ml',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
            recipeNote: '150 ml para el flan',
          ),
        ],
      );
    }
    return const ProcesarListaResponse(
      items: <ProcessedAiItem>[
        ProcessedAiItem(
          cleanName: 'Papa',
          quantity: 2,
          unit: 'kg',
          storeCategory: 'Supermercado',
          aisleName: 'Verdulería y Frutería',
        ),
        ProcessedAiItem(
          cleanName: 'Leche',
          quantity: 1,
          unit: 'l',
          storeCategory: 'Supermercado',
          aisleName: 'Lácteos y Refrigerados',
        ),
        ProcessedAiItem(
          cleanName: 'Ibuprofeno',
          quantity: 1,
          unit: 'caja',
          storeCategory: 'Farmacia',
          aisleName: 'Medicamentos',
        ),
      ],
    );
  }

  @override
  Future<ProcesarListaResponse> classifyAudio({
    required String audioBase64,
    String mimeType = 'audio/m4a',
  }) async => classifyText('audio');

  @override
  Future<ProcesarListaResponse> classifyImage({
    required String imageBase64,
    String mimeType = 'image/jpeg',
    bool isRecipe = false,
    String? textHint,
  }) async => classifyText(textHint ?? 'image', isRecipe: isRecipe);
}

void main() {
  testWidgets(
    'Phase 3.5 end-to-end: onboarding dual CTAs, Electric Mercado palette, avatar profile menu, QR live share, vibration toggle, and sign-out keeping local lists',
    (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final auth = _TestAuthService();
      final ai = _TestAiClassifier();
      final sync = _TestSyncService(db);
      final sound = _TestSoundFeedbackService();
      final ads = _TestAdsCascadeService(db);
      var dbClosed = false;

      addTearDown(() async {
        KarritoToast.dismissCurrent();
        auth.dispose();
        if (!dbClosed) {
          dbClosed = true;
          await db.close();
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseInitializerProvider.overrideWithValue(() async => true),
            appDatabaseProvider.overrideWithValue(db),
            authServiceProvider.overrideWithValue(auth),
            wakelockServiceProvider.overrideWithValue(_TestWakelockService()),
            soundFeedbackServiceProvider.overrideWithValue(sound),
            aiClassifierServiceProvider.overrideWithValue(ai),
            syncServiceProvider.overrideWithValue(sync),
            adsCascadeServiceProvider.overrideWithValue(ads),
            subscriptionServiceProvider.overrideWithValue(
              _TestSubscriptionService(),
            ),
            mediaCaptureServiceProvider.overrideWithValue(
              _TestMediaCaptureService(),
            ),
            pushNotificationServiceProvider.overrideWithValue(
              _TestPushNotificationService(),
            ),
            isOnlineProvider.overrideWithValue(true),
          ],
          child: const KarritoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // First-run onboarding visible with cards AND both bottom CTAs.
      expect(find.text(AppStrings.onboardingHeadline), findsOneWidget);
      expect(find.text(AppStrings.onboardingCard1Title), findsOneWidget);
      expect(find.text(AppStrings.startShoppingButton), findsOneWidget);
      expect(find.text(AppStrings.onboardingGoogleButton), findsOneWidget);
      expect(find.text('Andalgalá'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);

      // Step through onboarding cards via arrow button.
      await tester.tap(find.byTooltip(AppStrings.onboardingNextButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.onboardingCard2Title), findsOneWidget);

      await tester.tap(find.byTooltip(AppStrings.onboardingNextButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.onboardingCard3Title), findsOneWidget);

      // Select Belén via modal bottom sheet before entering app.
      await tester.tap(find.text('Andalgalá'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Belén'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.startShoppingButton));
      await tester.pumpAndSettle();

      // Top-left shows Karrito brand logo (custom PNG or fallback), top-right has circular avatar.
      expect(find.byType(KarritoBrandLogo), findsOneWidget);
      expect(find.byTooltip(AppStrings.profileMenuTooltip), findsOneWidget);
      expect(find.byTooltip(AppStrings.settingsTooltip), findsNothing);

      // Quick theme toggle on home bar flips light <-> dark and persists in Drift.
      final toggleToDark = find.byTooltip(AppStrings.switchToDarkTooltip);
      expect(toggleToDark, findsOneWidget);
      await tester.tap(toggleToDark);
      await tester.pumpAndSettle();
      expect(find.byTooltip(AppStrings.switchToLightTooltip), findsOneWidget);

      final prefsAfterToggle = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(prefsAfterToggle.themeMode, 'dark');
      expect(prefsAfterToggle.onboardingCompleted, isTrue);

      // Add mixed items via smart input bar.
      await tester.enterText(
        find.byType(TextField),
        '2 kg de papa, 1 l leche, 1 caja ibuprofeno',
      );
      await tester.tap(find.text(AppStrings.addItemsButton));
      await tester.pumpAndSettle();
      final aiCallsAfterInput = ai.callCount;
      expect(aiCallsAfterInput, 1);

      expect(find.text('Supermercado (2/2)'), findsOneWidget);
      expect(find.text('Farmacia (1/1)'), findsOneWidget);

      // Open Aisle Reorder modal.
      await tester.tap(find.text(AppStrings.reorderAislesButton));
      await tester.pumpAndSettle();
      expect(find.byType(AisleReorderSheet), findsOneWidget);
      expect(find.byType(ReorderableListView), findsOneWidget);
      await tester.tap(find.text(AppStrings.saveOrderButton));
      await tester.pumpAndSettle();

      // Open Frecuentes sheet and add Leche with ZERO extra AI calls.
      await tester.tap(find.text(AppStrings.frequentButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.frequentItemsTitle), findsOneWidget);
      await tester.tap(find.text('Leche').last);
      await tester.pumpAndSettle();
      expect(ai.callCount, aiCallsAfterInput);
      await tester.tap(find.text(AppStrings.frequentDoneButton));
      await tester.pumpAndSettle();
      expect(find.text('Supermercado (3/3)'), findsOneWidget);

      // Checking an item triggers SoundFeedbackService; unchecking stays silent.
      expect(sound.playCalls, 0);
      await tester.tap(find.text('Papa').first);
      await tester.pumpAndSettle();
      expect(sound.playCalls, 1);
      await tester.tap(find.text('Papa').first);
      await tester.pumpAndSettle();
      expect(sound.playCalls, 1);

      // Open EditItemBottomSheet via long-press on Papa & assign a new Phase 3.5 rubro.
      await tester.longPress(find.text('Papa').first);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.editItemTitle), findsOneWidget);

      await tester.tap(find.text('Supermercado').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bazar y Hogar'));
      await tester.pumpAndSettle();
      expect(find.text('Cocina y Vajilla'), findsOneWidget);
      await tester.tap(find.text(AppStrings.saveShortButton));
      await tester.pumpAndSettle();
      expect(find.text('Bazar y Hogar (1/1)'), findsOneWidget);

      // Open unified ShareOptionsSheet: shows WhatsApp, Live share, and Join list.
      await tester.tap(find.byTooltip(AppStrings.shareListTooltip));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.shareAsTextOption), findsOneWidget);
      expect(find.text(AppStrings.shareLiveOption), findsOneWidget);
      expect(find.text(AppStrings.shareJoinOption), findsOneWidget);

      // Free user tapping "Compartir lista en vivo" sees Pro notice.
      await tester.tap(find.text(AppStrings.shareLiveOption));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.proLiveSheetTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.proLiveUnderstandButton));
      await tester.pumpAndSettle();

      // Pro user tapping "Compartir lista en vivo" sees scannable QrImageView + 6-char code.
      sync.simulatePro = true;
      await tester.tap(find.byTooltip(AppStrings.shareListTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.shareLiveOption));
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text(AppStrings.liveQrCaption), findsOneWidget);
      Navigator.of(tester.element(find.byType(QrImageView))).pop();
      await tester.pumpAndSettle();

      // Unified ShareOptionsSheet -> Unirme a una lista shows QR scan button & joins via deep-link/code.
      await tester.tap(find.byTooltip(AppStrings.shareListTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.shareJoinOption));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.scanQrButton), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).last,
        'karrito://join/K7M4P9',
      );
      await tester.tap(find.text(AppStrings.joinSubmitButton));
      await tester.pumpAndSettle();
      expect(find.text('Asado compartido'), findsOneWidget);

      // Free user tapping voice mic opens monthly-only PlansScreen (NO annual toggle).
      await tester.tap(find.byTooltip(AppStrings.voiceInputTooltip));
      await tester.pumpAndSettle();
      expect(find.byType(PlansScreen), findsOneWidget);
      expect(find.text(AppStrings.planProName), findsOneWidget);
      expect(find.text('Anual'), findsNothing);
      await tester.scrollUntilVisible(find.text(AppStrings.planBasicName), 200);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.planBasicName), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Open ProfileMenuSheet -> select avatar_3, verify all 12 avatars + Plans option, open Guide+FAQ, then Preferencias.
      await tester.tap(find.byTooltip(AppStrings.profileMenuTooltip));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.guestAccountTitle), findsOneWidget);
      expect(find.text(AppStrings.profilePlansOption), findsOneWidget);
      expect(find.text(AppStrings.profilePreferencesOption), findsOneWidget);
      expect(find.text(AppStrings.profileGuideFaqOption), findsOneWidget);
      expect(find.text(AppStrings.profileSignInGoogleOption), findsOneWidget);

      await tester.tap(find.byTooltip('Avatar 3'));
      await tester.pumpAndSettle();
      final prefsAfterAvatar = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(prefsAfterAvatar.avatarChoice, 'avatar_3');

      // Open Guía básica y preguntas frecuentes from Profile Menu.
      await tester.tap(find.text(AppStrings.profileGuideFaqOption));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.guideFaqTitle), findsOneWidget);
      final guideScrollable = find
          .descendant(
            of: find.byKey(const ValueKey<String>('guide_faq_list_view')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text(AppStrings.faqEntries.first.question),
        220,
        scrollable: guideScrollable,
      );
      expect(find.text(AppStrings.faqEntries.first.question), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Open Preferencias (SettingsScreen) from Profile Menu, verify Sound + Vibration toggles, link Google.
      await tester.tap(find.byTooltip(AppStrings.profileMenuTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.profilePreferencesOption));
      await tester.pumpAndSettle();

      expect(find.text('Sistema'), findsOneWidget);
      await tester.tap(find.text(AppStrings.linkGoogleButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(AppStrings.linkedAccountTitle), findsOneWidget);
      expect(find.text('vecino@catamarca.test'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(AppStrings.settingsGuideTitle),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsSoundOnCheckTitle), findsOneWidget);
      expect(
        find.text(AppStrings.settingsVibrationOnCheckTitle),
        findsOneWidget,
      );
      expect(find.text(AppStrings.settingsRemindersTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsGuideTitle), findsOneWidget);
      // FAQ accordion is no longer duplicated inside SettingsScreen.
      expect(find.text(AppStrings.faqEntries.first.question), findsNothing);

      // Scroll down to mandatory "Cuenta y privacidad" section with delete button.
      await tester.scrollUntilVisible(
        find.text(AppStrings.deleteAccountButton),
        250,
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.deleteAccountButton), findsOneWidget);
      await tester.tap(find.text(AppStrings.deleteAccountButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.deleteAccountDialogTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      // Go back to main screen, open Profile Menu and tap Cerrar sesión -> guest mode keeping local lists!
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppStrings.profileMenuTooltip));
      await tester.pumpAndSettle();
      expect(find.text('Vecino de Belén'), findsOneWidget);
      expect(find.text(AppStrings.profileSignOutOption), findsOneWidget);

      await tester.tap(find.text(AppStrings.profileSignOutOption));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(AppStrings.signedOutNotice), findsOneWidget);

      final remainingLists = await db.select(db.localLists).get();
      expect(remainingLists.isNotEmpty, isTrue);

      // Verify exact electric_mercado_1 (Light) & electric_mercado_2 (Dark) theme tokens.
      final lightTheme = AppTheme.light();
      final darkTheme = AppTheme.dark();
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFFDF7FF));
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF12111A));
      expect(
        lightTheme.switchTheme.trackColor?.resolve(<WidgetState>{}),
        const Color(0xFFE6DFF4),
      );
      expect(
        lightTheme.switchTheme.trackColor?.resolve(<WidgetState>{
          WidgetState.selected,
        }),
        const Color(0xFF531CB3),
      );
      expect(
        darkTheme.switchTheme.trackColor?.resolve(<WidgetState>{}),
        const Color(0xFF161422),
      );
      expect(
        darkTheme.switchTheme.thumbColor?.resolve(<WidgetState>{
          WidgetState.selected,
        }),
        const Color(0xFFCCFF00),
      );

      // Flush pending toast auto-dismiss timer and unmount cleanly.
      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );

  testWidgets(
    'Phase 5.3: Plus Jakarta Sans typography, onboarding assets, clipboard Pegar, Limpiar tachados, stop/leave live share, and 24h reminders',
    (WidgetTester tester) async {
      // Narrow phone viewport (360x800) to guarantee zero horizontal overflow on input chips.
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 1. Verify offline Plus Jakarta Sans TTF weights & onboarding demo assets exist.
      for (final weight in const <String>[
        'Regular',
        'Medium',
        'SemiBold',
        'Bold',
        'ExtraBold',
      ]) {
        expect(
          File('assets/fonts/PlusJakartaSans-$weight.ttf').existsSync(),
          isTrue,
        );
      }
      for (var step = 1; step <= 3; step++) {
        expect(File('assets/onboarding/step_$step.png').existsSync(), isTrue);
      }
      expect(File('assets/onboarding/README.txt').existsSync(), isTrue);

      final lightTheme = AppTheme.light();
      expect(
        lightTheme.textTheme.displayLarge?.fontFamily,
        AppTheme.fontFamily,
      );
      expect(lightTheme.textTheme.headlineMedium?.fontSize, 22);
      expect(lightTheme.textTheme.labelSmall?.letterSpacing, 0.33);

      // Mock platform Clipboard for empty & populated cases.
      String? clipboardText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return clipboardText == null
                ? null
                : <String, dynamic>{'text': clipboardText};
          }
          if (methodCall.method == 'Clipboard.setData') {
            final args = methodCall.arguments as Map<dynamic, dynamic>?;
            clipboardText = args?['text']?.toString();
            return null;
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      final db = AppDatabase(NativeDatabase.memory());
      final auth = _TestAuthService();
      final ai = _TestAiClassifier();
      final sync = _TestSyncService(db)..simulatePro = true;
      final sound = _TestSoundFeedbackService();
      final ads = _TestAdsCascadeService(db);
      final push = _TestPushNotificationService();
      var dbClosed = false;

      // Mark onboarding completed so we start directly on ShoppingListScreen.
      await (db.update(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).write(
        const LocalPreferencesCompanion(onboardingCompleted: Value(true)),
      );

      addTearDown(() async {
        KarritoToast.dismissCurrent();
        auth.dispose();
        if (!dbClosed) {
          dbClosed = true;
          await db.close();
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseInitializerProvider.overrideWithValue(() async => true),
            appDatabaseProvider.overrideWithValue(db),
            authServiceProvider.overrideWithValue(auth),
            wakelockServiceProvider.overrideWithValue(_TestWakelockService()),
            soundFeedbackServiceProvider.overrideWithValue(sound),
            aiClassifierServiceProvider.overrideWithValue(ai),
            syncServiceProvider.overrideWithValue(sync),
            adsCascadeServiceProvider.overrideWithValue(ads),
            subscriptionServiceProvider.overrideWithValue(
              _TestSubscriptionService(),
            ),
            mediaCaptureServiceProvider.overrideWithValue(
              _TestMediaCaptureService(),
            ),
            pushNotificationServiceProvider.overrideWithValue(push),
            isOnlineProvider.overrideWithValue(true),
          ],
          child: const KarritoApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Empty clipboard shows info toast; populated clipboard pastes into TextField.
      expect(find.text(AppStrings.pasteClipboardButton), findsOneWidget);
      expect(find.text(AppStrings.frequentButton), findsOneWidget);
      expect(find.text(AppStrings.importRecipeButton), findsOneWidget);
      expect(find.text(AppStrings.addItemsButton), findsOneWidget);

      await tester.tap(find.text(AppStrings.pasteClipboardButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text(AppStrings.clipboardEmptyNotice), findsOneWidget);
      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();

      clipboardText = '2 kg de papa, 1 l leche, 1 caja ibuprofeno';
      await tester.tap(find.text(AppStrings.pasteClipboardButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text(AppStrings.clipboardPastedNotice), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, clipboardText);
      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();

      // Submit pasted items.
      await tester.tap(find.text(AppStrings.addItemsButton));
      await tester.pumpAndSettle();
      expect(find.text('Supermercado (2/2)'), findsOneWidget);

      // 3. Check both Supermercado items -> Limpiar tachados (2) appears & clears with tombstones.
      await tester.tap(find.text('Papa').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Leche').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leche').first);
      await tester.pumpAndSettle();

      final clearBtn = find.text(AppStrings.clearCheckedButton(2));
      await tester.ensureVisible(clearBtn);
      await tester.pumpAndSettle();
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.clearCheckedConfirmTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.clearCheckedConfirmButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        find.text(AppStrings.clearCheckedSuccessNotice(2)),
        findsOneWidget,
      );

      final tombstones = await db.select(db.localPendingDeletions).get();
      expect(tombstones.where((t) => t.entityType == 'item').length, 2);
      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();

      // 4. Enable live share on owned list, then tap "Dejar de compartir en vivo".
      await tester.tap(find.byTooltip(AppStrings.shareListTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.shareLiveOption));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.stopLiveShareButton), findsOneWidget);

      await tester.ensureVisible(find.text(AppStrings.stopLiveShareButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.stopLiveShareButton));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(AppStrings.stopLiveShareConfirmButton), findsOneWidget);
      await tester.tap(find.text(AppStrings.stopLiveShareConfirmButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(sync.stopLiveShareCalls, 1);
      expect(find.text(AppStrings.stopLiveShareSuccessNotice), findsOneWidget);
      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();

      // 5. Join another user's shared list -> LiveShareCodeSheet shows "Salir de esta lista".
      await tester.tap(find.byTooltip(AppStrings.shareListTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.shareJoinOption));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'K7M4P9');
      await tester.tap(find.text(AppStrings.joinSubmitButton));
      await tester.pumpAndSettle();
      expect(find.text('Asado compartido'), findsOneWidget);

      await tester.tap(find.text('Código K7M4P9'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(AppStrings.leaveSharedListButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.leaveSharedListButton), findsOneWidget);
      await tester.tap(find.text(AppStrings.leaveSharedListButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.leaveSharedListButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Asado compartido'), findsNothing);

      // 6. Enable reminders toggle in SettingsScreen -> pausing app schedules 24h reminder.
      await tester.tap(find.byTooltip(AppStrings.profileMenuTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.profilePreferencesOption));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(AppStrings.settingsRemindersTitle),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      final switches = find.byType(Switch);
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      final updatedPrefs = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(updatedPrefs.remindersEnabled, isTrue);

      // Trigger realistic OS background transition -> schedules 24h reminder for pending "Ibuprofeno".
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(push.scheduledCount, 1);

      final cancelledBefore = push.cancelledCount;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(push.cancelledCount, greaterThan(cancelledBefore));

      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );

  testWidgets(
    'Phase 5.3 polish: nano-banana onboarding CTAs, SliverAppBar hide-on-scroll, Pro Recetas preview checklist & 9 extended FAQs',
    (WidgetTester tester) async {
      // 1. Verify all 3 nano-banana onboarding illustrations exist on disk.
      expect(File('assets/onboarding/step_1.png').existsSync(), isTrue);
      expect(File('assets/onboarding/step_2.png').existsSync(), isTrue);
      expect(File('assets/onboarding/step_3.png').existsSync(), isTrue);
      expect(AppStrings.faqEntries, hasLength(9));

      final db = AppDatabase(NativeDatabase.memory());
      final auth = _TestAuthService();
      final ai = _TestAiClassifier();
      final sync = _TestSyncService(db)..simulatePro = true;
      final sound = _TestSoundFeedbackService();
      final ads = _TestAdsCascadeService(db);
      final push = _TestPushNotificationService();
      var dbClosed = false;

      addTearDown(() async {
        KarritoToast.dismissCurrent();
        auth.dispose();
        if (!dbClosed) {
          dbClosed = true;
          await db.close();
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseInitializerProvider.overrideWithValue(() async => true),
            appDatabaseProvider.overrideWithValue(db),
            authServiceProvider.overrideWithValue(auth),
            wakelockServiceProvider.overrideWithValue(_TestWakelockService()),
            soundFeedbackServiceProvider.overrideWithValue(sound),
            aiClassifierServiceProvider.overrideWithValue(ai),
            syncServiceProvider.overrideWithValue(sync),
            adsCascadeServiceProvider.overrideWithValue(ads),
            subscriptionServiceProvider.overrideWithValue(
              _TestSubscriptionService(),
            ),
            mediaCaptureServiceProvider.overrideWithValue(
              _TestMediaCaptureService(),
            ),
            pushNotificationServiceProvider.overrideWithValue(push),
            isOnlineProvider.overrideWithValue(true),
          ],
          child: const KarritoApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Onboarding primary CTA is Neon Papaya (#FF6238) and Google CTA is Violet (#531CB3).
      final startBtn = tester.widget<FilledButton>(
        find.byKey(const ValueKey<String>('onboarding_start_button')),
      );
      expect(
        startBtn.style?.backgroundColor?.resolve(<WidgetState>{}),
        const Color(0xFFFF6238),
      );
      final googleBtn = tester.widget<FilledButton>(
        find.byKey(const ValueKey<String>('onboarding_google_button')),
      );
      expect(
        googleBtn.style?.backgroundColor?.resolve(<WidgetState>{}),
        const Color(0xFF531CB3),
      );

      // Enter app and upgrade local preference tier to Pro.
      await tester.tap(find.text(AppStrings.startShoppingButton));
      await tester.pumpAndSettle();
      await (db.update(db.localPreferences)..where((t) => t.id.equals(1)))
          .write(const LocalPreferencesCompanion(planTier: Value('pro_3usd')));
      await tester.pumpAndSettle();

      // 3. Verify SliverAppBar(floating: true, snap: false) inside CustomScrollView
      // for smooth gradual reveal, soft rounded TextField (minLines: 2, maxLines: 3),
      // and all 3 action buttons (Pegar, Frecuentes, + Agregar) aligned on one row.
      final sliverAppBar = tester.widget<SliverAppBar>(
        find.byType(SliverAppBar),
      );
      expect(sliverAppBar.floating, isTrue);
      expect(sliverAppBar.snap, isFalse);

      final inputContainer = tester.widget<Container>(
        find.byKey(const ValueKey<String>('smart_input_container')),
      );
      final inputDeco = inputContainer.decoration! as BoxDecoration;
      expect(inputDeco.borderRadius, BorderRadius.circular(20));

      final smartTextField = tester.widget<TextField>(find.byType(TextField));
      expect(smartTextField.minLines, 2);
      expect(smartTextField.maxLines, 3);

      final pasteRect = tester.getRect(
        find.text(AppStrings.pasteClipboardButton),
      );
      final freqRect = tester.getRect(find.text(AppStrings.frequentButton));
      final addRect = tester.getRect(find.text(AppStrings.addItemsButton));
      expect((pasteRect.center.dy - freqRect.center.dy).abs(), lessThan(2.0));
      expect((freqRect.center.dy - addRect.center.dy).abs(), lessThan(2.0));
      expect(pasteRect.right, lessThan(freqRect.left));
      expect(freqRect.right, lessThan(addRect.left));

      // 4. Tap wide "Recetas" button -> preview checklist with Argentine retail packages.
      final recipesBtn = find.byKey(
        const ValueKey<String>('wide_recipes_button'),
      );
      expect(recipesBtn, findsOneWidget);
      await tester.tap(recipesBtn);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.importRecipeTitle), findsOneWidget);
      expect(find.text(AppStrings.importRecipeCameraButton), findsOneWidget);
      expect(find.text(AppStrings.importRecipeGalleryButton), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).last,
        'Flan casero para 6 personas',
      );
      await tester.tap(find.text(AppStrings.importRecipeSubmitButton));
      await tester.pumpAndSettle();

      // Preview checklist renders normalized packages (1 kg, 1 l) + recipe notes.
      expect(find.text('Azúcar'), findsOneWidget);
      expect(find.text('1 kg'), findsOneWidget);
      expect(find.text('Receta: 100 g para el flan'), findsOneWidget);
      expect(find.text('Aceite de girasol'), findsOneWidget);
      expect(find.text('1 l'), findsOneWidget);
      expect(find.text(AppStrings.importRecipeAddSelected(2)), findsOneWidget);

      // Uncheck Aceite de girasol -> only 1 ingredient selected.
      await tester.tap(find.text('Aceite de girasol'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.importRecipeAddSelected(1)), findsOneWidget);

      // Confirm saving only selected item.
      await tester.tap(find.text(AppStrings.importRecipeAddSelected(1)));
      await tester.pumpAndSettle();

      expect(find.text('Azúcar'), findsOneWidget);
      expect(find.text('100 g para el flan'), findsOneWidget);
      expect(find.text('Aceite de girasol'), findsNothing);

      // 5. Populate enough items to verify hide-on-scroll collapses SliverAppBar cleanly.
      final activeList = (await db.select(db.localLists).get()).first;
      final now = DateTime.now().toUtc();
      for (var i = 1; i <= 16; i++) {
        await db
            .into(db.localItems)
            .insert(
              LocalItemsCompanion.insert(
                id: 'scroll-item-$i',
                listId: activeList.id,
                rawText: 'Producto $i',
                cleanName: 'Producto extra $i',
                quantity: const Value(1),
                unit: const Value('u'),
                storeCategory: 'Supermercado',
                aisleName: 'Almacén',
                updatedAt: now,
              ),
            );
      }
      await tester.pumpAndSettle();

      final initialRecipesRect = tester.getRect(recipesBtn);
      await tester.drag(
        find.byKey(const ValueKey<String>('shopping_list_scroll_view')),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      // Header hides off-screen or moves upward out of viewport.
      final afterScrollFinder = find.byKey(
        const ValueKey<String>('wide_recipes_button'),
      );
      if (afterScrollFinder.evaluate().isNotEmpty) {
        expect(
          tester.getRect(afterScrollFinder).top,
          lessThan(initialRecipesRect.top),
        );
      }

      // Swipe back down gradually (snap: false reveals proportionally to drag).
      await tester.drag(
        find.byKey(const ValueKey<String>('shopping_list_scroll_view')),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('wide_recipes_button')),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byTooltip(AppStrings.profileMenuTooltip)).top,
        greaterThanOrEqualTo(0),
      );

      // 6. Open Profile Menu -> Guide & FAQ -> verify all 9 extended FAQs exist and expand.
      await tester.tap(find.byTooltip(AppStrings.profileMenuTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.profileGuideFaqOption));
      await tester.pumpAndSettle();

      final guideScrollable = find
          .descendant(
            of: find.byKey(const ValueKey<String>('guide_faq_list_view')),
            matching: find.byType(Scrollable),
          )
          .first;
      for (final entry in AppStrings.faqEntries) {
        await tester.scrollUntilVisible(
          find.text(entry.question),
          220,
          scrollable: guideScrollable,
        );
        expect(find.text(entry.question), findsOneWidget);
      }

      // Tap last FAQ ("¿Tiene costo usar la aplicación?") -> expands answer.
      await tester.tap(find.text(AppStrings.faqEntries.last.question));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.faqEntries.last.answer), findsOneWidget);

      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );

  testWidgets(
    'Phase 5.4: 360dp narrow viewport with 1.3x text scale renders input bar and 3 action buttons on one row without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      final auth = _TestAuthService();
      final ai = _TestAiClassifier();
      final sync = _TestSyncService(db);
      final sound = _TestSoundFeedbackService();
      final ads = _TestAdsCascadeService(db);
      final push = _TestPushNotificationService();
      var dbClosed = false;

      await (db.update(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).write(
        const LocalPreferencesCompanion(onboardingCompleted: Value(true)),
      );

      addTearDown(() async {
        KarritoToast.dismissCurrent();
        auth.dispose();
        if (!dbClosed) {
          dbClosed = true;
          await db.close();
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseInitializerProvider.overrideWithValue(() async => true),
            appDatabaseProvider.overrideWithValue(db),
            authServiceProvider.overrideWithValue(auth),
            wakelockServiceProvider.overrideWithValue(_TestWakelockService()),
            soundFeedbackServiceProvider.overrideWithValue(sound),
            aiClassifierServiceProvider.overrideWithValue(ai),
            syncServiceProvider.overrideWithValue(sync),
            adsCascadeServiceProvider.overrideWithValue(ads),
            subscriptionServiceProvider.overrideWithValue(
              _TestSubscriptionService(),
            ),
            mediaCaptureServiceProvider.overrideWithValue(
              _TestMediaCaptureService(),
            ),
            pushNotificationServiceProvider.overrideWithValue(push),
            isOnlineProvider.overrideWithValue(true),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 780),
              textScaler: TextScaler.linear(1.3),
            ),
            child: const KarritoApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Zero RenderFlex overflows on narrow 360dp screen at 1.3x font scale.
      expect(tester.takeException(), isNull);

      final pasteRect = tester.getRect(
        find.text(AppStrings.pasteClipboardButton),
      );
      final freqRect = tester.getRect(find.text(AppStrings.frequentButton));
      final addRect = tester.getRect(find.text(AppStrings.addItemsButton));
      expect((pasteRect.center.dy - freqRect.center.dy).abs(), lessThan(2.5));
      expect((freqRect.center.dy - addRect.center.dy).abs(), lessThan(2.5));
      expect(pasteRect.right, lessThan(freqRect.left));
      expect(freqRect.right, lessThan(addRect.left));
      expect(addRect.right, lessThanOrEqualTo(360.0));

      KarritoToast.dismissCurrent();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );
}
