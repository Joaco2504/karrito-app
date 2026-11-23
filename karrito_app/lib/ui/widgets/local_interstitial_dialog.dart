import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/services/safe_url_validator.dart';
import 'karrito_bounce_button.dart';

/// Full-screen modal interstitial for local Catamarca businesses (`featured_5usd`)
/// replicating `.agents/figma_ref/10._publicidad_intersticial_local*` in both
/// Electric Mercado Light and AMOLED Dark.
class LocalInterstitialDialog extends StatefulWidget {
  const LocalInterstitialDialog({
    required this.ad,
    required this.onImpression,
    required this.onClick,
    required this.onViewPlans,
    super.key,
  });

  final CachedAdEntity ad;
  final VoidCallback onImpression;
  final VoidCallback onClick;
  final VoidCallback onViewPlans;

  static Future<void> show({
    required BuildContext context,
    required CachedAdEntity ad,
    required VoidCallback onImpression,
    required VoidCallback onClick,
    required VoidCallback onViewPlans,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: AppStrings.sponsoredLocalBadge,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) => LocalInterstitialDialog(
        ad: ad,
        onImpression: onImpression,
        onClick: onClick,
        onViewPlans: onViewPlans,
      ),
    );
  }

  @override
  State<LocalInterstitialDialog> createState() =>
      _LocalInterstitialDialogState();
}

class _LocalInterstitialDialogState extends State<LocalInterstitialDialog> {
  static const int _countdownSeconds = 3;
  int _secondsRemaining = _countdownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.onImpression();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canClose => _secondsRemaining <= 0;

  String _resolvePrimaryCtaLabel(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('wa.me') || lower.contains('whatsapp')) {
      return AppStrings.adWhatsAppCta;
    }
    if (lower.contains('maps.google') || lower.contains('goo.gl/maps')) {
      return AppStrings.adMapsCta;
    }
    return AppStrings.adOpenOfferCta;
  }

  IconData _resolvePrimaryCtaIcon(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('wa.me') || lower.contains('whatsapp')) {
      return Icons.chat_rounded;
    }
    if (lower.contains('maps.google') || lower.contains('goo.gl/maps')) {
      return Icons.near_me_rounded;
    }
    return Icons.open_in_new_rounded;
  }

  Future<void> _openOffer() async {
    final uri = SafeUrlValidator.parseSafeAdUri(widget.ad.actionUrl);
    if (uri != null) {
      widget.onClick();
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Karrito interstitial url launch skipped: $e');
      }
    } else {
      debugPrint('Karrito blocked unsafe interstitial action_url.');
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final progress =
        (_countdownSeconds - _secondsRemaining) / _countdownSeconds;

    return PopScope(
      canPop: _canClose,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar: sponsored badge + animated countdown/close pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: karritoColors.fieldSurface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: karritoColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 17,
                                color: karritoColors.accentSoft,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.sponsoredLocalBadge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        KarritoBounceButton(
                          enabled: _canClose,
                          child: Material(
                            color: _canClose
                                ? karritoColors.accent
                                : karritoColors.fieldSurface,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: _canClose
                                    ? karritoColors.accent
                                    : karritoColors.border,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _canClose
                                  ? () => Navigator.of(context).pop()
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 7,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!_canClose) ...[
                                      SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 2.2,
                                          backgroundColor: karritoColors.border,
                                          color: karritoColors.cta,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        AppStrings.adSkipIn(_secondsRemaining),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                    ] else ...[
                                      Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: karritoColors.onAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppStrings.adCloseButton,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: karritoColors.onAccent,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Main local sponsored flyer card
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: karritoColors.border,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: karritoColors.shadowTint,
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 360,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (widget.ad.interstitialUrl != null &&
                                    widget.ad.interstitialUrl!
                                        .trim()
                                        .isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: widget.ad.interstitialUrl!.trim(),
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Container(
                                      color: karritoColors.accentContainer,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.storefront_rounded,
                                        size: 64,
                                        color: karritoColors.accentSoft,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    color: karritoColors.accentContainer,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 64,
                                      color: karritoColors.accentSoft,
                                    ),
                                  ),
                                // Atmospheric gradient scrim
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.18),
                                        Colors.transparent,
                                        (isDark
                                                ? const Color(0xFF161422)
                                                : const Color(0xFF3A008C))
                                            .withValues(alpha: 0.92),
                                      ],
                                      stops: const [0.0, 0.42, 1.0],
                                    ),
                                  ),
                                ),
                                // Top-left "Oferta regional" Neon Papaya pill
                                Positioned(
                                  top: 14,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: karritoColors.cta,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          AppStrings.regionalOfferBadge
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bottom business title & Catamarca city badge
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.storefront_rounded,
                                            size: 16,
                                            color: Color(0xFFE9DDFF),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              widget.ad.city == 'Todas'
                                                  ? 'Catamarca'
                                                  : '${widget.ad.city} · Catamarca',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                                color: Color(0xFFE9DDFF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.ad.businessName,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.15,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                KarritoBounceButton(
                                  child: FilledButton.icon(
                                    onPressed: _openOffer,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: karritoColors.cta,
                                      foregroundColor: karritoColors.onCta,
                                      minimumSize: const Size.fromHeight(52),
                                    ),
                                    icon: Icon(
                                      _resolvePrimaryCtaIcon(
                                        widget.ad.actionUrl,
                                      ),
                                      size: 20,
                                    ),
                                    label: Text(
                                      _resolvePrimaryCtaLabel(
                                        widget.ad.actionUrl,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Upsell micro-card to Karrito Pro / Básico
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: karritoColors.fieldSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: karritoColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: karritoColors.accentContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              size: 19,
                              color: karritoColors.accentSoft,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.adUpsellTitle,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  AppStrings.adUpsellSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: karritoColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          KarritoBounceButton(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onViewPlans();
                              },
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 38),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                              ),
                              child: const Text(AppStrings.adViewPlansButton),
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
        ),
      ),
    );
  }
}
