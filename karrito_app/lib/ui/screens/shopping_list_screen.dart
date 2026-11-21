import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
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

  Future<void> _openAisleReorder(String storeCategory) async {
    final controller = ref.read(shoppingControllerProvider.notifier);
    final aisles = await controller.getAislesForStore(storeCategory);
    if (!mounted || aisles.isEmpty) return;

    final reordered = await AisleReorderSheet.show(
      context: context,
      storeCategory: storeCategory,
      initialAisles: aisles,
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
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _openListSelector(lists, activeList),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: karritoColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (activeList.isShared) ...[
                            Icon(
                              Icons.sensors_rounded,
                              size: 16,
                              color: karritoColors.completed,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Flexible(
                            child: Text(
                              activeList.title,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: karritoColors.accent,
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
                  color: isDark ? karritoColors.accent : colorScheme.onSurface,
                ),
              ),
              onPressed: () {
                ref
                    .read(shoppingControllerProvider.notifier)
                    .setThemeMode(isDark ? 'light' : 'dark');
              },
            ),
          ),
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
                : null,
            icon: Icon(
              keepScreenOn
                  ? Icons.stay_current_portrait_rounded
                  : Icons.screen_lock_portrait_rounded,
            ),
            onPressed: () {
              ref
                  .read(shoppingControllerProvider.notifier)
                  .setKeepScreenOn(!keepScreenOn, notify: true);
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: AppStrings.shareListTooltip,
            icon: const Icon(Icons.share_outlined),
            onPressed: _openShareOptions,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: AppStrings.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
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
                    icon: Icons.wifi_off_rounded,
                    text:
                        '${AppStrings.offlineBannerTitle}. ${AppStrings.offlineBannerBody}',
                  )
                else if (pendingAiCount > 0)
                  _StatusBanner(
                    backgroundColor: karritoColors.accentContainer,
                    foregroundColor: karritoColors.onAccentContainer,
                    icon: Icons.cloud_sync_outlined,
                    text: AppStrings.pendingAiBanner(pendingAiCount),
                    trailing: uiState.isReprocessing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: karritoColors.onAccentContainer,
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              ref
                                  .read(shoppingControllerProvider.notifier)
                                  .reprocessPendingAi(userTriggered: true);
                            },
                            child: const Text(AppStrings.reprocessNowButton),
                          ),
                  ),
                if (activeList != null &&
                    activeList.isShared &&
                    activeList.shareCode != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => LiveShareCodeSheet.show(
                        context: context,
                        listTitle: activeList.title,
                        shareCode: activeList.shareCode!,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: karritoColors.completedContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sensors_rounded,
                              size: 16,
                              color: karritoColors.completed,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppStrings.liveListBadge} · Código ${activeList.shareCode}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: karritoColors.onCompletedContainer,
                                ),
                              ),
                            ),
                            Text(
                              AppStrings.shareListTooltip,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: karritoColors.completed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
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
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              KarritoBounceButton(
                                child: OutlinedButton.icon(
                                  onPressed: _openFrequentItems,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 42),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.history_rounded,
                                    size: 18,
                                    color: karritoColors.accent,
                                  ),
                                  label: const Text(AppStrings.frequentButton),
                                ),
                              ),
                              const Spacer(),
                              KarritoBounceButton(
                                enabled: !uiState.isSubmitting,
                                child: FilledButton(
                                  onPressed: uiState.isSubmitting
                                      ? null
                                      : _submitInput,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 42),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: uiState.isSubmitting
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Text(AppStrings.addItemsButton),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (sortedStores.isNotEmpty) ...[
                  SizedBox(
                    height: 48,
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
                        return KarritoBounceButton(
                          child: ChoiceChip(
                            selected: isSelected,
                            showCheckmark: false,
                            backgroundColor: colorScheme.surface,
                            selectedColor: karritoColors.accent,
                            side: BorderSide(
                              color: isSelected
                                  ? karritoColors.accent
                                  : karritoColors.border,
                              width: isSelected ? 1.4 : 1.0,
                            ),
                            label: Text(
                              '$store (${AppStrings.pendingCountBadge(pending, storeList.length)})',
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          KarritoBounceButton(
                            child: TextButton.icon(
                              onPressed: () =>
                                  _openAisleReorder(effectiveStore),
                              icon: const Icon(Icons.reorder_rounded, size: 18),
                              label: const Text(AppStrings.reorderAislesButton),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
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
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                            children: [
                              if (activeStorePendingCount == 0 &&
                                  activeStoreItems.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: karritoColors.completedContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 18,
                                          color: karritoColors.completed,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            AppStrings.allCheckedInStore,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
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
    required this.icon,
    required this.text,
    this.trailing,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
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
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: karritoColors.accentContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 34,
                color: theme.brightness == Brightness.dark
                    ? karritoColors.accent
                    : karritoColors.onAccentContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.emptyListTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.emptyListBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
