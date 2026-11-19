import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/constants/app_strings.dart';
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
    'onboarding completes and renders store tabs, aisles, and check-off flow',
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

      // First-run onboarding visible with Andalgalá preselected.
      expect(find.text(AppStrings.onboardingHeadline), findsOneWidget);
      expect(find.text('Andalgalá'), findsOneWidget);

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

      // Check off Papa and verify counter flips from 1/1 -> 0/1 and Supermercado 1/2.
      await tester.tap(find.text('Papa'));
      await tester.pumpAndSettle();

      expect(find.text('Supermercado (1/2)'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);

      // Switch to Farmacia tab and confirm Ibuprofeno appears.
      await tester.tap(find.text('Farmacia (1/1)'));
      await tester.pumpAndSettle();
      expect(find.text('Ibuprofeno'), findsOneWidget);

      // Unmount ProviderScope and flush Drift's StreamQueryStore timer cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      dbClosed = true;
      await db.close();
    },
  );
}
