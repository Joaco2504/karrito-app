import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Fixed external label rendered above every Karrito form field and selector.
class KarritoFieldLabel extends StatelessWidget {
  const KarritoFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: karritoColors.textSecondary,
        height: 1.25,
      ),
    );
  }
}

/// Reusable option selector following `karrito-ui-selectors`:
/// fixed label above, distinct solid surface, 1px border, 14px radius,
/// >= 48px touch target, and a rounded `ModalBottomSheet` picker with green check.
class KarritoSelectorField<T> extends StatelessWidget {
  const KarritoSelectorField({
    required this.sheetTitle,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.labelBuilder,
    this.leadingIcon,
    super.key,
  });

  final String? label;
  final String sheetTitle;
  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(T option)? labelBuilder;
  final IconData? leadingIcon;

  String _formatOption(T option) {
    return labelBuilder != null ? labelBuilder!(option) : option.toString();
  }

  Future<void> _openSelectorSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final karritoColors = theme.extension<KarritoColors>()!;
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.7;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: Text(
                    sheetTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (itemContext, index) {
                      final option = options[index];
                      final isSelected = option == value;
                      final displayText = _formatOption(option);

                      return Material(
                        color: isSelected
                            ? karritoColors.completedContainer.withValues(
                                alpha: 0.55,
                              )
                            : karritoColors.fieldSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? karritoColors.completed.withValues(
                                    alpha: 0.55,
                                  )
                                : karritoColors.border,
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(sheetContext).pop(option),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayText,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? karritoColors
                                                      .onCompletedContainer
                                                : colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.check_rounded,
                                      color: karritoColors.completed,
                                      size: 22,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != value) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final currentText = _formatOption(value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          KarritoFieldLabel(label!),
          const SizedBox(height: 6),
        ],
        Semantics(
          button: true,
          label: label ?? sheetTitle,
          value: currentText,
          child: Material(
            color: karritoColors.fieldSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: karritoColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openSelectorSheet(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(
                          leadingIcon,
                          size: 20,
                          color: karritoColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          currentText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: karritoColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
