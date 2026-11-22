import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/constants/app_strings.dart';
import 'package:karrito_app/core/theme/app_theme.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/data/services/auth_service.dart';
import 'package:karrito_app/data/services/sound_service.dart';
import 'package:karrito_app/data/services/sync_service.dart';
import 'package:karrito_app/data/services/wakelock_service.dart';
import 'package:karrito_app/main.dart';
import 'package:karrito_app/providers/core_providers.dart';
import 'package:karrito_app/ui/widgets/aisle_reorder_sheet.dart';
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

  void dispose() {
    _authController.close();
  }
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
  Future<LiveShareOutcome> enableLiveShare(ShoppingListEntity list) async {
    if (!simulatePro) {
      return const LiveShareOutcome.requiresPro();
    }
    return const LiveShareOutcome.ready('K7M4P9');
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
  Future<ProcesarListaResponse> classifyText(String text) async {
    callCount++;
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
            appDatabaseProvider.overrideWithValue(db),
            authServiceProvider.overrideWithValue(auth),
            wakelockServiceProvider.overrideWithValue(_TestWakelockService()),
            soundFeedbackServiceProvider.overrideWithValue(sound),
            aiClassifierServiceProvider.overrideWithValue(ai),
            syncServiceProvider.overrideWithValue(sync),
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

      // Top-left shows Karrito brand logo fallback, top-right has circular avatar instead of gear.
      expect(find.text('Karrito'), findsOneWidget);
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

      // Open ProfileMenuSheet -> select avatar_3, verify persistence, open Guide+FAQ, then Preferencias.
      await tester.tap(find.byTooltip(AppStrings.profileMenuTooltip));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.guestAccountTitle), findsOneWidget);
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
        find.text(AppStrings.settingsVibrationOnCheckTitle),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsSoundOnCheckTitle), findsOneWidget);
      expect(
        find.text(AppStrings.settingsVibrationOnCheckTitle),
        findsOneWidget,
      );

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
}
