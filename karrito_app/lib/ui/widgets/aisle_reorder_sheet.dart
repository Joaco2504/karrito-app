import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import 'karrito_bounce_button.dart';

class AisleReorderSheet extends StatefulWidget {
  const AisleReorderSheet({
    required this.storeCategory,
    required this.initialAisles,
    super.key,
  });

  final String storeCategory;
  final List<String> initialAisles;

  static Future<List<String>?> show({
    required BuildContext context,
    required String storeCategory,
    required List<String> initialAisles,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AisleReorderSheet(
        storeCategory: storeCategory,
        initialAisles: initialAisles,
      ),
    );
  }

  @override
  State<AisleReorderSheet> createState() => _AisleReorderSheetState();
}

class _AisleReorderSheetState extends State<AisleReorderSheet> {
  late final List<String> _aisles;

  @override
  void initState() {
    super.initState();
    _aisles = List<String>.from(widget.initialAisles);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final moved = _aisles.removeAt(oldIndex);
      _aisles.insert(newIndex, moved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.reorderAislesTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.reorderAislesSubtitle(widget.storeCategory),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: karritoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: _aisles.length,
                onReorderItem: _onReorderItem,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final aisle = _aisles[index];
                  return Padding(
                    key: ValueKey<String>('reorder::$aisle'),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: karritoColors.fieldSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: karritoColors.border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                aisle,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.drag_handle_rounded,
                              color: karritoColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: KarritoBounceButton(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        AppStrings.cancelButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KarritoBounceButton(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_aisles),
                      child: const Text(
                        AppStrings.saveOrderButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
