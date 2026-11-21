import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';

class ListSelectorSheet extends StatelessWidget {
  const ListSelectorSheet({
    required this.lists,
    required this.activeListId,
    required this.onSelect,
    required this.onCreate,
    required this.onRename,
    required this.onDelete,
    required this.onShareLive,
    required this.onJoinWithCode,
    super.key,
  });

  final List<ShoppingListEntity> lists;
  final String activeListId;
  final ValueChanged<String> onSelect;
  final Future<bool> Function(String title) onCreate;
  final Future<bool> Function(String listId, String title) onRename;
  final Future<bool> Function(String listId) onDelete;
  final VoidCallback onShareLive;
  final VoidCallback onJoinWithCode;

  static Future<void> show({
    required BuildContext context,
    required List<ShoppingListEntity> lists,
    required String activeListId,
    required ValueChanged<String> onSelect,
    required Future<bool> Function(String title) onCreate,
    required Future<bool> Function(String listId, String title) onRename,
    required Future<bool> Function(String listId) onDelete,
    required VoidCallback onShareLive,
    required VoidCallback onJoinWithCode,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ListSelectorSheet(
        lists: lists,
        activeListId: activeListId,
        onSelect: onSelect,
        onCreate: onCreate,
        onRename: onRename,
        onDelete: onDelete,
        onShareLive: onShareLive,
        onJoinWithCode: onJoinWithCode,
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();
    final created = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.newListTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: AppStrings.newListHint),
            onSubmitted: (val) => Navigator.of(dialogContext).pop(val),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text(AppStrings.createListButton),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (created != null && context.mounted) {
      final ok = await onCreate(created);
      if (ok && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    ShoppingListEntity list,
  ) async {
    final controller = TextEditingController(text: list.title);
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.renameListTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (val) => Navigator.of(dialogContext).pop(val),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text(AppStrings.saveListButton),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (updated != null && context.mounted) {
      final ok = await onRename(list.id, updated);
      if (ok && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShoppingListEntity list,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.deleteListButton),
          content: Text(
            list.isJoinedRemote
                ? AppStrings.leaveSharedListConfirmBody(list.title)
                : AppStrings.deleteListConfirmBody(list.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppStrings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: const Text(AppStrings.deleteButton),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final ok = await onDelete(list.id);
      if (ok && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownedCount = lists.where((l) => !l.isJoinedRemote).length;
    final canCreate = ownedCount < StoreHierarchy.maxActiveListsPhase2;
    final canDelete = lists.length > 1;
    final colorScheme = Theme.of(context).colorScheme;
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tus listas ($ownedCount/${StoreHierarchy.maxActiveListsPhase2})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (canCreate)
                      FilledButton.icon(
                        onPressed: () => _showCreateDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(AppStrings.newListTitle),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...lists.map((list) {
                final isSelected = list.id == activeListId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: isSelected
                        ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                        : null,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              list.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (list.isShared) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: karritoColors.completedContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.liveListBadge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: karritoColors.onCompletedContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: list.isShared && list.shareCode != null
                          ? Text(
                              'Código: ${list.shareCode}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: karritoColors.textSecondary,
                                  ),
                            )
                          : null,
                      onTap: () {
                        onSelect(list.id);
                        Navigator.of(context).pop();
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!list.isJoinedRemote)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: AppStrings.renameListTitle,
                              onPressed: () => _showRenameDialog(context, list),
                            ),
                          if (canDelete)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              tooltip: AppStrings.deleteListButton,
                              onPressed: () => _confirmDelete(context, list),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (!canCreate) ...[
                const SizedBox(height: 2),
                Text(
                  AppStrings.maxListsReached,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onShareLive();
                },
                icon: const Icon(Icons.sensors_rounded, size: 20),
                label: const Text(AppStrings.shareLiveOption),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onJoinWithCode();
                },
                icon: const Icon(Icons.group_add_outlined, size: 20),
                label: const Text(AppStrings.joinWithCodeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
