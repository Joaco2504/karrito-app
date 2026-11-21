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
import 'package:karrito_app/data/services/wakelock_service.dart';
import 'package:karrito_app/main.dart';
import 'package:karrito_app/providers/core_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _TestAuthService implements AuthService {
  @override
  Session? get currentSession => null;

  @override
  String? get currentUserId => 'test-user-id';

  @override
  Future<bool> ensureSignedInSilently() async => true;
}

class _TestWakelockService implements WakelockService {
  @override
  Future<void> setEnabled(bool enabled) async {}
}

class _TestAiClassifier implements AiClassifierService {
  @override
  Future<ProcesarListaResponse> classifyText(String text) async {
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
    'onboarding, selector bottom sheets, edit item sheet, and settings work end-to-end',
    (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      var dbClosed = false;
      addTearDown(() async {
        if (!dbClosed) {
          dbClosed = true;
          await db.close();
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            authServiceProvider.overrideWithValue(_TestAuthService()),
            wakelockServiceProvider.overrideWithValue(_TestWakelockService()),
            aiClassifierServiceProvider.overrideWithValue(_TestAiClassifier()),
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

      // Open locality selector bottom sheet, select Belén.
      await tester.tap(find.text('Andalgalá'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.selectCityTitle), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.text('Belén'));
      await tester.pumpAndSettle();
      expect(find.text('Belén'), findsOneWidget);

      await tester.tap(find.text(AppStrings.startShoppingButton));
      await tester.pumpAndSettle();

      // Navigated to main shopping screen with seeded list.
      expect(find.text('Compra semanal'), findsOneWidget);
      expect(find.text(AppStrings.emptyListTitle), findsOneWidget);

      // Add mixed items via smart input bar.
      await tester.enterText(
        find.byType(TextField),
        '2 kg de papa, 1 l leche, 1 caja ibuprofeno',
      );
      await tester.tap(find.text(AppStrings.addItemsButton));
      await tester.pumpAndSettle();

      // Dynamic store tabs and aisles rendered with pending counters.
      expect(find.text('Supermercado (2/2)'), findsOneWidget);
      expect(find.text('Farmacia (1/1)'), findsOneWidget);
      expect(find.text('Verdulería y Frutería'), findsOneWidget);
      expect(find.text('Papa'), findsOneWidget);
      expect(find.text('Leche'), findsOneWidget);

      // Open EditItemBottomSheet via long-press on Papa.
      await tester.longPress(find.text('Papa'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.editItemTitle), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text(AppStrings.removeShortButton), findsOneWidget);
      expect(find.text(AppStrings.saveShortButton), findsOneWidget);

      // Verify Quitar and Guardar sit horizontally on the same row.
      final removeCenter = tester.getCenter(
        find.text(AppStrings.removeShortButton),
      );
      final saveCenter = tester.getCenter(
        find.text(AppStrings.saveShortButton),
      );
      expect(removeCenter.dy, closeTo(saveCenter.dy, 2.0));
      expect(removeCenter.dx, lessThan(saveCenter.dx));

      // Change Comercio from Supermercado to Dietética / Naturista via selector sheet.
      await tester.tap(find.text('Supermercado').last);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.selectStoreTitle), findsOneWidget);
      await tester.tap(find.text('Dietética / Naturista'));
      await tester.pumpAndSettle();

      // Pasillo automatically updates to the first valid aisle of Dietética / Naturista.
      expect(find.text('Frutos Secos y Semillas'), findsOneWidget);

      // Save changes and confirm item moved tab.
      await tester.tap(find.text(AppStrings.saveShortButton));
      await tester.pumpAndSettle();
      expect(find.text('Dietética / Naturista (1/1)'), findsOneWidget);
      expect(find.text('Supermercado (1/1)'), findsOneWidget);

      // Check off Leche in Supermercado tab.
      await tester.tap(find.text('Leche'));
      await tester.pumpAndSettle();
      expect(find.text('Supermercado (0/1)'), findsOneWidget);

      // Open Settings and verify KarritoSelectorField and Switch.
      await tester.tap(find.byTooltip(AppStrings.settingsTooltip));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsTitle), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('Belén'), findsOneWidget);

      await tester.tap(find.text('Belén'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.selectCityTitle), findsOneWidget);
      await tester.tap(find.text('Andalgalá'));
      await tester.pumpAndSettle();
      expect(find.text('Andalgalá'), findsOneWidget);

      // Toggle keepScreenOn switch off and verify it updates state cleanly.
      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      // Verify explicit SwitchThemeData colors in Light and Dark themes.
      final lightSwitch = AppTheme.light().switchTheme;
      final darkSwitch = AppTheme.dark().switchTheme;
      expect(
        lightSwitch.trackColor?.resolve(<WidgetState>{}),
        const Color(0xFFEDE7DF),
      );
      expect(
        lightSwitch.trackOutlineColor?.resolve(<WidgetState>{}),
        const Color(0xFFD0C7BC),
      );
      expect(
        darkSwitch.trackColor?.resolve(<WidgetState>{}),
        const Color(0xFF2B2329),
      );
      expect(
        darkSwitch.trackOutlineColor?.resolve(<WidgetState>{}),
        const Color(0xFF4A3F46),
      );

      // Unmount ProviderScope and flush Drift's StreamQueryStore timer cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );
}
