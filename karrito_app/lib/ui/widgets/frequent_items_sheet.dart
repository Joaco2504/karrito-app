import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/store_visuals.dart';
import '../../data/local/app_database.dart';
import '../../domain/services/item_text_parser.dart';
import '../../providers/shopping_providers.dart';
import 'karrito_bounce_button.dart';
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
  final Set<String> _addedKeysThisSession = <String>{};
  int _sessionAddedCount = 0;
  String _query = '';
  String? _selectedStoreFilter;

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
    final isDark = theme.brightness == Brightness.dark;
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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.84;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 2, 16, 18 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: karritoColors.accentContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 21,
                      color: karritoColors.accentSoft,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                AppStrings.frequentItemsTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                '1 toque',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: karritoColors.onLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.frequentItemsSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: karritoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.doneButton,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: karritoColors.fieldSurface,
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 19,
                      color: karritoColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
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
                          avatar: Icon(
                            StoreVisuals.forStore(store).icon,
                            size: 15,
                            color: effectiveStoreFilter == store
                                ? karritoColors.onAccent
                                : karritoColors.textSecondary,
                          ),
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
                        ? 'Comprado 1 vez'
                        : 'Comprado ${item.useCount} veces';
                    final wasAdded = _addedKeysThisSession.contains(
                      item.normalizedName,
                    );
                    final aisleVisual = StoreVisuals.forAisle(
                      item.preferredAisle,
                    );

                    return Material(
                      color: wasAdded
                          ? karritoColors.checkedTileSurface
                          : karritoColors.fieldSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: wasAdded
                              ? karritoColors.accentSoft.withValues(alpha: 0.6)
                              : karritoColors.border,
                          width: 1,
                        ),
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
                              _addedKeysThisSession.add(item.normalizedName);
                              _sessionAddedCount++;
                            });
                            KarritoToast.show(
                              context,
                              message: notice,
                              type: KarritoToastType.success,
                            );
                          }
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 64),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: aisleVisual.color.withValues(
                                      alpha: isDark ? 0.22 : 0.16,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    aisleVisual.icon,
                                    size: 20,
                                    color: aisleVisual.color,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.repeat_rounded,
                                            size: 13,
                                            color: karritoColors.cta,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '$countLabel · ${item.preferredAisle}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: karritoColors
                                                        .textSecondary,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: AppStrings.removeFrequentTooltip,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: karritoColors.textSecondary,
                                  ),
                                  onPressed: () async {
                                    await widget.onRemoveFrequent(item);
                                  },
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: wasAdded
                                        ? karritoColors.accentContainer
                                        : karritoColors.accent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        wasAdded
                                            ? Icons.check_rounded
                                            : Icons.add_rounded,
                                        size: 15,
                                        color: wasAdded
                                            ? karritoColors.onAccentContainer
                                            : karritoColors.onAccent,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        wasAdded
                                            ? AppStrings.frequentAddedBadge
                                            : 'Sumar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: wasAdded
                                              ? karritoColors.onAccentContainer
                                              : karritoColors.onAccent,
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
            const SizedBox(height: 14),
            KarritoBounceButton(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 19),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _sessionAddedCount > 0
                            ? AppStrings.frequentDoneButton
                            : AppStrings.doneButton,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_sessionAddedCount > 0) ...[
                      const SizedBox(width: 10),
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
                          AppStrings.frequentSessionCount(_sessionAddedCount),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: karritoColors.onLime,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
