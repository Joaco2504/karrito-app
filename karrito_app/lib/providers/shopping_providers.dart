import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/store_hierarchy.dart';
import '../data/local/app_database.dart';
import '../data/repositories/shopping_repository.dart';
import '../data/services/ads_cascade_service.dart';
import '../data/services/ai_classifier_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/media_capture_service.dart';
import '../data/services/share_service.dart';
import '../data/services/subscription_service.dart';
import '../data/services/sync_service.dart';
import '../domain/services/currency_formatter.dart';
import 'core_providers.dart';

class AccountStatus {
  const AccountStatus({
    required this.isAnonymous,
    this.email,
    this.userId,
    this.photoUrl,
    this.displayName,
  });

  final bool isAnonymous;
  final String? email;
  final String? userId;
  final String? photoUrl;
  final String? displayName;
}

class AccountStatusNotifier extends Notifier<AccountStatus> {
  @override
  AccountStatus build() {
    final auth = ref.watch(authServiceProvider);
    final sub = auth.onAuthStateChange.listen((_) {
      refresh();
    });
    ref.onDispose(sub.cancel);

    return AccountStatus(
      isAnonymous: auth.isAnonymous,
      email: auth.currentEmail,
      userId: auth.currentUserId,
      photoUrl: auth.currentPhotoUrl,
      displayName: auth.currentDisplayName,
    );
  }

  void refresh() {
    final auth = ref.read(authServiceProvider);
    state = AccountStatus(
      isAnonymous: auth.isAnonymous,
      email: auth.currentEmail,
      userId: auth.currentUserId,
      photoUrl: auth.currentPhotoUrl,
      displayName: auth.currentDisplayName,
    );
  }
}

final accountStatusProvider =
    NotifierProvider<AccountStatusNotifier, AccountStatus>(
      AccountStatusNotifier.new,
    );

final preferencesProvider = StreamProvider<UserPreferencesEntity>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchPreferences();
});

final shoppingListsProvider = StreamProvider<List<ShoppingListEntity>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchLists();
});

final aisleOrderMapProvider = StreamProvider<Map<(String, String), int>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchAisleOrderMap();
});

final learnedItemsProvider = StreamProvider<List<LearnedItemEntity>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchLearnedItems();
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

final cachedAdsProvider = StreamProvider<List<CachedAdEntity>>((ref) {
  return ref.watch(adsCascadeServiceProvider).watchCachedAds();
});

final expenseHistoryProvider = StreamProvider<List<ExpenseHistoryEntity>>((
  ref,
) {
  return ref.watch(shoppingRepositoryProvider).watchExpenseHistory();
});

final effectivePlanTierProvider = Provider<String>((ref) {
  return ref.watch(preferencesProvider).value?.planTier ?? KarritoPlanTier.free;
});

final maxActiveListsForPlanProvider = Provider<int>((ref) {
  final prefs = ref.watch(preferencesProvider).value;
  final tier = prefs?.planTier ?? KarritoPlanTier.free;
  switch (tier) {
    case KarritoPlanTier.pro:
      return prefs?.proMaxLists ?? 999;
    case KarritoPlanTier.basic:
      return prefs?.basicMaxLists ?? 10;
    default:
      return prefs?.freeMaxLists ?? StoreHierarchy.maxActiveListsPhase2;
  }
});

final activeBannerDecisionProvider = Provider<AdCascadeDecision>((ref) {
  final prefs = ref.watch(preferencesProvider).value;
  final ads = ref.watch(cachedAdsProvider).value ?? const <CachedAdEntity>[];
  return AdsCascadeSelector.resolveBanner(
    cachedAds: ads,
    userCity: prefs?.city ?? StoreHierarchy.defaultCity,
    planTier: prefs?.planTier ?? KarritoPlanTier.free,
  );
});

final activeInterstitialDecisionProvider = Provider<AdCascadeDecision>((ref) {
  final prefs = ref.watch(preferencesProvider).value;
  final ads = ref.watch(cachedAdsProvider).value ?? const <CachedAdEntity>[];
  return AdsCascadeSelector.resolveInterstitial(
    cachedAds: ads,
    userCity: prefs?.city ?? StoreHierarchy.defaultCity,
    planTier: prefs?.planTier ?? KarritoPlanTier.free,
  );
});

class ShoppingUiState {
  const ShoppingUiState({
    this.isSubmitting = false,
    this.isReprocessing = false,
    this.isSyncing = false,
    this.isLinkingGoogle = false,
    this.isProcessingSubscription = false,
    this.isDeletingAccount = false,
    this.feedbackMessage,
    this.isError = false,
    this.messageVersion = 0,
    this.interstitialTriggerVersion = 0,
  });

  final bool isSubmitting;
  final bool isReprocessing;
  final bool isSyncing;
  final bool isLinkingGoogle;
  final bool isProcessingSubscription;
  final bool isDeletingAccount;
  final String? feedbackMessage;
  final bool isError;
  final int messageVersion;
  final int interstitialTriggerVersion;

  ShoppingUiState copyWith({
    bool? isSubmitting,
    bool? isReprocessing,
    bool? isSyncing,
    bool? isLinkingGoogle,
    bool? isProcessingSubscription,
    bool? isDeletingAccount,
    String? feedbackMessage,
    bool clearMessage = false,
    bool? isError,
    int? messageVersion,
    int? interstitialTriggerVersion,
  }) {
    return ShoppingUiState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isReprocessing: isReprocessing ?? this.isReprocessing,
      isSyncing: isSyncing ?? this.isSyncing,
      isLinkingGoogle: isLinkingGoogle ?? this.isLinkingGoogle,
      isProcessingSubscription:
          isProcessingSubscription ?? this.isProcessingSubscription,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      feedbackMessage: clearMessage
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      isError: isError ?? this.isError,
      messageVersion: messageVersion ?? this.messageVersion,
      interstitialTriggerVersion:
          interstitialTriggerVersion ?? this.interstitialTriggerVersion,
    );
  }
}

class ShoppingController extends Notifier<ShoppingUiState> {
  @override
  ShoppingUiState build() => const ShoppingUiState();

  ShoppingRepository get _repo => ref.read(shoppingRepositoryProvider);
  SyncService get _sync => ref.read(syncServiceProvider);

  void _emitFeedback(String message, {bool isError = false}) {
    state = state.copyWith(
      feedbackMessage: message,
      isError: isError,
      messageVersion: state.messageVersion + 1,
    );
  }

  void _triggerBackgroundSync() {
    if (!ref.read(isOnlineProvider)) return;
    unawaited(
      _sync.syncAll().catchError((Object error) {
        debugPrint('Karrito background sync ignored: $error');
      }),
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

      if (outcome.fromAiCount > 0) {
        state = state.copyWith(
          interstitialTriggerVersion: state.interstitialTriggerVersion + 1,
        );
      }

      _triggerBackgroundSync();
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

  Future<void> addFromFrequent(LearnedItemEntity learnedItem) async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return;
    await _repo.addLearnedItemToList(
      listId: activeList.id,
      learnedItem: learnedItem,
    );
    _triggerBackgroundSync();
  }

  Future<void> removeFromFrequent(LearnedItemEntity learnedItem) async {
    await _repo.removeLearnedItem(learnedItem.normalizedName);
    _triggerBackgroundSync();
  }

  Future<List<String>> getAislesForStore(String storeCategory) {
    return _repo.getAislesForStore(storeCategory);
  }

  Future<void> saveAisleOrder({
    required String storeCategory,
    required List<String> orderedAisles,
  }) async {
    await _repo.saveAisleOrder(
      storeCategory: storeCategory,
      orderedAisles: orderedAisles,
    );
    _emitFeedback(AppStrings.reorderSuccessNotice(storeCategory));
    _triggerBackgroundSync();
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
        _triggerBackgroundSync();
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

  Future<void> syncNow({bool userTriggered = false}) async {
    if (state.isSyncing) return;
    if (!ref.read(isOnlineProvider)) {
      if (userTriggered) {
        _emitFeedback(AppStrings.syncFailedError, isError: true);
      }
      return;
    }

    state = state.copyWith(isSyncing: true);
    try {
      await _sync.syncAll();
      ref.read(accountStatusProvider.notifier).refresh();
      if (userTriggered) {
        _emitFeedback(AppStrings.syncCompletedNotice);
      }
    } catch (error) {
      debugPrint('Karrito syncNow failed: $error');
      if (userTriggered) {
        final refCode = SupabaseSyncService.extractDiagnosticCode(error);
        _emitFeedback(AppStrings.syncFailedWithRef(refCode), isError: true);
      }
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<bool> linkGoogleAccount({
    bool completeOnboardingAfter = false,
    String? city,
  }) async {
    if (state.isLinkingGoogle) return false;
    if (!ref.read(isOnlineProvider)) {
      _emitFeedback(AppStrings.googleOfflineError, isError: true);
      return false;
    }

    state = state.copyWith(isLinkingGoogle: true);
    try {
      GoogleLinkOutcome? outcome;
      try {
        outcome = await ref.read(authServiceProvider).linkOrSignInWithGoogle();
        if (outcome == null) {
          return false;
        }

        // Immediately refresh UI so the linked account shows up even if sync fails.
        ref.read(accountStatusProvider.notifier).refresh();

        final currentPrefs = ref.read(preferencesProvider).value;
        final hasGooglePhoto =
            outcome.photoUrl != null && outcome.photoUrl!.trim().isNotEmpty;
        final currentChoice = currentPrefs?.avatarChoice ?? 'avatar_1';
        final nextAvatarChoice =
            hasGooglePhoto &&
                (currentChoice == 'avatar_1' || currentChoice == 'google')
            ? 'google'
            : null;

        await _repo.updatePreferences(
          city: city,
          onboardingCompleted: completeOnboardingAfter ? true : null,
          googlePhotoUrl: hasGooglePhoto ? outcome.photoUrl!.trim() : null,
          avatarChoice: nextAvatarChoice,
        );

        if (outcome.switchedUid) {
          final remapped = await _repo.prepareLocalDataForAccountSwitch(
            outcome.userId,
          );
          final currentActiveId = ref.read(activeListIdProvider);
          if (currentActiveId != null &&
              remapped.containsKey(currentActiveId)) {
            ref
                .read(activeListIdProvider.notifier)
                .select(remapped[currentActiveId]!);
          }
        }
      } on AuthActionException catch (e) {
        _emitFeedback(e.message, isError: true);
        return false;
      } catch (error) {
        debugPrint('Karrito linkGoogleAccount auth error: $error');
        _emitFeedback(AppStrings.googleTokenError, isError: true);
        return false;
      }

      try {
        await _sync.syncAll();
        ref.read(accountStatusProvider.notifier).refresh();
        _emitFeedback(AppStrings.googleLinkedNotice);
      } catch (syncError) {
        debugPrint(
          'Karrito linkGoogleAccount post-link sync deferred: $syncError',
        );
        ref.read(accountStatusProvider.notifier).refresh();
        _emitFeedback(AppStrings.googleLinkedSyncPendingNotice);
      }
      return true;
    } finally {
      state = state.copyWith(isLinkingGoogle: false);
    }
  }

  Future<void> signOutToGuest() async {
    if (state.isLinkingGoogle) return;
    state = state.copyWith(isLinkingGoogle: true);
    try {
      await ref.read(authServiceProvider).signOutToGuest();
      ref.read(accountStatusProvider.notifier).refresh();

      final newGuestUid = ref.read(authServiceProvider).currentUserId;
      final remapped = await _repo.prepareLocalDataForAccountSwitch(
        newGuestUid,
      );
      final currentActiveId = ref.read(activeListIdProvider);
      if (currentActiveId != null && remapped.containsKey(currentActiveId)) {
        ref
            .read(activeListIdProvider.notifier)
            .select(remapped[currentActiveId]!);
      }

      final currentChoice =
          ref.read(preferencesProvider).value?.avatarChoice ?? 'avatar_1';
      await _repo.updatePreferences(
        clearGooglePhotoUrl: true,
        avatarChoice: currentChoice == 'google' ? 'avatar_1' : null,
      );

      _emitFeedback(AppStrings.signedOutNotice);
    } catch (error) {
      debugPrint('Karrito signOutToGuest warning: $error');
      _emitFeedback(AppStrings.signedOutNotice);
    } finally {
      state = state.copyWith(isLinkingGoogle: false);
    }
  }

  Future<LiveShareOutcome?> enableLiveShareForActiveList() async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return null;

    if (!ref.read(isOnlineProvider)) {
      _emitFeedback(AppStrings.liveOfflineError, isError: true);
      return null;
    }

    try {
      final outcome = await _sync.enableLiveShare(activeList);
      if (!outcome.requiresPro) {
        unawaited(
          ref
              .read(pushNotificationServiceProvider)
              .requestPermissionAndRegisterToken(
                ref.read(authServiceProvider).currentUserId,
              ),
        );
      }
      return outcome;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return null;
    } catch (_) {
      _emitFeedback(AppStrings.syncFailedError, isError: true);
      return null;
    }
  }

  Future<String?> joinSharedListByCode(String code) async {
    if (!ref.read(isOnlineProvider)) {
      return AppStrings.liveOfflineError;
    }

    try {
      final result = await _sync.joinSharedListByCode(code);
      ref.read(activeListIdProvider.notifier).select(result.listId);
      unawaited(
        ref
            .read(pushNotificationServiceProvider)
            .requestPermissionAndRegisterToken(
              ref.read(authServiceProvider).currentUserId,
            ),
      );
      _emitFeedback(AppStrings.liveJoinedNotice(result.title));
      return null;
    } on ShoppingActionException catch (e) {
      return e.message;
    } catch (_) {
      return AppStrings.syncFailedError;
    }
  }

  Future<void> toggleItemChecked(ShoppingItemEntity item) async {
    final willCheck = !item.isChecked;
    if (willCheck) {
      final prefs = ref.read(preferencesProvider).value;
      final soundEnabled = prefs?.soundEnabled ?? true;
      final vibrationEnabled = prefs?.vibrationEnabled ?? true;
      if (soundEnabled || vibrationEnabled) {
        unawaited(
          ref
              .read(soundFeedbackServiceProvider)
              .playItemCheckedFeedback(
                playSound: soundEnabled,
                triggerVibration: vibrationEnabled,
              ),
        );
      }
    }
    await _repo.toggleItemChecked(item);
    _triggerBackgroundSync();
  }

  Future<bool> updateItem({
    required ShoppingItemEntity original,
    required String cleanName,
    required double quantity,
    required String unit,
    required String storeCategory,
    required String aisleName,
    double? price,
    bool updatePrice = false,
  }) async {
    try {
      await _repo.updateItemAndLearn(
        original: original,
        cleanName: cleanName,
        quantity: quantity,
        unit: unit,
        storeCategory: storeCategory,
        aisleName: aisleName,
        price: price,
        updatePrice: updatePrice,
      );
      _triggerBackgroundSync();
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<void> updateItemPrice(ShoppingItemEntity item, double? price) async {
    await _repo.updateItemPrice(item: item, price: price);
  }

  Future<bool> saveShoppingExpensesForActiveList() async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return false;
    final items = ref.read(activeListItemsProvider).value ?? const [];

    try {
      final result = await _repo.recordShoppingExpenses(
        list: activeList,
        items: items,
      );
      _emitFeedback(
        AppStrings.cartExpenseSavedNotice(
          CurrencyFormatter.formatArs(result.totalRecorded),
        ),
      );
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<void> deleteExpenseRecord(String id) async {
    await _repo.deleteExpenseRecord(id);
  }

  Future<void> setMonthlyBudget(double? budgetArs) async {
    if (budgetArs == null || budgetArs <= 0) {
      await _repo.updatePreferences(clearMonthlyBudget: true);
    } else {
      await _repo.updatePreferences(monthlyBudgetArs: budgetArs);
    }
  }

  Future<bool> addItemsFromVoicePayload(EncodedVoicePayload payload) async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null || state.isSubmitting) return false;
    if (!ref.read(isOnlineProvider)) {
      _emitFeedback(AppStrings.proMediaOfflineError, isError: true);
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearMessage: true);
    try {
      final outcome = await _repo.addItemsFromAudio(
        listId: activeList.id,
        audioBase64: payload.base64Data,
        mimeType: payload.mimeType,
      );
      if (outcome.addedCount > 0) {
        _emitFeedback(AppStrings.addedItemsNotice(outcome.addedCount));
      } else {
        _emitFeedback(
          'No detectamos productos claros en ese audio. Probá dictar más pausado.',
          isError: true,
        );
      }
      _triggerBackgroundSync();
      return outcome.addedCount > 0;
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

  Future<bool> addItemsFromImagePayload(EncodedImagePayload payload) async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null || state.isSubmitting) return false;
    if (!ref.read(isOnlineProvider)) {
      _emitFeedback(AppStrings.proMediaOfflineError, isError: true);
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearMessage: true);
    try {
      final outcome = await _repo.addItemsFromImage(
        listId: activeList.id,
        imageBase64: payload.base64Data,
        mimeType: payload.mimeType,
      );
      if (outcome.addedCount > 0) {
        _emitFeedback(AppStrings.addedItemsNotice(outcome.addedCount));
      } else {
        _emitFeedback(
          'No pudimos leer productos en esa foto. Probá con mejor luz o acercando la cámara.',
          isError: true,
        );
      }
      _triggerBackgroundSync();
      return outcome.addedCount > 0;
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

  Future<bool> importRecipeOrProjectText(String rawText) async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearMessage: true);
    try {
      final outcome = await _repo.importRecipeOrProject(
        listId: activeList.id,
        rawText: rawText,
        isOnline: ref.read(isOnlineProvider),
      );
      if (outcome.addedCount > 0) {
        _emitFeedback(AppStrings.addedItemsNotice(outcome.addedCount));
      }
      _triggerBackgroundSync();
      return outcome.addedCount > 0;
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

  Future<bool> purchaseMonthlyPlan(String targetTier) async {
    if (state.isProcessingSubscription) return false;
    state = state.copyWith(isProcessingSubscription: true);
    try {
      final outcome = await ref
          .read(subscriptionServiceProvider)
          .purchaseMonthlyPlan(targetTier);
      if (outcome.succeeded) {
        await _repo.updatePreferences(planTier: outcome.planTier);
        unawaited(_sync.refreshAccountPlanAndConfig());
      }
      if (!outcome.cancelled && outcome.message != null) {
        _emitFeedback(outcome.message!, isError: !outcome.succeeded);
      }
      return outcome.succeeded;
    } finally {
      state = state.copyWith(isProcessingSubscription: false);
    }
  }

  Future<void> restorePurchases() async {
    if (state.isProcessingSubscription) return;
    state = state.copyWith(isProcessingSubscription: true);
    try {
      final outcome = await ref
          .read(subscriptionServiceProvider)
          .restorePurchases();
      if (outcome.succeeded) {
        await _repo.updatePreferences(planTier: outcome.planTier);
        unawaited(_sync.refreshAccountPlanAndConfig());
      }
      if (outcome.message != null) {
        _emitFeedback(outcome.message!, isError: !outcome.succeeded);
      }
    } finally {
      state = state.copyWith(isProcessingSubscription: false);
    }
  }

  Future<void> refreshPlanAndAds() async {
    if (!ref.read(isOnlineProvider)) return;
    final city =
        ref.read(preferencesProvider).value?.city ?? StoreHierarchy.defaultCity;
    final subService = ref.read(subscriptionServiceProvider);
    final auth = ref.read(authServiceProvider);

    await subService.identifyUser(auth.currentUserId);
    final rcTier = await subService.fetchActivePlanTier();
    if (rcTier != null) {
      await _repo.updatePreferences(planTier: rcTier);
    }
    await _sync.refreshAccountPlanAndConfig();
    await ref.read(adsCascadeServiceProvider).refreshLocalAds(city);
  }

  Future<bool> deleteAccountAndWipeData() async {
    if (state.isDeletingAccount) return false;
    if (!ref.read(isOnlineProvider)) {
      _emitFeedback(
        'Necesitás conexión a internet para borrar tu cuenta en la nube. Probá cuando vuelva la señal.',
        isError: true,
      );
      return false;
    }

    state = state.copyWith(isDeletingAccount: true);
    try {
      await ref.read(authServiceProvider).deleteAccountPermanently();
      final freshListId = await _repo.wipeAllLocalDataForAccountDeletion();
      ref.read(activeListIdProvider.notifier).select(freshListId);
      ref.read(accountStatusProvider.notifier).refresh();
      _emitFeedback(AppStrings.accountDeletedNotice);
      return true;
    } on AuthActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    } catch (_) {
      _emitFeedback(
        'No pudimos eliminar tu cuenta ahora. Probá de nuevo en unos segundos.',
        isError: true,
      );
      return false;
    } finally {
      state = state.copyWith(isDeletingAccount: false);
    }
  }

  void triggerInterstitialForListCompletion() {
    state = state.copyWith(
      interstitialTriggerVersion: state.interstitialTriggerVersion + 1,
    );
  }

  Future<void> deleteItem(ShoppingItemEntity item) async {
    await _repo.deleteItem(item);
    _triggerBackgroundSync();
  }

  Future<bool> createList(String title) async {
    try {
      final limit = ref.read(maxActiveListsForPlanProvider);
      final newId = await _repo.createList(
        title,
        ownerId: ref.read(authServiceProvider).currentUserId,
        maxActiveLists: limit,
      );
      ref.read(activeListIdProvider.notifier).select(newId);
      _triggerBackgroundSync();
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<bool> renameList(String listId, String title) async {
    try {
      await _repo.renameList(listId, title);
      _triggerBackgroundSync();
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<bool> deleteList(String listId) async {
    try {
      await _repo.deleteList(listId);
      _triggerBackgroundSync();
      return true;
    } on ShoppingActionException catch (e) {
      _emitFeedback(e.message, isError: true);
      return false;
    }
  }

  Future<void> setCity(String city) async {
    await _repo.updatePreferences(city: city);
    _triggerBackgroundSync();
    if (ref.read(isOnlineProvider)) {
      unawaited(ref.read(adsCascadeServiceProvider).refreshLocalAds(city));
    }
  }

  Future<void> setThemeMode(String themeMode) async {
    await _repo.updatePreferences(themeMode: themeMode);
  }

  Future<void> completeOnboarding({required String city}) async {
    await _repo.updatePreferences(city: city, onboardingCompleted: true);
    _triggerBackgroundSync();
  }

  Future<void> reopenOnboarding() async {
    await _repo.updatePreferences(onboardingCompleted: false);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _repo.updatePreferences(soundEnabled: enabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await _repo.updatePreferences(vibrationEnabled: enabled);
  }

  Future<void> setAvatarChoice(String avatarChoice) async {
    await _repo.updatePreferences(avatarChoice: avatarChoice);
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

  Future<void> shareActiveListAsText() async {
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
