import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../providers/core_providers.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/aisle_section_card.dart';
import '../widgets/edit_item_sheet.dart';
import '../widgets/list_selector_sheet.dart';
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
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ShoppingUiState>(shoppingControllerProvider, (previous, next) {
      if (next.messageVersion != previous?.messageVersion &&
          next.feedbackMessage != null &&
          mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.feedbackMessage!),
            backgroundColor: next.isError
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        );
      }
    });

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

    final colorScheme = Theme.of(context).colorScheme;
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

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
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _openListSelector(lists, activeList),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            activeList.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        actions: [
          IconButton(
            tooltip: keepScreenOn
                ? AppStrings.wakelockOnTooltip
                : AppStrings.wakelockOffTooltip,
            style: keepScreenOn
                ? IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
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
            tooltip: AppStrings.shareListTooltip,
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ref.read(shoppingControllerProvider.notifier).shareActiveList();
            },
          ),
          IconButton(
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
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    icon: Icons.cloud_sync_outlined,
                    text: AppStrings.pendingAiBanner(pendingAiCount),
                    trailing: uiState.isReprocessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
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
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: uiState.isSubmitting
                                ? null
                                : _submitInput,
                            child: uiState.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(AppStrings.addItemsButton),
                          ),
                        ],
                      ),
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
                        return ChoiceChip(
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: colorScheme.primary,
                          label: Text(
                            '$store (${AppStrings.pendingCountBadge(pending, storeList.length)})',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedStore = store;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: itemsAsync.isLoading && items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? const _EmptyListPlaceholder()
                      : ListView(
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
                                      .read(shoppingControllerProvider.notifier)
                                      .toggleItemChecked(item);
                                },
                                onEditItem: _openEditSheet,
                              ),
                          ],
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 32,
                color: colorScheme.primary,
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
