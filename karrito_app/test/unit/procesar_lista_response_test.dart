import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';

void main() {
  group('ProcesarListaResponse.fromJson', () {
    test('parses valid mixed items and quota payload', () {
      final json = <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'clean_name': 'papa',
            'quantity': 2,
            'unit': 'kg',
            'store_category': 'Supermercado',
            'aisle_name': 'Verdulería y Frutería',
          },
          <String, dynamic>{
            'clean_name': 'Tornillos autoperforantes',
            'quantity': 10,
            'unit': 'unidades',
            'store_category': 'Ferretería / Corralón',
            'aisle_name': 'Fijaciones',
          },
          <String, dynamic>{
            'clean_name': 'ibuprofeno 400mg',
            'quantity': 1,
            'unit': 'caja',
            'store_category': 'Farmacia',
            'aisle_name': 'Medicamentos',
          },
        ],
        'quota': <String, dynamic>{
          'plan_tier': 'free',
          'daily_ai_count': 1,
          'daily_ai_limit': 5,
          'remaining': 4,
        },
      };

      final parsed = ProcesarListaResponse.fromJson(json);

      expect(parsed.items, hasLength(3));
      expect(parsed.items[0].cleanName, 'Papa');
      expect(parsed.items[0].quantity, 2.0);
      expect(parsed.items[0].unit, 'kg');
      expect(parsed.items[0].storeCategory, 'Supermercado');
      expect(parsed.items[0].aisleName, 'Verdulería y Frutería');

      expect(parsed.items[1].unit, 'u');
      expect(parsed.items[1].storeCategory, 'Ferretería / Corralón');

      expect(parsed.items[2].cleanName, 'Ibuprofeno 400mg');
      expect(parsed.items[2].unit, 'caja');

      expect(parsed.quota?.planTier, 'free');
      expect(parsed.quota?.dailyAiCount, 1);
      expect(parsed.quota?.dailyAiLimit, 5);
      expect(parsed.quota?.remaining, 4);
    });

    test('normalizes unknown store and non-positive quantity safely', () {
      final parsed = ProcesarListaResponse.fromJson(<String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'clean_name': 'cuaderno rayado',
            'quantity': 0,
            'unit': '',
            'store_category': 'Libreria',
            'aisle_name': 'utiles escolares',
          },
          <String, dynamic>{
            'clean_name': 'linterna',
            'quantity': -3,
            'unit': null,
            'store_category': 'Desconocido',
            'aisle_name': 'Varios',
          },
        ],
      });

      expect(parsed.items[0].quantity, 1.0);
      expect(parsed.items[0].unit, 'u');
      expect(parsed.items[0].storeCategory, 'Librería / Papelería');
      expect(parsed.items[0].aisleName, 'Útiles Escolares');

      expect(parsed.items[1].quantity, 1.0);
      expect(parsed.items[1].storeCategory, 'Otros / Varios');
      expect(parsed.quota, isNull);
    });

    test('throws FormatException when items array is missing', () {
      expect(
        () => ProcesarListaResponse.fromJson(<String, dynamic>{}),
        throwsFormatException,
      );
    });
  });
}
