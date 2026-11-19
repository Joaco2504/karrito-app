import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../data/local/app_database.dart';
import '../data/repositories/shopping_repository.dart';
import '../data/services/ai_classifier_service.dart';
import '../data/services/share_service.dart';
import 'core_providers.dart';

final preferencesProvider = StreamProvider<UserPreferencesEntity>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchPreferences();
});

final shoppingListsProvider = StreamProvider<List<ShoppingListEntity>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchLists();
});

final aisleOrderMapProvider = StreamProvider<Map<(String, String), int>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchAisleOrderMap();
});

class ActiveListIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String listId) {
    state = listId;
  }
}

final activeListIdProvider = NotifierProvider<ActiveListIdNotifier, String?>(
  ActiveListIdNotifier.new,
);

final activeListProvider = Provider<ShoppingListEntity?>((ref) {
  final lists = ref.watch(shoppingListsProvider).value;
  if (lists == null || lists.isEmpty) {
    return null;
  }
  final selectedId = ref.watch(activeListIdProvider);
  if (selectedId == null) {
    return lists.first;
  }
  for (final list in lists) {
    if (list.id == selectedId) {
      return list;
    }
  }
  return lists.first;
});

final activeListItemsProvider = StreamProvider<List<ShoppingItemEntity>>((ref) {
  final activeList = ref.watch(activeListProvider);
  if (activeList == null) {
    return Stream<List<ShoppingItemEntity>>.value(const <ShoppingItemEntity>[]);
  }
  return ref.watch(shoppingRepositoryProvider).watchItemsForList(activeList.id);
});

final activeListPendingAiCountProvider = StreamProvider<int>((ref) {
  final activeList = ref.watch(activeListProvider);
  if (activeList == null) {
    return Stream<int>.value(0);
  }
  return ref
      .watch(shoppingRepositoryProvider)
      .watchPendingAiCount(activeList.id);
});

class ShoppingUiState {
  const ShoppingUiState({
    this.isSubmitting = false,
    this.isReprocessing = false,
    this.feedbackMessage,
    this.isError = false,
    this.messageVersion = 0,
  });

  final bool isSubmitting;
  final bool isReprocessing;
  final String? feedbackMessage;
  final bool isError;
  final int messageVersion;

  ShoppingUiState copyWith({
    bool? isSubmitting,
    bool? isReprocessing,
    String? feedbackMessage,
    bool clearMessage = false,
    bool? isError,
    int? messageVersion,
  }) {
    return ShoppingUiState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isReprocessing: isReprocessing ?? this.isReprocessing,
      feedbackMessage: clearMessage
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      isError: isError ?? this.isError,
      messageVersion: messageVersion ?? this.messageVersion,
    );
  }
}

class ShoppingController extends Notifier<ShoppingUiState> {
  @override
  ShoppingUiState build() => const ShoppingUiState();

  ShoppingRepository get _repo => ref.read(shoppingRepositoryProvider);

  void _emitFeedback(String message, {bool isError = false}) {
    state = state.copyWith(
      feedbackMessage: message,
      isError: isError,
      messageVersion: state.messageVersion + 1,
    );
  }

  /// Adds items from user text. Returns `true` when input can be cleared
  /// (saved locally, via AI, or offline), and `false` on validation/quota errors.
  Future<bool> addItems(String rawText) async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return false;
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearMessage: true);
    try {
      final isOnline = ref.read(isOnlineProvider);
      final outcome = await _repo.addItemsFromInput(
        listId: activeList.id,
        rawInput: rawText,
        isOnline: isOnline,
      );

      if (outcome.savedOfflineCount > 0 && outcome.fromLocalCount == 0) {
        _emitFeedback(AppStrings.savedOfflineNotice);
      } else if (outcome.fromLocalCount == outcome.addedCount &&
          outcome.addedCount > 0) {
        _emitFeedback(
          AppStrings.addedItemsNotice(
            outcome.addedCount,
            fromLocal: outcome.fromLocalCount,
          ),
        );
      } else if (outcome.addedCount > 0) {
        _emitFeedback(AppStrings.addedItemsNotice(outcome.addedCount));
      }
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    } on AiClassifierException catch (e) {
      _emitFeedback(e.userMessage, isError: true);
      return false;
    } catch (_) {
      _emitFeedback(AppStrings.genericProcessingError, isError: true);
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> reprocessPendingAi({bool userTriggered = false}) async {
    if (state.isReprocessing) return;
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      if (userTriggered) {
        _emitFeedback(AppStrings.networkFallbackError, isError: true);
      }
      return;
    }

    state = state.copyWith(isReprocessing: true);
    try {
      final resolved = await _repo.reprocessPendingAiItems();
      if (resolved > 0) {
        _emitFeedback(AppStrings.reprocessSuccessNotice);
      }
    } on AiClassifierException catch (e) {
      if (userTriggered) {
        _emitFeedback(e.userMessage, isError: true);
      }
    } catch (_) {
      if (userTriggered) {
        _emitFeedback(AppStrings.genericProcessingError, isError: true);
      }
    } finally {
      state = state.copyWith(isReprocessing: false);
    }
  }

  Future<void> toggleItemChecked(ShoppingItemEntity item) async {
    await _repo.toggleItemChecked(item);
  }

  Future<bool> updateItem({
    required ShoppingItemEntity original,
    required String cleanName,
    required double quantity,
    required String unit,
    required String storeCategory,
    required String aisleName,
  }) async {
    try {
      await _repo.updateItemAndLearn(
        original: original,
        cleanName: cleanName,
        quantity: quantity,
        unit: unit,
        storeCategory: storeCategory,
        aisleName: aisleName,
      );
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<void> deleteItem(ShoppingItemEntity item) async {
    await _repo.deleteItem(item);
  }

  Future<bool> createList(String title) async {
    try {
      final newId = await _repo.createList(title);
      ref.read(activeListIdProvider.notifier).select(newId);
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<bool> renameList(String listId, String title) async {
    try {
      await _repo.renameList(listId, title);
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<bool> deleteList(String listId) async {
    try {
      await _repo.deleteList(listId);
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<void> setCity(String city) async {
    await _repo.updatePreferences(city: city);
  }

  Future<void> setThemeMode(String themeMode) async {
    await _repo.updatePreferences(themeMode: themeMode);
  }

  Future<void> completeOnboarding({required String city}) async {
    await _repo.updatePreferences(city: city, onboardingCompleted: true);
  }

  Future<void> reopenOnboarding() async {
    await _repo.updatePreferences(onboardingCompleted: false);
  }

  Future<void> setKeepScreenOn(bool enabled, {bool notify = false}) async {
    await _repo.updatePreferences(keepScreenOn: enabled);
    await ref.read(wakelockServiceProvider).setEnabled(enabled);
    if (notify) {
      _emitFeedback(
        enabled
            ? AppStrings.wakelockEnabledNotice
            : AppStrings.wakelockDisabledNotice,
      );
    }
  }

  Future<void> shareActiveList() async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return;
    final items = ref.read(activeListItemsProvider).value ?? const [];
    final aisleOrders = await _repo.getAisleOrderMap();

    final shared = await ShareService.shareShoppingList(
      listTitle: activeList.title,
      items: items,
      aisleOrders: aisleOrders,
    );
    if (!shared) {
      _emitFeedback(AppStrings.shareEmptyListError, isError: true);
    }
  }
}

final shoppingControllerProvider =
    NotifierProvider<ShoppingController, ShoppingUiState>(
      ShoppingController.new,
    );
