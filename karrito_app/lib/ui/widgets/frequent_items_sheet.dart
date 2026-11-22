import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/services/item_text_parser.dart';
import '../../providers/shopping_providers.dart';
import 'karrito_selector_field.dart';
import 'karrito_toast.dart';

class FrequentItemsSheet extends ConsumerStatefulWidget {
  const FrequentItemsSheet({
    required this.onAddFrequent,
    required this.onRemoveFrequent,
    super.key,
  });

  final Future<void> Function(LearnedItemEntity item) onAddFrequent;
  final Future<void> Function(LearnedItemEntity item) onRemoveFrequent;

  static Future<void> show({
    required BuildContext context,
    required Future<void> Function(LearnedItemEntity item) onAddFrequent,
    required Future<void> Function(LearnedItemEntity item) onRemoveFrequent,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FrequentItemsSheet(
        onAddFrequent: onAddFrequent,
        onRemoveFrequent: onRemoveFrequent,
      ),
    );
  }

  @override
  ConsumerState<FrequentItemsSheet> createState() => _FrequentItemsSheetState();
}

class _FrequentItemsSheetState extends ConsumerState<FrequentItemsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedStoreFilter;
  String? _inlineNotice;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _displayTitle(LearnedItemEntity item) {
    final stored = item.displayName?.trim() ?? '';
    if (stored.isNotEmpty) return stored;
    return ItemTextParser.toSentenceCase(item.normalizedName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final learnedAsync = ref.watch(learnedItemsProvider);
    final allLearned = learnedAsync.value ?? const <LearnedItemEntity>[];

    final availableStores = <String>{
      for (final item in allLearned) item.preferredStore,
    }.toList()..sort();

    final effectiveStoreFilter =
        _selectedStoreFilter != null &&
            availableStores.contains(_selectedStoreFilter)
        ? _selectedStoreFilter
        : null;

    final normalizedQuery = ItemTextParser.normalizeProductName(_query);
    final filtered = allLearned.where((item) {
      if (effectiveStoreFilter != null &&
          item.preferredStore != effectiveStoreFilter) {
        return false;
      }
      if (normalizedQuery.isEmpty) return true;
      final name = item.normalizedName;
      final store = ItemTextParser.normalizeProductName(item.preferredStore);
      final aisle = ItemTextParser.normalizeProductName(item.preferredAisle);
      return name.contains(normalizedQuery) ||
          store.contains(normalizedQuery) ||
          aisle.contains(normalizedQuery);
    }).toList();

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.80;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 18 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.frequentItemsTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: karritoColors.lime,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '1 toque',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: karritoColors.onLime,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const KarritoFieldLabel(AppStrings.frequentSearchLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.frequentSearchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: karritoColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: karritoColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                    color: karritoColors.accentSoft,
                    width: 1.6,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: karritoColors.accentSoft,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: AppStrings.cancelButton,
                        icon: Icon(
                          Icons.close_rounded,
                          color: karritoColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            if (availableStores.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          'Todos',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: effectiveStoreFilter == null
                                ? karritoColors.onAccent
                                : colorScheme.onSurface,
                          ),
                        ),
                        selected: effectiveStoreFilter == null,
                        showCheckmark: false,
                        selectedColor: karritoColors.accent,
                        backgroundColor: karritoColors.fieldSurface,
                        shape: const StadiumBorder(),
                        onSelected: (_) =>
                            setState(() => _selectedStoreFilter = null),
                      ),
                    ),
                    for (final store in availableStores)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            store,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: effectiveStoreFilter == store
                                  ? karritoColors.onAccent
                                  : colorScheme.onSurface,
                            ),
                          ),
                          selected: effectiveStoreFilter == store,
                          showCheckmark: false,
                          selectedColor: karritoColors.accent,
                          backgroundColor: karritoColors.fieldSurface,
                          shape: const StadiumBorder(),
                          onSelected: (_) =>
                              setState(() => _selectedStoreFilter = store),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (_inlineNotice != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: karritoColors.completedContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: karritoColors.lime,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: karritoColors.onLime,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _inlineNotice!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: karritoColors.onCompletedContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (allLearned.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      AppStrings.frequentEmptyTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.frequentEmptyBody,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: karritoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 8,
                ),
                child: Text(
                  AppStrings.frequentNoMatches,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: karritoColors.textSecondary,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final title = _displayTitle(item);
                    final countLabel = item.useCount == 1
                        ? '1 vez'
                        : '${item.useCount} veces';
                    return Material(
                      color: karritoColors.fieldSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: karritoColors.border, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          await widget.onAddFrequent(item);
                          if (context.mounted) {
                            final notice = AppStrings.addedFromFrequentNotice(
                              title,
                            );
                            setState(() {
                              _inlineNotice = notice;
                            });
                            KarritoToast.show(
                              context,
                              message: notice,
                              type: KarritoToastType.success,
                            );
                          }
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 58),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.preferredStore} · ${item.preferredAisle} · $countLabel',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  karritoColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: AppStrings.removeFrequentTooltip,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 19,
                                    color: karritoColors.textSecondary,
                                  ),
                                  onPressed: () async {
                                    await widget.onRemoveFrequent(item);
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: karritoColors.accent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                        color: karritoColors.onAccent,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Sumar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: karritoColors.onAccent,
                                        ),
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
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.doneButton),
            ),
          ],
        ),
      ),
    );
  }
}
