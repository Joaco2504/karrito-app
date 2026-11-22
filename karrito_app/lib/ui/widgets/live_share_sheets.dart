import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/share_code_helper.dart';
import '../screens/qr_scanner_screen.dart';
import 'karrito_bounce_button.dart';
import 'karrito_selector_field.dart';
import 'karrito_toast.dart';

enum ShareOptionChoice { text, live, join, openSettings }

class ShareOptionsSheet {
  static Future<ShareOptionChoice?> show({
    required BuildContext context,
    required bool isGuestAccount,
  }) {
    return showModalBottomSheet<ShareOptionChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final karritoColors = theme.extension<KarritoColors>()!;

        return SingleChildScrollView(
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
                    fontWeight: FontWeight.w800,
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
                badgeText: AppStrings.liveListBadge,
                onTap: () =>
                    Navigator.of(sheetContext).pop(ShareOptionChoice.live),
              ),
              const SizedBox(height: 10),
              _OptionCard(
                icon: Icons.qr_code_scanner_rounded,
                title: AppStrings.shareJoinOption,
                subtitle: AppStrings.shareJoinSubtitle,
                onTap: () =>
                    Navigator.of(sheetContext).pop(ShareOptionChoice.join),
              ),
              if (isGuestAccount) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: karritoColors.warningSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: karritoColors.cta.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.guestShareSuggestionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: karritoColors.warningText,
                          fontWeight: FontWeight.w800,
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
    this.badgeText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return Material(
      color: karritoColors.fieldSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: karritoColors.accentContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: karritoColors.accentSoft, size: 22),
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: karritoColors.lime,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: karritoColors.onLime,
                              ),
                            ),
                          ),
                        ],
                      ],
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
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final karritoColors = theme.extension<KarritoColors>()!;
        final isDark = theme.brightness == Brightness.dark;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [Color(0xFF251842), Color(0xFF1A132E)]
                        : const [Color(0xFFF2EBFF), Color(0xFFE9DDFF)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: karritoColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                            'Karrito Pro',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: karritoColors.onLime,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.sensors_rounded,
                          color: karritoColors.accentSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.proLiveSheetTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.proLiveSheetBody,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: karritoColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              KarritoBounceButton(
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text(AppStrings.proLiveUnderstandButton),
                ),
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
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final karritoColors = theme.extension<KarritoColors>()!;
        final isDark = theme.brightness == Brightness.dark;
        final chars = shareCode.trim().split('');
        final invitePreview = AppStrings.liveInviteMessage(
          listTitle,
          shareCode,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF2D1B54), Color(0xFF1E1338)]
                      : const [Color(0xFF531CB3), Color(0xFF3A008C)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: isDark
                    ? Border.all(color: const Color(0xFF432D73))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: karritoColors.accent.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -28,
                    bottom: -28,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA078FF).withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                      AppStrings.liveListBadge.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: karritoColors.onLime,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppStrings.liveShareTitle,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.liveShareSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFFE9DDFF),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sync_alt_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: ShareCodeHelper.buildJoinUri(shareCode),
                                  version: QrVersions.auto,
                                  size: 172,
                                  gapless: true,
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.all(6),
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF1D1A28),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF1D1A28),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.liveQrCaption,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFFE9DDFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.35 : 0.18,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                AppStrings.shareCodeLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFFD0BCFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Semantics(
                                label: shareCode,
                                child: Row(
                                  children: [
                                    for (var i = 0; i < chars.length; i++) ...[
                                      if (i > 0) const SizedBox(width: 6),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF171026)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: isDark
                                                ? Border.all(
                                                    color: const Color(
                                                      0xFF4B377A,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          child: Text(
                                            chars[i],
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF3A008C),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              KarritoBounceButton(
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: shareCode),
                                    );
                                    if (sheetContext.mounted) {
                                      KarritoToast.show(
                                        sheetContext,
                                        message: AppStrings.codeCopiedNotice,
                                        type: KarritoToastType.success,
                                      );
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.14,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(AppStrings.copyCodeButton),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        KarritoBounceButton(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: karritoColors.cta,
                              foregroundColor: karritoColors.onCta,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () async {
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: invitePreview,
                                  subject: '$listTitle - Karrito',
                                ),
                              );
                            },
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text(AppStrings.sendInviteButton),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '"$invitePreview"',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  Future<void> _submit([String? overrideCode]) async {
    final source = overrideCode ?? _codeController.text;
    final normalized = ShareCodeHelper.extractCodeFromQrOrText(source);
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

  Future<void> _scanQrCode() async {
    if (_isLoading) return;
    final scannedCode = await QrCodeScannerScreen.open(context);
    if (!mounted || scannedCode == null) return;
    _codeController.text = scannedCode;
    await _submit(scannedCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.joinSheetTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w800,
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
          const SizedBox(height: 12),
          KarritoBounceButton(
            enabled: !_isLoading,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _scanQrCode,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text(AppStrings.scanQrButton),
            ),
          ),
          const SizedBox(height: 16),
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
                child: KarritoBounceButton(
                  enabled: !_isLoading,
                  child: FilledButton(
                    onPressed: _isLoading ? null : () => _submit(),
                    child: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text(AppStrings.joinSubmitButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
