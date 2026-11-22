import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/constants/store_hierarchy.dart';
import 'package:karrito_app/core/theme/app_theme.dart';
import 'package:karrito_app/ui/widgets/karrito_asset_icon.dart';

void main() {
  group('StoreHierarchy Phase 3.5 expansion', () {
    test('contains all 11 canonical stores with Otros / Varios last', () {
      expect(StoreHierarchy.storeOrder, hasLength(11));
      expect(StoreHierarchy.storeOrder.last, StoreHierarchy.fallbackStore);
      expect(
        StoreHierarchy.storeOrder,
        containsAll(<String>[
          'Bazar y Hogar',
          'Indumentaria y Calzado',
          'Juguetería y Regalería',
          'Mascotas y Veterinaria',
          'Electrónica y Celulares',
        ]),
      );
    });

    test('contains exact aisles for all 5 new rubros', () {
      expect(StoreHierarchy.storeAisles['Bazar y Hogar'], <String>[
        'Cocina y Vajilla',
        'Herméticos y Organización',
        'Termos y Mate',
        'Decoración y Textil Hogar',
      ]);
      expect(StoreHierarchy.storeAisles['Indumentaria y Calzado'], <String>[
        'Ropa Cotidiana',
        'Ropa Interior y Medias',
        'Calzado',
        'Accesorios',
      ]);
      expect(StoreHierarchy.storeAisles['Juguetería y Regalería'], <String>[
        'Juguetes',
        'Juegos de Mesa',
        'Cotillón y Envoltorios',
      ]);
      expect(StoreHierarchy.storeAisles['Mascotas y Veterinaria'], <String>[
        'Alimento Balanceado',
        'Higiene y Piedritas',
        'Salud y Pipetas',
        'Accesorios Mascotas',
      ]);
      expect(StoreHierarchy.storeAisles['Electrónica y Celulares'], <String>[
        'Cargadores y Cables',
        'Pilas y Baterías',
        'Audio y Accesorios',
        'Informática Básica',
      ]);
    });

    test('normalizeStore resolves fuzzy names for new rubros', () {
      expect(StoreHierarchy.normalizeStore('bazar'), 'Bazar y Hogar');
      expect(
        StoreHierarchy.normalizeStore('indumentaria'),
        'Indumentaria y Calzado',
      );
      expect(
        StoreHierarchy.normalizeStore('Jugueteria'),
        'Juguetería y Regalería',
      );
      expect(
        StoreHierarchy.normalizeStore('veterinaria'),
        'Mascotas y Veterinaria',
      );
      expect(
        StoreHierarchy.normalizeStore('electronica y celulares'),
        'Electrónica y Celulares',
      );
    });
  });

  group('KarritoAssetIcon and KarritoBrandLogo', () {
    tearDown(KarritoAssetRegistry.resetForTest);

    test('slugify strips Spanish accents and punctuation cleanly', () {
      expect(
        KarritoAssetIcon.slugify('Ferretería / Corralón'),
        'ferreteria_corralon',
      );
      expect(
        KarritoAssetIcon.slugify('Verdulería y Frutería'),
        'verduleria_y_fruteria',
      );
      expect(
        KarritoAssetIcon.slugify('Electrónica y Celulares'),
        'electronica_y_celulares',
      );
      expect(
        KarritoAssetIcon.slugify('Cotillón y Envoltorios'),
        'cotillon_y_envoltorios',
      );
      expect(
        KarritoAssetIcon.assetPathFor(
          KarritoAssetIconKind.store,
          'Bazar y Hogar',
        ),
        'assets/icons/stores/bazar_y_hogar.png',
      );
      expect(
        KarritoAssetIcon.assetPathFor(
          KarritoAssetIconKind.aisle,
          'Termos y Mate',
        ),
        'assets/icons/aisles/termos_y_mate.png',
      );
    });

    testWidgets(
      'falls back cleanly to Material vector icons and wordmark when custom PNGs are missing',
      (WidgetTester tester) async {
        KarritoAssetRegistry.setKnownAssetsForTest(const <String>{});

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Column(
                children: [
                  KarritoBrandLogo(),
                  KarritoAssetIcon.store('Bazar y Hogar'),
                  KarritoAssetIcon.aisle('Termos y Mate'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Karrito'), findsOneWidget);
        expect(find.byIcon(Icons.home_rounded), findsOneWidget);
        expect(find.byIcon(Icons.local_cafe_rounded), findsOneWidget);
      },
    );
  });
}
