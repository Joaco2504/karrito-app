import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/theme/app_theme.dart';
import 'package:karrito_app/ui/widgets/karrito_bounce_button.dart';
import 'package:karrito_app/ui/widgets/karrito_toast.dart';

void main() {
  tearDown(KarritoToast.dismissCurrent);

  testWidgets(
    'KarritoToast renders success/error/info overlays and auto-dismisses cleanly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () => KarritoToast.show(
                      context,
                      message: 'Sincronización completa con tu cuenta.',
                      type: KarritoToastType.success,
                      duration: const Duration(milliseconds: 600),
                    ),
                    child: const Text('Mostrar éxito'),
                  ),
                  ElevatedButton(
                    onPressed: () => KarritoToast.show(
                      context,
                      message: 'No pudimos sincronizar ahora.',
                      type: KarritoToastType.error,
                      duration: const Duration(milliseconds: 600),
                    ),
                    child: const Text('Mostrar error'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar éxito'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Sincronización completa con tu cuenta.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Replacing an active toast immediately swaps to the new toast.
      await tester.tap(find.text('Mostrar error'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sincronización completa con tu cuenta.'), findsNothing);
      expect(find.text('No pudimos sincronizar ahora.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      // Auto-dismiss removes the overlay cleanly after duration + reverse anim.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.text('No pudimos sincronizar ahora.'), findsNothing);
    },
  );

  testWidgets('KarritoToast dismisses immediately on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => KarritoToast.show(
                context,
                message: 'Código copiado para compartir.',
                type: KarritoToastType.info,
                duration: const Duration(seconds: 10),
              ),
              child: const Text('Mostrar aviso'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mostrar aviso'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Código copiado para compartir.'), findsOneWidget);

    await tester.tap(find.text('Código copiado para compartir.'));
    await tester.pumpAndSettle();
    expect(find.text('Código copiado para compartir.'), findsNothing);
  });

  testWidgets('KarritoBounceButton delivers taps to child button', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: KarritoBounceButton(
              child: FilledButton(
                onPressed: () => tapped = true,
                child: const Text('Agregar'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets(
    'KarritoToast animates linear countdown bar from 100% to 0% and triggers exit at 0%',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => KarritoToast.show(
                  context,
                  message: 'Eliminamos 2 productos tachados.',
                  type: KarritoToastType.success,
                  duration: const Duration(milliseconds: 1000),
                ),
                child: const Text('Disparar toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disparar toast'));
      await tester.pump();

      final barFinder = find.byKey(KarritoToast.countdownBarKey);
      expect(barFinder, findsOneWidget);
      final initialValue =
          tester.widget<LinearProgressIndicator>(barFinder).value ?? 0.0;
      expect(initialValue, greaterThan(0.9));

      // Midway through visible duration, progress shrinks smoothly towards 0.
      await tester.pump(const Duration(milliseconds: 500));
      final midValue =
          tester.widget<LinearProgressIndicator>(barFinder).value ?? 1.0;
      expect(midValue, lessThan(0.65));
      expect(midValue, greaterThan(0.3));
      expect(find.text('Eliminamos 2 productos tachados.'), findsOneWidget);

      // Right after countdown reaches 0% + 240 ms exit animation, overlay is gone.
      await tester.pump(const Duration(milliseconds: 550));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Eliminamos 2 productos tachados.'), findsNothing);
    },
  );
}
