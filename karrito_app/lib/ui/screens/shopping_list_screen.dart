import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/store_visuals.dart';
import '../../data/local/app_database.dart';
import '../../providers/core_providers.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/aisle_reorder_sheet.dart';
import '../widgets/aisle_section_card.dart';
import '../widgets/edit_item_sheet.dart';
import '../widgets/frequent_items_sheet.dart';
import '../widgets/karrito_bounce_button.dart';
import '../widgets/list_selector_sheet.dart';
import '../widgets/live_share_sheets.dart';
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

  Future<void> _openEditSheet(ShoppingItemEntity item) async {
    final result = await EditItemBottomSheet.show(context, item);
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

  Future<void> _handleShareLive() async {
    final activeList = ref.read(activeListProvider);
    if (activeList == null) return;

    final controller = ref.read(shoppingControllerProvider.notifier);
    final outcome = await controller.enableLiveShareForActiveList();
    if (outcome == null || !mounted) return;

    if (outcome.requiresPro) {
      await ProLiveRequiredSheet.show(context);
      return;
    }

    if (outcome.shareCode != null) {
      await LiveShareCodeSheet.show(
        context: context,
        listTitle: activeList.title,
        shareCode: outcome.shareCode!,
      );
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
    ListSelectorSheet.show(
      context: context,
      lists: lists,
      activeListId: activeList.id,
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
    final uiState = ref.watch(shoppingControllerProvider);
    final listsAsync = ref.watch(shoppingListsProvider);
    final activeList = ref.watch(activeListProvider);
    final itemsAsync = ref.watch(activeListItemsProvider);
    final aisleOrderMap =
        ref.watch(aisleOrderMapProvider).value ??
        const <(String, String), int>{};
    final prefs = ref.watch(preferencesProvider).value;
    final isOnline = ref.watch(isOnlineProvider);
    final pendingAiCount =
        ref.watch(activeListPendingAiCountProvider).value ?? 0;

    final keepScreenOn = prefs?.keepScreenOn ?? true;
    final lists = listsAsync.value ?? const <ShoppingListEntity>[];
    final items = itemsAsync.value ?? const <ShoppingItemEntity>[];

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

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: activeList == null
            ? const Text(AppStrings.appName)
            : Tooltip(
                message: AppStrings.listSelectorTooltip,
                child: KarritoBounceButton(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _openListSelector(lists, activeList),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? karritoColors.aisleCardSurface
                            : karritoColors.fieldSurface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: karritoColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (activeList.isShared) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: karritoColors.lime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                          ],
                          Flexible(
                            child: Text(
                              activeList.title,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: karritoColors.accentSoft,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                backgroundColor: isDark
                    ? karritoColors.fieldSurface
                    : karritoColors.fieldSurface,
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
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey<bool>(isDark),
                  size: 20,
                  color: isDark ? karritoColors.lime : karritoColors.accentSoft,
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
          const SizedBox(width: 2),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: AppStrings.settingsTooltip,
            style: IconButton.styleFrom(
              backgroundColor: karritoColors.fieldSurface,
              foregroundColor: colorScheme.onSurface,
            ),
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isOnline)
                  _StatusBanner(
                    backgroundColor: karritoColors.warningSurface,
                    foregroundColor: karritoColors.warningText,
                    badgeColor: karritoColors.cta,
                    badgeText: AppStrings.pendingOfflineBadge,
                    icon: Icons.cloud_off_rounded,
                    title: AppStrings.offlineBannerTitle,
                    subtitle: AppStrings.offlineBannerBody,
                  )
                else if (pendingAiCount > 0)
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
                                  .read(shoppingControllerProvider.notifier)
                                  .reprocessPendingAi(userTriggered: true);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: karritoColors.onCtaContainer,
                            ),
                            child: const Text(AppStrings.reprocessNowButton),
                          ),
                  ),
                if (activeList != null &&
                    activeList.isShared &&
                    activeList.shareCode != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => LiveShareCodeSheet.show(
                        context: context,
                        listTitle: activeList.title,
                        shareCode: activeList.shareCode!,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? const [Color(0xFF2D1B54), Color(0xFF1E1338)]
                                : const [Color(0xFF531CB3), Color(0xFF3A008C)],
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
                                style: theme.textTheme.bodySmall?.copyWith(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? karritoColors.aisleCardSurface
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: karritoColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: karritoColors.shadowTint,
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: karritoColors.fieldSurface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: karritoColors.border.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: _inputController,
                            focusNode: _inputFocusNode,
                            enabled: !uiState.isSubmitting,
                            minLines: 1,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: AppStrings.inputHint,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            KarritoBounceButton(
                              child: TextButton.icon(
                                onPressed: _openFrequentItems,
                                style: TextButton.styleFrom(
                                  backgroundColor: karritoColors.ctaContainer,
                                  foregroundColor: karritoColors.onCtaContainer,
                                  minimumSize: const Size(0, 42),
                                  shape: const StadiumBorder(),
                                  side: BorderSide(
                                    color: karritoColors.cta.withValues(
                                      alpha: isDark ? 0.35 : 0.25,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.star_outline_rounded,
                                  size: 18,
                                  color: karritoColors.cta,
                                ),
                                label: const Text(AppStrings.frequentButton),
                              ),
                            ),
                            const Spacer(),
                            KarritoBounceButton(
                              enabled: !uiState.isSubmitting,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: karritoColors.accent.withValues(
                                        alpha: isDark ? 0.42 : 0.22,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FilledButton.icon(
                                  onPressed: uiState.isSubmitting
                                      ? null
                                      : _submitInput,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 42),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: uiState.isSubmitting
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(Icons.add_rounded, size: 19),
                                  label: const Text(AppStrings.addItemsButton),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (sortedStores.isNotEmpty) ...[
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: sortedStores.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final store = sortedStores[index];
                        final storeList = itemsByStore[store]!;
                        final pending = storeList
                            .where((item) => !item.isChecked)
                            .length;
                        final isSelected = store == effectiveStore;
                        final storeVisual = StoreVisuals.forStore(store);

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
                            avatar: Icon(
                              storeVisual.icon,
                              size: 16,
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
                  if (effectiveStore != null && sortedAisles.isNotEmpty)
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
                              icon: const Icon(Icons.reorder_rounded, size: 18),
                              label: const Text(AppStrings.reorderAislesButton),
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
                ],
                Expanded(
                  child: itemsAsync.isLoading && items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? const _EmptyListPlaceholder()
                      : AnimatedSwitcher(
                          duration: disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.025),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: ListView(
                            key: ValueKey<String>(
                              '${activeList?.id}::$effectiveStore',
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                            children: [
                              if (activeStorePendingCount == 0 &&
                                  activeStoreItems.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color: karritoColors.completedContainer,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: karritoColors.completed
                                            .withValues(alpha: 0.35),
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
                                              color: karritoColors
                                                  .onCompletedContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              for (final aisle in sortedAisles)
                                AisleSectionCard(
                                  key: ValueKey(
                                    '${activeList?.id}::$effectiveStore::$aisle',
                                  ),
                                  aisleName: aisle,
                                  items: itemsByAisle[aisle]!,
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
                                        .read(
                                          shoppingControllerProvider.notifier,
                                        )
                                        .toggleItemChecked(item);
                                  },
                                  onEditItem: _openEditSheet,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
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
