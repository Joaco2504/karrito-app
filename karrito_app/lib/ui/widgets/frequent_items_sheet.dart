import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/services/item_text_parser.dart';
import '../../providers/shopping_providers.dart';
import 'karrito_selector_field.dart';

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

    final normalizedQuery = ItemTextParser.normalizeProductName(_query);
    final filtered = normalizedQuery.isEmpty
        ? allLearned
        : allLearned.where((item) {
            final name = item.normalizedName;
            final store = ItemTextParser.normalizeProductName(
              item.preferredStore,
            );
            final aisle = ItemTextParser.normalizeProductName(
              item.preferredAisle,
            );
            return name.contains(normalizedQuery) ||
                store.contains(normalizedQuery) ||
                aisle.contains(normalizedQuery);
          }).toList();

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppStrings.frequentItemsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const KarritoFieldLabel(AppStrings.frequentSearchLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.frequentSearchHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: karritoColors.textSecondary,
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
            if (_inlineNotice != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
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
                        _inlineNotice!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: karritoColors.onCompletedContainer,
                          fontWeight: FontWeight.w600,
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
                    return Material(
                      color: karritoColors.fieldSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: karritoColors.border, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          await widget.onAddFrequent(item);
                          if (mounted) {
                            setState(() {
                              _inlineNotice =
                                  AppStrings.addedFromFrequentNotice(title);
                            });
                          }
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 54),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
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
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.preferredStore} · ${item.preferredAisle}',
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
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: karritoColors.textSecondary,
                                  ),
                                  onPressed: () async {
                                    await widget.onRemoveFrequent(item);
                                  },
                                ),
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: colorScheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
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
