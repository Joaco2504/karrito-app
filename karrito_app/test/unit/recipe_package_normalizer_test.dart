import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/repositories/shopping_repository.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/domain/services/recipe_package_normalizer.dart';

class _RecipeAiFake implements AiClassifierService {
  bool lastTextWasRecipe = false;
  bool lastImageWasRecipe = false;
  String? lastImageHint;

  @override
  Future<ProcesarListaResponse> classifyText(
    String text, {
    bool isRecipe = false,
  }) async {
    lastTextWasRecipe = isRecipe;
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
        ),
        ProcessedAiItem(
          cleanName: 'Huevos',
          quantity: 4,
          unit: 'u',
          storeCategory: 'Supermercado',
          aisleName: 'Lácteos y Refrigerados',
        ),
      ],
    );
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
    bool isRecipe = false,
    String? textHint,
  }) async {
    lastImageWasRecipe = isRecipe;
    lastImageHint = textHint;
    return const ProcesarListaResponse(
      items: <ProcessedAiItem>[
        ProcessedAiItem(
          cleanName: 'Leche entera',
          quantity: 500,
          unit: 'ml',
          storeCategory: 'Supermercado',
          aisleName: 'Lácteos y Refrigerados',
          recipeNote: '500 ml para el flan',
        ),
      ],
    );
  }
}

void main() {
  group('RecipePackageNormalizer', () {
    test(
      'normalizes Argentine culinary micro-quantities into retail packages',
      () {
        final sugar = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Azúcar',
            quantity: 100,
            unit: 'g',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
          ),
        );
        expect(sugar.quantity, 1);
        expect(sugar.unit, 'kg');
        expect(sugar.recipeNote, '100 g para la receta');

        final oil = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Aceite de girasol',
            quantity: 150,
            unit: 'ml',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
          ),
        );
        expect(oil.quantity, 1);
        expect(oil.unit, 'l');
        expect(oil.recipeNote, '150 ml para la receta');

        final milk = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Leche entera',
            quantity: 250,
            unit: 'ml',
            storeCategory: 'Supermercado',
            aisleName: 'Lácteos y Refrigerados',
          ),
        );
        expect(milk.quantity, 1);
        expect(milk.unit, 'l');
        expect(milk.recipeNote, '250 ml para la receta');

        final eggs = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Huevos',
            quantity: 4,
            unit: 'u',
            storeCategory: 'Supermercado',
            aisleName: 'Lácteos y Refrigerados',
          ),
        );
        expect(eggs.quantity, 6);
        expect(eggs.unit, 'u');
        expect(eggs.recipeNote, '4 u para la receta');

        final butter = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Manteca',
            quantity: 50,
            unit: 'g',
            storeCategory: 'Supermercado',
            aisleName: 'Lácteos y Refrigerados',
          ),
        );
        expect(butter.quantity, 100);
        expect(butter.unit, 'g');
        expect(butter.recipeNote, '50 g para la receta');

        final salt = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Sal fina',
            quantity: 10,
            unit: 'g',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
          ),
        );
        expect(salt.quantity, 500);
        expect(salt.unit, 'g');
        expect(salt.recipeNote, '10 g para la receta');

        final vanilla = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Esencia de vainilla',
            quantity: 1,
            unit: 'cdita',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
          ),
        );
        expect(vanilla.quantity, 1);
        expect(vanilla.unit, 'u');
        expect(vanilla.recipeNote, '1 cdita para la receta');
      },
    );

    test(
      'preserves Gemini recipeNote and leaves full commercial packages untouched',
      () {
        final alreadyCommercial = RecipePackageNormalizer.normalizeSingleItem(
          const ProcessedAiItem(
            cleanName: 'Azúcar',
            quantity: 1,
            unit: 'kg',
            storeCategory: 'Supermercado',
            aisleName: 'Almacén',
            recipeNote: '100 g para el flan',
          ),
        );
        expect(alreadyCommercial.quantity, 1);
        expect(alreadyCommercial.unit, 'kg');
        expect(alreadyCommercial.recipeNote, '100 g para el flan');
      },
    );

    test(
      'encodes and extracts recipe note via raw_text without schema change',
      () {
        final encoded = RecipePackageNormalizer.encodeRawText(
          fallbackRawText: 'Flan casero para 6 personas',
          recipeNote: '100 g para el flan',
        );
        expect(encoded, 'Receta: 100 g para el flan');
        expect(
          RecipePackageNormalizer.extractRecipeNote(encoded),
          '100 g para el flan',
        );
        expect(
          RecipePackageNormalizer.extractRecipeNote('2 kg papa, leche'),
          isNull,
        );
      },
    );

    test('ProcessedAiItem.fromJson reads recipe_note field', () {
      final parsed = ProcessedAiItem.fromJson(<String, dynamic>{
        'clean_name': 'Azúcar',
        'quantity': 1,
        'unit': 'kg',
        'store_category': 'Supermercado',
        'aisle_name': 'Almacén',
        'recipe_note': '100 g para el flan',
      });
      expect(parsed.recipeNote, '100 g para el flan');
    });

    test(
      'ShoppingRepository previews recipes (text & photo) and saves only selected items',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final fakeAi = _RecipeAiFake();
        final repo = ShoppingRepository(db: db, aiClassifier: fakeAi);
        final lists = await repo.watchLists().first;
        final listId = lists.first.id;

        final preview = await repo.previewRecipeFromText(
          rawText: 'Flan casero para 6 personas',
          isOnline: true,
        );
        expect(fakeAi.lastTextWasRecipe, isTrue);
        expect(preview, hasLength(3));
        expect(preview[0].quantity, 1);
        expect(preview[0].unit, 'kg');
        expect(preview[0].recipeNote, '100 g para el flan');
        expect(preview[1].quantity, 1);
        expect(preview[1].unit, 'l');
        expect(preview[2].quantity, 6);
        expect(preview[2].unit, 'u');

        final photoPreview = await repo.previewRecipeFromImage(
          imageBase64: 'ZmFrZQ==',
          mimeType: 'image/jpeg',
          dishHint: 'Flan casero',
          isOnline: true,
        );
        expect(fakeAi.lastImageWasRecipe, isTrue);
        expect(fakeAi.lastImageHint, 'Flan casero');
        expect(photoPreview.single.quantity, 1);
        expect(photoPreview.single.unit, 'l');

        // Save ONLY 2 of the 3 previewed ingredients (skipping Aceite).
        final savedCount = await repo.addSelectedProcessedItems(
          listId: listId,
          items: <ProcessedAiItem>[preview[0], preview[2]],
          fallbackRawText: 'Flan casero para 6 personas',
        );
        expect(savedCount, 2);

        final savedItems = await db.select(db.localItems).get();
        expect(savedItems, hasLength(2));
        final sugarSaved = savedItems.firstWhere(
          (i) => i.cleanName == 'Azúcar',
        );
        expect(sugarSaved.quantity, 1);
        expect(sugarSaved.unit, 'kg');
        expect(
          RecipePackageNormalizer.extractRecipeNote(sugarSaved.rawText),
          '100 g para el flan',
        );
      },
    );
  });
}
