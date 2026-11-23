import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/services/ads_cascade_service.dart';
import '../../data/services/media_capture_service.dart';
import '../../data/services/subscription_service.dart';
import '../../domain/services/currency_formatter.dart';
import '../../providers/core_providers.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/ads_banner_bar.dart';
import '../widgets/aisle_reorder_sheet.dart';
import '../widgets/aisle_section_card.dart';
import '../widgets/edit_item_sheet.dart';
import '../widgets/frequent_items_sheet.dart';
import '../widgets/karrito_asset_icon.dart';
import '../widgets/karrito_bounce_button.dart';
import '../widgets/karrito_skeleton_loader.dart';
import '../widgets/karrito_toast.dart';
import '../widgets/list_selector_sheet.dart';
import '../widgets/live_share_sheets.dart';
import '../widgets/local_interstitial_dialog.dart';
import '../widgets/pro_features_sheets.dart';
import '../widgets/profile_avatar_widget.dart';
import '../widgets/profile_menu_sheet.dart';
import 'monthly_expenses_screen.dart';
import 'plans_screen.dart';
import 'settings_screen.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final Set<String> _collapsedAisleKeys = <String>{};
  String? _selectedStore;
  bool _showingInterstitial = false;

  bool get _isPro => KarritoPlanTier.isPro(ref.read(effectivePlanTierProvider));

  Future<void> _maybeShowInterstitial() async {
    if (_showingInterstitial || !mounted) return;
    final decision = ref.read(activeInterstitialDecisionProvider);
    if (decision.source == AdSlotSource.none) return;

    _showingInterstitial = true;
    try {
      if (decision.source == AdSlotSource.localAd && decision.localAd != null) {
        final ad = decision.localAd!;
        final adsService = ref.read(adsCascadeServiceProvider);
        await LocalInterstitialDialog.show(
          context: context,
          ad: ad,
          onImpression: () => unawaited(adsService.recordImpression(ad.id)),
          onClick: () => unawaited(adsService.recordClick(ad.id)),
          onViewPlans: () {
            if (mounted) {
              unawaited(PlansScreen.open(context));
            }
          },
        );
      } else if (decision.source == AdSlotSource.admob) {
        await ref
            .read(adsCascadeServiceProvider)
            .showAdMobInterstitialIfReady();
      }
    } finally {
      _showingInterstitial = false;
    }
  }

  Future<void> _handleVoiceDictation() async {
    if (!_isPro) {
      await PlansScreen.open(context);
      return;
    }
    final payload = await VoiceDictationSheet.show(
      context: context,
      mediaService: ref.read(mediaCaptureServiceProvider),
    );
    if (payload == null || !mounted) return;
    await ref
        .read(shoppingControllerProvider.notifier)
        .addItemsFromVoicePayload(payload);
  }

  Future<void> _handlePhotoScan() async {
    if (!_isPro) {
      await PlansScreen.open(context);
      return;
    }
    final source = await ScanPhotoSourceSheet.show(context);
    if (source == null || !mounted) return;
    try {
      final payload = await ref
          .read(mediaCaptureServiceProvider)
          .pickAndCompressImage(source);
      if (payload == null || !mounted) return;
      await ref
          .read(shoppingControllerProvider.notifier)
          .addItemsFromImagePayload(payload);
    } on MediaGuardException catch (e) {
      if (mounted) {
        KarritoToast.show(
          context,
          message: e.userMessage,
          type: KarritoToastType.error,
        );
      }
    }
  }

  Future<void> _handleImportRecipe() async {
    if (!_isPro) {
      await PlansScreen.open(context);
      return;
    }
    final controller = ref.read(shoppingControllerProvider.notifier);
    final result = await ImportRecipeSheet.show(
      context: context,
      mediaService: ref.read(mediaCaptureServiceProvider),
      onPreviewText: controller.previewRecipeFromText,
      onPreviewImage: controller.previewRecipeFromImage,
    );
    if (result == null || !mounted) return;
    await controller.addSelectedRecipeItems(
      result.selectedItems,
      fallbackRawText: result.sourceLabel,
    );
  }

  Future<void> _handleEditPrice(ShoppingItemEntity item) async {
    final result = await ItemPriceInputSheet.show(context, item);
    if (result == null || !mounted) return;
    await ref
        .read(shoppingControllerProvider.notifier)
        .updateItemPrice(item, result.clear ? null : result.price);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitInput() async {
    final text = _inputController.text;
    final success = await ref
        .read(shoppingControllerProvider.notifier)
        .addItems(text);
    if (success && mounted) {
      _inputController.clear();
      _inputFocusNode.unfocus();
    }
  }

  Future<void> _handlePasteClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (pasted.isEmpty) {
      KarritoToast.show(
        context,
        message: AppStrings.clipboardEmptyNotice,
        type: KarritoToastType.info,
      );
      return;
    }

    final existing = _inputController.text.trim();
    final combined = existing.isEmpty ? pasted : '$existing, $pasted';
    _inputController
      ..text = combined
      ..selection = TextSelection.collapsed(offset: combined.length);
    _inputFocusNode.requestFocus();
    KarritoToast.show(
      context,
      message: AppStrings.clipboardPastedNotice,
      type: KarritoToastType.success,
    );
  }

  Future<void> _confirmClearChecked({
    required int checkedCount,
    required String? storeName,
  }) async {
    if (checkedCount <= 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.clearCheckedConfirmTitle),
        content: Text(
          AppStrings.clearCheckedConfirmBody(checkedCount, storeName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.clearCheckedConfirmButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(shoppingControllerProvider.notifier)
        .clearCheckedItemsForActiveList(storeCategory: storeName);
  }

  Future<void> _openEditSheet(ShoppingItemEntity item) async {
    final result = await EditItemBottomSheet.show(
      context,
      item,
      showPriceField: _isPro,
    );
    if (result == null || !mounted) return;

    final controller = ref.read(shoppingControllerProvider.notifier);
    if (result.isDelete) {
      await controller.deleteItem(item);
      return;
    }

    await controller.updateItem(
      original: item,
      cleanName: result.cleanName,
      quantity: result.quantity,
      unit: result.unit,
      storeCategory: result.storeCategory,
      aisleName: result.aisleName,
      price: result.price,
      updatePrice: result.updatePrice,
    );
  }

  Future<void> _openAisleReorder(
    String storeCategory,
    Map<String, List<ShoppingItemEntity>> itemsByAisle,
  ) async {
    final controller = ref.read(shoppingControllerProvider.notifier);
    final aisles = await controller.getAislesForStore(storeCategory);
    if (!mounted || aisles.isEmpty) return;

    final previews = <String, List<String>>{
      for (final entry in itemsByAisle.entries)
        entry.key: entry.value.map((i) => i.cleanName).toList(),
    };

    final reordered = await AisleReorderSheet.show(
      context: context,
      storeCategory: storeCategory,
      initialAisles: aisles,
      aisleItemPreviews: previews,
    );
    if (reordered == null || !mounted) return;

    await controller.saveAisleOrder(
      storeCategory: storeCategory,
      orderedAisles: reordered,
    );
  }

  Future<void> _openFrequentItems() async {
    final controller = ref.read(shoppingControllerProvider.notifier);
    await FrequentItemsSheet.show(
      context: context,
      onAddFrequent: controller.addFromFrequent,
      onRemoveFrequent: controller.removeFromFrequent,
    );
  }

  Future<void> _openLiveShareSheet(ShoppingListEntity list, String shareCode) {
    final controller = ref.read(shoppingControllerProvider.notifier);
    return LiveShareCodeSheet.show(
      context: context,
      listTitle: list.title,
      shareCode: shareCode,
      isJoinedRemote: list.isJoinedRemote,
      onStopLiveShare: list.isJoinedRemote
          ? null
          : controller.stopLiveShareForActiveList,
      onLeaveSharedList: list.isJoinedRemote
          ? controller.leaveSharedListForActiveList
          : null,
    );
  }

  Future<void> _handleShareLive() async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return;

    if (activeList.isJoinedRemote &&
        activeList.isShared &&
        activeList.shareCode != null) {
      await _openLiveShareSheet(activeList, activeList.shareCode!);
      return;
    }

    final controller = ref.read(shoppingControllerProvider.notifier);
    final outcome = await controller.enableLiveShareForActiveList();
    if (outcome == null || !mounted) return;

    if (outcome.requiresPro) {
      await ProLiveRequiredSheet.show(context);
      return;
    }

    if (outcome.shareCode != null) {
      await _openLiveShareSheet(activeList, outcome.shareCode!);
    }
  }

  Future<void> _handleJoinWithCode() async {
    final controller = ref.read(shoppingControllerProvider.notifier);
    await JoinSharedListSheet.show(
      context: context,
      onJoin: controller.joinSharedListByCode,
    );
  }

  Future<void> _openShareOptions() async {
    final isGuest = ref.read(accountStatusProvider).isAnonymous;
    final choice = await ShareOptionsSheet.show(
      context: context,
      isGuestAccount: isGuest,
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case ShareOptionChoice.text:
        await ref
            .read(shoppingControllerProvider.notifier)
            .shareActiveListAsText();
      case ShareOptionChoice.live:
        await _handleShareLive();
      case ShareOptionChoice.join:
        await _handleJoinWithCode();
      case ShareOptionChoice.openSettings:
        await Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
    }
  }

  void _openListSelector(
    List<ShoppingListEntity> lists,
    ShoppingListEntity activeList,
  ) {
    final controller = ref.read(shoppingControllerProvider.notifier);
    final maxActiveLists = ref.read(maxActiveListsForPlanProvider);
    ListSelectorSheet.show(
      context: context,
      lists: lists,
      activeListId: activeList.id,
      maxActiveLists: maxActiveLists,
      onUpgradePlan: () => PlansScreen.open(context),
      onSelect: (id) {
        ref.read(activeListIdProvider.notifier).select(id);
        setState(() {
          _selectedStore = null;
        });
      },
      onCreate: controller.createList,
      onRename: controller.renameList,
      onDelete: controller.deleteList,
      onShareLive: _handleShareLive,
      onJoinWithCode: _handleJoinWithCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      shoppingControllerProvider.select((s) => s.interstitialTriggerVersion),
      (previous, next) {
        if (previous != null && next != previous && mounted) {
          unawaited(_maybeShowInterstitial());
        }
      },
    );

    final uiState = ref.watch(shoppingControllerProvider);
    final listsAsync = ref.watch(shoppingListsProvider);
    final activeList = ref.watch(activeListProvider);
    final itemsAsync = ref.watch(activeListItemsProvider);
    final aisleOrderMap =
        ref.watch(aisleOrderMapProvider).value ??
        const <(String, String), int>{};
    final prefs = ref.watch(preferencesProvider).value;
    final planTier = ref.watch(effectivePlanTierProvider);
    final isPro = KarritoPlanTier.isPro(planTier);
    final account = ref.watch(accountStatusProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final pendingAiCount =
        ref.watch(activeListPendingAiCountProvider).value ?? 0;

    final keepScreenOn = prefs?.keepScreenOn ?? true;
    final avatarChoice = prefs?.avatarChoice ?? KarritoAvatars.defaultChoice;
    final googlePhotoUrl = prefs?.googlePhotoUrl ?? account.photoUrl;
    final lists = listsAsync.value ?? const <ShoppingListEntity>[];
    final items = itemsAsync.value ?? const <ShoppingItemEntity>[];
    final totalPendingCount = items.where((i) => !i.isChecked).length;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    // Group items dynamically by store
    final itemsByStore = <String, List<ShoppingItemEntity>>{};
    for (final item in items) {
      itemsByStore
          .putIfAbsent(item.storeCategory, () => <ShoppingItemEntity>[])
          .add(item);
    }

    final sortedStores = itemsByStore.keys.toList()
      ..sort((a, b) {
        final idxA = StoreHierarchy.storeOrder.indexOf(a);
        final idxB = StoreHierarchy.storeOrder.indexOf(b);
        final rankA = idxA >= 0 ? idxA : 999;
        final rankB = idxB >= 0 ? idxB : 999;
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.compareTo(b);
      });

    final effectiveStore = sortedStores.isEmpty
        ? null
        : (sortedStores.contains(_selectedStore)
              ? _selectedStore!
              : sortedStores.first);

    final activeStoreItems = effectiveStore == null
        ? const <ShoppingItemEntity>[]
        : (itemsByStore[effectiveStore] ?? const <ShoppingItemEntity>[]);

    final itemsByAisle = <String, List<ShoppingItemEntity>>{};
    for (final item in activeStoreItems) {
      itemsByAisle
          .putIfAbsent(item.aisleName, () => <ShoppingItemEntity>[])
          .add(item);
    }

    final sortedAisles = itemsByAisle.keys.toList()
      ..sort((a, b) {
        final orderA = aisleOrderMap[(effectiveStore!, a)] ?? 500;
        final orderB = aisleOrderMap[(effectiveStore, b)] ?? 500;
        if (orderA != orderB) return orderA.compareTo(orderB);
        return a.compareTo(b);
      });

    final activeStorePendingCount = activeStoreItems
        .where((i) => !i.isChecked)
        .length;
    final activeStoreCheckedCount =
        activeStoreItems.length - activeStorePendingCount;

    final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
      1.0,
      1.45,
    );
    final inputBoxHeight = 86.0 * textScale;
    final slBottomHeight =
        (activeList != null ? (6.0 + 38.0 * textScale) : 0.0) +
        (56.0 + inputBoxHeight + (86.0 * textScale)) +
        (sortedStores.isNotEmpty ? (6.0 + 44.0 * textScale) : 0.0);

    Widget wrapMaxWidth(Widget child) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: child,
        ),
      );
    }

    final recipesBorderColor = isDark
        ? const Color(0xFF9E74FF)
        : const Color(0xFF280066);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: isDark ? karritoColors.cta : karritoColors.accent,
              backgroundColor: colorScheme.surface,
              onRefresh: () => ref
                  .read(shoppingControllerProvider.notifier)
                  .refreshFromPull(),
              child: CustomScrollView(
                key: const ValueKey<String>('shopping_list_scroll_view'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: false,
                    pinned: false,
                    primary: true,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    titleSpacing: 16,
                    title: const KarritoBrandLogo(height: 30),
                    actions: [
                      Semantics(
                        button: true,
                        label: isDark
                            ? AppStrings.switchToLightTooltip
                            : AppStrings.switchToDarkTooltip,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: isDark
                              ? AppStrings.switchToLightTooltip
                              : AppStrings.switchToDarkTooltip,
                          style: IconButton.styleFrom(
                            backgroundColor: karritoColors.fieldSurface,
                          ),
                          icon: AnimatedSwitcher(
                            duration: disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 240),
                            transitionBuilder: (child, animation) {
                              return RotationTransition(
                                turns: Tween<double>(
                                  begin: 0.78,
                                  end: 1.0,
                                ).animate(animation),
                                child: ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              key: ValueKey<bool>(isDark),
                              size: 20,
                              color: isDark
                                  ? karritoColors.lime
                                  : karritoColors.accentSoft,
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(shoppingControllerProvider.notifier)
                                .setThemeMode(isDark ? 'light' : 'dark');
                          },
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: keepScreenOn
                            ? AppStrings.wakelockOnTooltip
                            : AppStrings.wakelockOffTooltip,
                        style: keepScreenOn
                            ? IconButton.styleFrom(
                                backgroundColor: karritoColors.accent,
                                foregroundColor: karritoColors.onAccent,
                              )
                            : IconButton.styleFrom(
                                backgroundColor: karritoColors.fieldSurface,
                              ),
                        icon: Icon(
                          keepScreenOn
                              ? Icons.stay_current_portrait_rounded
                              : Icons.screen_lock_portrait_rounded,
                          size: 19,
                        ),
                        onPressed: () {
                          ref
                              .read(shoppingControllerProvider.notifier)
                              .setKeepScreenOn(!keepScreenOn, notify: true);
                        },
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: AppStrings.shareListTooltip,
                        style: IconButton.styleFrom(
                          backgroundColor: karritoColors.accentContainer,
                          foregroundColor: karritoColors.accentSoft,
                        ),
                        icon: const Icon(Icons.share_rounded, size: 19),
                        onPressed: _openShareOptions,
                      ),
                      const SizedBox(width: 6),
                      Semantics(
                        button: true,
                        label: AppStrings.profileMenuTooltip,
                        child: Tooltip(
                          message: AppStrings.profileMenuTooltip,
                          child: KarritoBounceButton(
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => ProfileMenuSheet.show(context),
                              child: KarritoProfileAvatar(
                                avatarChoice: avatarChoice,
                                googlePhotoUrl: googlePhotoUrl,
                                size: 40,
                                showLinkedDot: !account.isAnonymous,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(slBottomHeight),
                      child: SizedBox(
                        height: slBottomHeight,
                        child: wrapMaxWidth(
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (activeList != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    2,
                                  ),
                                  child: SizedBox(
                                    height: 36 * textScale,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Tooltip(
                                            message:
                                                AppStrings.listSelectorTooltip,
                                            child: KarritoBounceButton(
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                onTap: () => _openListSelector(
                                                  lists,
                                                  activeList,
                                                ),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 13,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? karritoColors
                                                              .aisleCardSurface
                                                        : karritoColors
                                                              .fieldSurface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          karritoColors.border,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (activeList
                                                          .isShared) ...[
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    karritoColors
                                                                        .lime,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 7,
                                                        ),
                                                      ],
                                                      Flexible(
                                                        child: Text(
                                                          activeList.title,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: theme
                                                              .textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: colorScheme
                                                                    .onSurface,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded,
                                                        size: 20,
                                                        color: karritoColors
                                                            .accentSoft,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (items.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: totalPendingCount == 0
                                                  ? karritoColors.lime
                                                  : karritoColors
                                                        .accentContainer,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              AppStrings.pendingCountBadge(
                                                totalPendingCount,
                                                items.length,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures(),
                                                ],
                                                color: totalPendingCount == 0
                                                    ? karritoColors.onLime
                                                    : karritoColors
                                                          .onAccentContainer,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  8,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? karritoColors.aisleCardSurface
                                        : colorScheme.surface,
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(
                                      color: karritoColors.border,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: karritoColors.shadowTint,
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    10,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        key: const ValueKey<String>(
                                          'smart_input_container',
                                        ),
                                        constraints: BoxConstraints(
                                          minHeight: 74 * textScale,
                                          maxHeight: inputBoxHeight,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF251D38)
                                              : const Color(0xFFF2EFFB),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: karritoColors.border
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _inputController,
                                                focusNode: _inputFocusNode,
                                                enabled: !uiState.isSubmitting,
                                                minLines: 2,
                                                maxLines: 3,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(height: 1.32),
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          AppStrings.inputHint,
                                                      hintMaxLines: 2,
                                                      filled: false,
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                            16,
                                                            14,
                                                            8,
                                                            14,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 30,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                              color: karritoColors.border
                                                  .withValues(alpha: 0.75),
                                            ),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              tooltip:
                                                  AppStrings.voiceInputTooltip,
                                              onPressed: uiState.isSubmitting
                                                  ? null
                                                  : _handleVoiceDictation,
                                              icon: Icon(
                                                Icons.mic_none_rounded,
                                                size: 21,
                                                color: isPro
                                                    ? karritoColors.accentSoft
                                                    : karritoColors
                                                          .textSecondary,
                                              ),
                                            ),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              tooltip:
                                                  AppStrings.scanPhotoTooltip,
                                              onPressed: uiState.isSubmitting
                                                  ? null
                                                  : _handlePhotoScan,
                                              icon: Icon(
                                                Icons.photo_camera_outlined,
                                                size: 20,
                                                color: isPro
                                                    ? karritoColors.accentSoft
                                                    : karritoColors
                                                          .textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 42 * textScale,
                                        child: Row(
                                          key: const ValueKey<String>(
                                            'input_actions_row',
                                          ),
                                          children: [
                                            Flexible(
                                              flex: 3,
                                              fit: FlexFit.tight,
                                              child: KarritoBounceButton(
                                                enabled: !uiState.isSubmitting,
                                                child: TextButton(
                                                  onPressed:
                                                      uiState.isSubmitting
                                                      ? null
                                                      : _handlePasteClipboard,
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: isDark
                                                        ? const Color(
                                                            0xFF251D38,
                                                          )
                                                        : const Color(
                                                            0xFFF2EFFB,
                                                          ),
                                                    foregroundColor:
                                                        karritoColors
                                                            .accentSoft,
                                                    minimumSize: const Size(
                                                      0,
                                                      40,
                                                    ),
                                                    shape:
                                                        const StadiumBorder(),
                                                    side: BorderSide(
                                                      color:
                                                          karritoColors.border,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .content_paste_rounded,
                                                        size: 16,
                                                        color: karritoColors
                                                            .accentSoft,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Flexible(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            AppStrings
                                                                .pasteClipboardButton,
                                                            maxLines: 1,
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              flex: 4,
                                              fit: FlexFit.tight,
                                              child: KarritoBounceButton(
                                                child: TextButton(
                                                  onPressed: _openFrequentItems,
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        karritoColors
                                                            .ctaContainer,
                                                    foregroundColor:
                                                        karritoColors
                                                            .onCtaContainer,
                                                    minimumSize: const Size(
                                                      0,
                                                      40,
                                                    ),
                                                    shape:
                                                        const StadiumBorder(),
                                                    side: BorderSide(
                                                      color: karritoColors.cta
                                                          .withValues(
                                                            alpha: isDark
                                                                ? 0.35
                                                                : 0.25,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .star_outline_rounded,
                                                        size: 16,
                                                        color:
                                                            karritoColors.cta,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Flexible(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            AppStrings
                                                                .frequentButton,
                                                            maxLines: 1,
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              flex: 4,
                                              fit: FlexFit.tight,
                                              child: KarritoBounceButton(
                                                enabled: !uiState.isSubmitting,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: karritoColors.cta
                                                            .withValues(
                                                              alpha: isDark
                                                                  ? 0.42
                                                                  : 0.28,
                                                            ),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: FilledButton(
                                                    onPressed:
                                                        uiState.isSubmitting
                                                        ? null
                                                        : _submitInput,
                                                    style: FilledButton.styleFrom(
                                                      backgroundColor:
                                                          karritoColors.cta,
                                                      foregroundColor:
                                                          karritoColors.onCta,
                                                      shape:
                                                          const StadiumBorder(),
                                                      minimumSize: const Size(
                                                        0,
                                                        40,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        if (uiState
                                                            .isSubmitting)
                                                          SizedBox(
                                                            width: 16,
                                                            height: 16,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  karritoColors
                                                                      .onCta,
                                                            ),
                                                          )
                                                        else
                                                          const Icon(
                                                            Icons.add_rounded,
                                                            size: 16,
                                                          ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        const Flexible(
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              AppStrings
                                                                  .addItemsButton,
                                                              maxLines: 1,
                                                              softWrap: false,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      KarritoBounceButton(
                                        enabled: !uiState.isSubmitting,
                                        child: Material(
                                          color: karritoColors.accent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            side: BorderSide(
                                              color: recipesBorderColor,
                                              width: 1.3,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            key: const ValueKey<String>(
                                              'wide_recipes_button',
                                            ),
                                            onTap: uiState.isSubmitting
                                                ? null
                                                : _handleImportRecipe,
                                            child: SizedBox(
                                              height: 40 * textScale,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    KarritoChefHatIcon(
                                                      size: 20,
                                                      color: karritoColors
                                                          .onAccent,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      AppStrings
                                                          .importRecipeButton,
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontSize: 14.5,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: karritoColors
                                                                .onAccent,
                                                          ),
                                                    ),
                                                    const Spacer(),
                                                    if (!isPro)
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              right: 6,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.18,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                999,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          'Pro',
                                                          style: TextStyle(
                                                            fontSize: 10.5,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: karritoColors
                                                                .onAccent,
                                                          ),
                                                        ),
                                                      ),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 20,
                                                      color: karritoColors
                                                          .onAccent,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (sortedStores.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: SizedBox(
                                    height: 44 * textScale,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: sortedStores.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final store = sortedStores[index];
                                        final storeList = itemsByStore[store]!;
                                        final pending = storeList
                                            .where((item) => !item.isChecked)
                                            .length;
                                        final isSelected =
                                            store == effectiveStore;

                                        return KarritoBounceButton(
                                          child: ChoiceChip(
                                            selected: isSelected,
                                            showCheckmark: false,
                                            backgroundColor: isDark
                                                ? karritoColors.aisleCardSurface
                                                : colorScheme.surface,
                                            selectedColor: karritoColors.accent,
                                            shape: const StadiumBorder(),
                                            side: BorderSide(
                                              color: isSelected
                                                  ? karritoColors.accent
                                                  : karritoColors.border,
                                              width: isSelected ? 1.4 : 1.0,
                                            ),
                                            avatar: KarritoAssetIcon.store(
                                              store,
                                              size: 18,
                                              color: isSelected
                                                  ? karritoColors.onAccent
                                                  : karritoColors.textSecondary,
                                            ),
                                            label: Text(
                                              '$store (${AppStrings.pendingCountBadge(pending, storeList.length)})',
                                              style: TextStyle(
                                                fontWeight: isSelected
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures(),
                                                ],
                                                color: isSelected
                                                    ? karritoColors.onAccent
                                                    : colorScheme.onSurface,
                                              ),
                                            ),
                                            onSelected: (_) {
                                              setState(() {
                                                _selectedStore = store;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isOnline)
                    SliverToBoxAdapter(
                      child: wrapMaxWidth(
                        _StatusBanner(
                          backgroundColor: karritoColors.warningSurface,
                          foregroundColor: karritoColors.warningText,
                          badgeColor: karritoColors.cta,
                          badgeText: AppStrings.pendingOfflineBadge,
                          icon: Icons.cloud_off_rounded,
                          title: AppStrings.offlineBannerTitle,
                          subtitle: AppStrings.offlineBannerBody,
                        ),
                      ),
                    )
                  else if (pendingAiCount > 0)
                    SliverToBoxAdapter(
                      child: wrapMaxWidth(
                        _StatusBanner(
                          backgroundColor: karritoColors.ctaContainer,
                          foregroundColor: karritoColors.onCtaContainer,
                          badgeColor: karritoColors.cta,
                          badgeText: 'Pendientes',
                          icon: Icons.cloud_sync_rounded,
                          title: AppStrings.pendingAiBanner(pendingAiCount),
                          trailing: uiState.isReprocessing
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: karritoColors.onCtaContainer,
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                          shoppingControllerProvider.notifier,
                                        )
                                        .reprocessPendingAi(
                                          userTriggered: true,
                                        );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        karritoColors.onCtaContainer,
                                  ),
                                  child: const Text(
                                    AppStrings.reprocessNowButton,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (activeList != null &&
                      activeList.isShared &&
                      activeList.shareCode != null)
                    SliverToBoxAdapter(
                      child: wrapMaxWidth(
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _openLiveShareSheet(
                              activeList,
                              activeList.shareCode!,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? const [
                                          Color(0xFF2D1B54),
                                          Color(0xFF1E1338),
                                        ]
                                      : const [
                                          Color(0xFF531CB3),
                                          Color(0xFF3A008C),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: isDark
                                    ? Border.all(
                                        color: karritoColors.accent.withValues(
                                          alpha: 0.4,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: karritoColors.lime,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      AppStrings.liveListBadge,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: karritoColors.onLime,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Código ${activeList.shareCode}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (effectiveStore != null && sortedAisles.isNotEmpty)
                    SliverToBoxAdapter(
                      child: wrapMaxWidth(
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 12, 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$effectiveStore · ${sortedAisles.length} ${sortedAisles.length == 1 ? 'pasillo' : 'pasillos'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: karritoColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              KarritoBounceButton(
                                child: TextButton.icon(
                                  onPressed: () => _openAisleReorder(
                                    effectiveStore,
                                    itemsByAisle,
                                  ),
                                  icon: const Icon(
                                    Icons.reorder_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    AppStrings.reorderAislesButton,
                                  ),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if ((itemsAsync.isLoading && items.isEmpty) ||
                      (uiState.isSubmitting && items.isEmpty))
                    SliverToBoxAdapter(
                      child: wrapMaxWidth(
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: KarritoSkeletonLoader(shrinkWrap: true),
                        ),
                      ),
                    )
                  else if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: wrapMaxWidth(const _EmptyListPlaceholder()),
                    )
                  else ...[
                    if (uiState.isSubmitting)
                      SliverToBoxAdapter(
                        child: wrapMaxWidth(
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 6, 16, 12),
                            child: KarritoSkeletonLoader(
                              showStoreTabs: false,
                              cardCount: 1,
                              shrinkWrap: true,
                            ),
                          ),
                        ),
                      ),
                    if (activeStorePendingCount == 0 &&
                        activeStoreItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: wrapMaxWidth(
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: karritoColors.completedContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: karritoColors.completed.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: karritoColors.lime,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: karritoColors.onLime,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppStrings.allCheckedInStore,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color:
                                            karritoColors.onCompletedContainer,
                                      ),
                                    ),
                                  ),
                                  if (totalPendingCount == 0 && !isPro)
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              shoppingControllerProvider
                                                  .notifier,
                                            )
                                            .triggerInterstitialForListCompletion();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            karritoColors.onCompletedContainer,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: const Text('Cerrar lista'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (activeStoreCheckedCount > 0)
                      SliverToBoxAdapter(
                        child: wrapMaxWidth(
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: KarritoBounceButton(
                                child: TextButton.icon(
                                  onPressed: () => _confirmClearChecked(
                                    checkedCount: activeStoreCheckedCount,
                                    storeName: effectiveStore,
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: isDark
                                        ? karritoColors.fieldSurface
                                        : karritoColors.accentContainer,
                                    foregroundColor: isDark
                                        ? karritoColors.accentSoft
                                        : karritoColors.onAccentContainer,
                                    visualDensity: VisualDensity.compact,
                                    shape: const StadiumBorder(),
                                    side: BorderSide(
                                      color: karritoColors.border,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 7,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.cleaning_services_outlined,
                                    size: 15,
                                  ),
                                  label: Text(
                                    AppStrings.clearCheckedButton(
                                      activeStoreCheckedCount,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                      sliver: SliverList.builder(
                        itemCount: sortedAisles.length,
                        itemBuilder: (context, index) {
                          final aisle = sortedAisles[index];
                          return wrapMaxWidth(
                            AisleSectionCard(
                              key: ValueKey(
                                '${activeList?.id}::$effectiveStore::$aisle',
                              ),
                              aisleName: aisle,
                              items: itemsByAisle[aisle]!,
                              showPriceChips: isPro,
                              isExpanded: !_collapsedAisleKeys.contains(
                                '$effectiveStore::$aisle',
                              ),
                              onToggleExpand: () {
                                final key = '$effectiveStore::$aisle';
                                setState(() {
                                  if (_collapsedAisleKeys.contains(key)) {
                                    _collapsedAisleKeys.remove(key);
                                  } else {
                                    _collapsedAisleKeys.add(key);
                                  }
                                });
                              },
                              onToggleItem: (item) {
                                ref
                                    .read(shoppingControllerProvider.notifier)
                                    .toggleItemChecked(item);
                              },
                              onEditItem: _openEditSheet,
                              onEditPrice: isPro ? _handleEditPrice : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isPro && items.isNotEmpty)
            wrapMaxWidth(
              _ProCartSummaryBar(
                summary: CartPriceCalculator.summarize(
                  items: items,
                  activeStore: effectiveStore,
                ),
                onOpenHistory: () => MonthlyExpensesScreen.open(context),
                onSaveTrip: () {
                  ref
                      .read(shoppingControllerProvider.notifier)
                      .saveShoppingExpensesForActiveList();
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: const KarritoAdsBannerBar(),
    );
  }
}

class _ProCartSummaryBar extends StatelessWidget {
  const _ProCartSummaryBar({
    required this.summary,
    required this.onOpenHistory,
    required this.onSaveTrip,
  });

  final CartPriceSummary summary;
  final VoidCallback onOpenHistory;
  final VoidCallback onSaveTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: isDark
            ? karritoColors.aisleCardSurface
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: karritoColors.accent.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: karritoColors.shadowTint,
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.cartStoreSubtotalLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: karritoColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatArs(summary.storeAmount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: karritoColors.border),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.cartTotalLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: karritoColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatArs(summary.totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: karritoColors.accentSoft,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppStrings.cartMonthlyHistoryButton,
                onPressed: onOpenHistory,
                style: IconButton.styleFrom(
                  backgroundColor: karritoColors.accentContainer,
                  foregroundColor: karritoColors.accentSoft,
                ),
                icon: const Icon(Icons.bar_chart_rounded, size: 20),
              ),
            ],
          ),
          if (summary.hasAnyPrice) ...[
            const SizedBox(height: 8),
            KarritoBounceButton(
              child: FilledButton.icon(
                onPressed: onSaveTrip,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  backgroundColor: karritoColors.cta,
                  foregroundColor: karritoColors.onCta,
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text(AppStrings.cartCloseAndSaveButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.badgeColor,
    required this.badgeText,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color badgeColor;
  final String badgeText;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: foregroundColor.withValues(alpha: 0.88),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}

class _EmptyListPlaceholder extends StatelessWidget {
  const _EmptyListPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: karritoColors.accentContainer,
                shape: BoxShape.circle,
                border: Border.all(color: karritoColors.border),
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 34,
                color: karritoColors.accentSoft,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.emptyListTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.emptyListBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: karritoColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
