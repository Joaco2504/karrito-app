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
import 'package:karrito_app/data/services/sync_service.dart';
import 'package:karrito_app/data/services/wakelock_service.dart';
import 'package:karrito_app/main.dart';
import 'package:karrito_app/providers/core_providers.dart';
import 'package:karrito_app/ui/widgets/aisle_reorder_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _TestAuthService implements AuthService {
  bool _isAnon = true;
  String? _email;
  final _authController = StreamController<AuthState>.broadcast();

  @override
  Session? get currentSession => null;

  @override
  String? get currentUserId => 'test-user-id';

  @override
  bool get isAnonymous => _isAnon;

  @override
  String? get currentEmail => _email;

  @override
  Stream<AuthState> get onAuthStateChange => _authController.stream;

  @override
  Future<bool> ensureSignedInSilently() async => true;

  @override
  Future<GoogleLinkOutcome?> linkOrSignInWithGoogle() async {
    _isAnon = false;
    _email = 'vecino@catamarca.test';
    return const GoogleLinkOutcome(
      userId: 'test-user-id',
      email: 'vecino@catamarca.test',
      switchedUid: false,
    );
  }

  void dispose() {
    _authController.close();
  }
}

class _TestWakelockService implements WakelockService {
  @override
  Future<void> setEnabled(bool enabled) async {}
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
    'Phase 3 flows: onboarding, quick theme toggle, aisle reorder, frequents, live join, and Google linking',
    (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final auth = _TestAuthService();
      final ai = _TestAiClassifier();
      final sync = _TestSyncService(db);
      var dbClosed = false;

      addTearDown(() async {
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
            aiClassifierServiceProvider.overrideWithValue(ai),
            syncServiceProvider.overrideWithValue(sync),
            isOnlineProvider.overrideWithValue(true),
          ],
          child: const KarritoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // First-run onboarding visible with Andalgalá preselected in KarritoSelectorField.
      expect(find.text(AppStrings.onboardingHeadline), findsOneWidget);
      expect(find.text('Andalgalá'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);

      // Select Belén via modal bottom sheet.
      await tester.tap(find.text('Andalgalá'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Belén'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.startShoppingButton));
      await tester.pumpAndSettle();

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

      // Open Aisle Reorder modal from "Ordenar pasillos" compact button.
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
      await tester.tap(find.text(AppStrings.doneButton));
      await tester.pumpAndSettle();
      expect(find.text('Supermercado (3/3)'), findsOneWidget);

      // Open EditItemBottomSheet via long-press on Papa.
      await tester.longPress(find.text('Papa').first);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.editItemTitle), findsOneWidget);

      final removeCenter = tester.getCenter(
        find.text(AppStrings.removeShortButton),
      );
      final saveCenter = tester.getCenter(
        find.text(AppStrings.saveShortButton),
      );
      expect(removeCenter.dy, closeTo(saveCenter.dy, 2.0));
      expect(removeCenter.dx, lessThan(saveCenter.dx));

      await tester.tap(find.text('Supermercado').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dietética / Naturista'));
      await tester.pumpAndSettle();
      expect(find.text('Frutos Secos y Semillas'), findsOneWidget);
      await tester.tap(find.text(AppStrings.saveShortButton));
      await tester.pumpAndSettle();
      expect(find.text('Dietética / Naturista (1/1)'), findsOneWidget);

      // Open ListSelectorSheet -> "Compartir lista en vivo" as Free user shows Pro info sheet.
      await tester.tap(find.text('Compra semanal'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.joinWithCodeButton), findsOneWidget);
      await tester.tap(find.text(AppStrings.shareLiveOption));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.proLiveSheetTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.proLiveUnderstandButton));
      await tester.pumpAndSettle();

      // Join shared list with 6-character code from ListSelectorSheet.
      await tester.tap(find.text('Compra semanal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.joinWithCodeButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.joinSheetTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'k7m-4p9');
      await tester.tap(find.text(AppStrings.joinSubmitButton));
      await tester.pumpAndSettle();
      expect(find.text('Asado compartido'), findsOneWidget);

      // Open Settings -> check dark mode synced & link Google account card.
      await tester.tap(find.byTooltip(AppStrings.settingsTooltip));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.guestAccountTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.linkGoogleButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.linkedAccountTitle), findsOneWidget);
      expect(find.text('vecino@catamarca.test'), findsOneWidget);

      // Verify SwitchThemeData colors remain explicit in both Light and Dark themes.
      final lightSwitch = AppTheme.light().switchTheme;
      final darkSwitch = AppTheme.dark().switchTheme;
      expect(
        lightSwitch.trackColor?.resolve(<WidgetState>{}),
        const Color(0xFFEDE7DF),
      );
      expect(
        darkSwitch.trackColor?.resolve(<WidgetState>{}),
        const Color(0xFF2B2329),
      );

      // Clean unmount & flush Drift's StreamQueryStore timer.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );
}
