import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/domain/services/item_text_parser.dart';

void main() {
  group('ItemTextParser.normalizeProductName', () {
    test('lowercases, trims, strips accents, and collapses spaces', () {
      expect(
        ItemTextParser.normalizeProductName('  Jabón   Líquido  '),
        'jabon liquido',
      );
      expect(ItemTextParser.normalizeProductName('Azúcar'), 'azucar');
      expect(ItemTextParser.normalizeProductName('Fijación,'), 'fijacion');
    });

    test('preserves Spanish ñ while removing vowel tildes', () {
      expect(ItemTextParser.normalizeProductName('Pañuelos'), 'pañuelos');
    });
  });

  group('ItemTextParser.parseInput', () {
    test(
      'parses comma and newline separated items with quantities and units',
      () {
        final result = ItemTextParser.parseInput(
          '2 kg de papa, 1.5 l leche\n10 tornillos\nmedio kilo de carne',
        );

        expect(result.isComplex, isFalse);
        expect(result.candidates, hasLength(4));

        expect(result.candidates[0].cleanName, 'Papa');
        expect(result.candidates[0].normalizedName, 'papa');
        expect(result.candidates[0].quantity, 2.0);
        expect(result.candidates[0].unit, 'kg');

        expect(result.candidates[1].cleanName, 'Leche');
        expect(result.candidates[1].quantity, 1.5);
        expect(result.candidates[1].unit, 'l');

        expect(result.candidates[2].cleanName, 'Tornillos');
        expect(result.candidates[2].quantity, 10.0);
        expect(result.candidates[2].unit, 'u');

        expect(result.candidates[3].cleanName, 'Carne');
        expect(result.candidates[3].quantity, 0.5);
        expect(result.candidates[3].unit, 'kg');
      },
    );

    test('splits list commas without breaking decimal commas', () {
      final result = ItemTextParser.parseInput(
        '1,5 kg de papa, 0,5 l de aceite',
      );

      expect(result.isComplex, isFalse);
      expect(result.candidates, hasLength(2));
      expect(result.candidates[0].quantity, 1.5);
      expect(result.candidates[0].unit, 'kg');
      expect(result.candidates[0].cleanName, 'Papa');
      expect(result.candidates[1].quantity, 0.5);
      expect(result.candidates[1].unit, 'l');
      expect(result.candidates[1].cleanName, 'Aceite');
    });

    test('handles bullets, fractions, and half dozen', () {
      final result = ItemTextParser.parseInput(
        '- 1/2 kg de yerba\n• media docena de facturas',
      );

      expect(result.isComplex, isFalse);
      expect(result.candidates, hasLength(2));
      expect(result.candidates[0].quantity, 0.5);
      expect(result.candidates[0].unit, 'kg');
      expect(result.candidates[0].cleanName, 'Yerba');

      expect(result.candidates[1].quantity, 0.5);
      expect(result.candidates[1].unit, 'docena');
      expect(result.candidates[1].cleanName, 'Facturas');
    });

    test('keeps simple noun phrases with para eligible for local cache', () {
      final result = ItemTextParser.parseInput(
        '2 cajas de tornillos para madera',
      );

      expect(result.isComplex, isFalse);
      expect(result.candidates, hasLength(1));
      expect(result.candidates[0].normalizedName, 'tornillos para madera');
      expect(result.candidates[0].quantity, 2.0);
      expect(result.candidates[0].unit, 'caja');
    });

    test('marks conversational prose and conjunctions as complex', () {
      expect(
        ItemTextParser.parseInput(
          'necesito algo para destapar la bacha',
        ).isComplex,
        isTrue,
      );
      expect(ItemTextParser.parseInput('papa y cebolla').isComplex, isTrue);
    });
  });
}
