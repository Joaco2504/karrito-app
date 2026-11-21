import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/share_code_helper.dart';
import 'karrito_selector_field.dart';

enum ShareOptionChoice { text, live, openSettings }

class ShareOptionsSheet {
  static Future<ShareOptionChoice?> show({
    required BuildContext context,
    required bool isGuestAccount,
  }) {
    return showModalBottomSheet<ShareOptionChoice>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final karritoColors = theme.extension<KarritoColors>()!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppStrings.shareOptionsTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _OptionCard(
                icon: Icons.text_snippet_outlined,
                title: AppStrings.shareAsTextOption,
                subtitle: AppStrings.shareAsTextSubtitle,
                onTap: () =>
                    Navigator.of(sheetContext).pop(ShareOptionChoice.text),
              ),
              const SizedBox(height: 10),
              _OptionCard(
                icon: Icons.sensors_rounded,
                title: AppStrings.shareLiveOption,
                subtitle: AppStrings.shareLiveSubtitle,
                onTap: () =>
                    Navigator.of(sheetContext).pop(ShareOptionChoice.live),
              ),
              if (isGuestAccount) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: karritoColors.warningSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: karritoColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.guestShareSuggestionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: karritoColors.warningText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.guestShareSuggestionBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(
                            sheetContext,
                          ).pop(ShareOptionChoice.openSettings),
                          child: const Text(AppStrings.goToSettingsButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;

    return Material(
      color: karritoColors.fieldSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: karritoColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: karritoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: karritoColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProLiveRequiredSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final karritoColors = theme.extension<KarritoColors>()!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sensors_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.proLiveSheetTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.proLiveSheetBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: karritoColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text(AppStrings.proLiveUnderstandButton),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LiveShareCodeSheet {
  static Future<void> show({
    required BuildContext context,
    required String listTitle,
    required String shareCode,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final karritoColors = theme.extension<KarritoColors>()!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.liveShareTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.liveShareSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: karritoColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const KarritoFieldLabel(AppStrings.shareCodeLabel),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(minHeight: 58),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: karritoColors.fieldSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: karritoColors.border, width: 1),
                ),
                child: SelectableText(
                  shareCode,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: shareCode));
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                              content: Text(AppStrings.codeCopiedNotice),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text(
                        AppStrings.copyCodeButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await SharePlus.instance.share(
                          ShareParams(
                            text: AppStrings.liveInviteMessage(
                              listTitle,
                              shareCode,
                            ),
                            subject: '$listTitle - Karrito',
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text(
                        AppStrings.sendInviteButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class JoinSharedListSheet extends StatefulWidget {
  const JoinSharedListSheet({required this.onJoin, super.key});

  final Future<String?> Function(String shareCode) onJoin;

  static Future<String?> show({
    required BuildContext context,
    required Future<String?> Function(String shareCode) onJoin,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => JoinSharedListSheet(onJoin: onJoin),
    );
  }

  @override
  State<JoinSharedListSheet> createState() => _JoinSharedListSheetState();
}

class _JoinSharedListSheetState extends State<JoinSharedListSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final normalized = ShareCodeHelper.normalizeAndValidate(
      _codeController.text,
    );
    if (normalized == null) {
      setState(() => _errorText = AppStrings.invalidShareCodeError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final errorMessage = await widget.onJoin(normalized);
    if (!mounted) return;

    if (errorMessage != null) {
      setState(() {
        _isLoading = false;
        _errorText = errorMessage;
      });
      return;
    }

    Navigator.of(context).pop(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.joinSheetTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const KarritoFieldLabel(AppStrings.joinCodeLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _codeController,
            enabled: !_isLoading,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.joinCodeHint,
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancelButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.joinSubmitButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
