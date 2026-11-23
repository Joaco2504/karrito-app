import 'package:flutter/material.dart';

/// Custom semantic colors for Karrito extracted directly from
/// `.agents/figma_ref/electric_mercado_1/DESIGN.md` (Light) and
/// `.agents/figma_ref/electric_mercado_2/DESIGN.md` (Dark AMOLED).
@immutable
class KarritoColors extends ThemeExtension<KarritoColors> {
  const KarritoColors({
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.cta,
    required this.onCta,
    required this.ctaContainer,
    required this.onCtaContainer,
    required this.lime,
    required this.onLime,
    required this.completed,
    required this.completedContainer,
    required this.onCompletedContainer,
    required this.checkedTileSurface,
    required this.checkedTileBorder,
    required this.aisleCardSurface,
    required this.border,
    required this.textSecondary,
    required this.fieldSurface,
    required this.warningSurface,
    required this.warningText,
    required this.softDestructive,
    required this.shadowTint,
  });

  /// Deep Violet Berry (Light `#531CB3`) / Electric Violet (Dark `#8B5CF6`).
  final Color accent;
  final Color onAccent;

  /// High-contrast violet accent readable on canvas and cards.
  final Color accentSoft;
  final Color accentContainer;
  final Color onAccentContainer;

  /// Neon Papaya (`#FF6238`) — high-energy secondary CTA, drag highlight, alerts.
  final Color cta;
  final Color onCta;
  final Color ctaContainer;
  final Color onCtaContainer;

  /// Electric Lime (`#ABF926` Light / `#CCFF00` Dark) — live tags & highlights.
  final Color lime;
  final Color onLime;

  /// Readable completed status ink & containers.
  final Color completed;
  final Color completedContainer;
  final Color onCompletedContainer;

  /// Tinted surface & border for checked shopping items.
  final Color checkedTileSurface;
  final Color checkedTileBorder;

  /// Outer tonal container for aisle cards (`#F8F1FF` Light / `#161422` Dark).
  final Color aisleCardSurface;

  final Color border;
  final Color textSecondary;
  final Color fieldSurface;
  final Color warningSurface;
  final Color warningText;
  final Color softDestructive;
  final Color shadowTint;

  static const light = KarritoColors(
    accent: Color(0xFF531CB3),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFF3A008C),
    accentContainer: Color(0xFFE9DDFF),
    onAccentContainer: Color(0xFF23005B),
    cta: Color(0xFFFF6238),
    onCta: Color(0xFFFFFFFF),
    ctaContainer: Color(0xFFFFDBD2),
    onCtaContainer: Color(0xFF881F00),
    lime: Color(0xFFABF926),
    onLime: Color(0xFF111F00),
    completed: Color(0xFF314D00),
    completedContainer: Color(0xFFECFFD0),
    onCompletedContainer: Color(0xFF203500),
    checkedTileSurface: Color(0xFFF2EBFF),
    checkedTileBorder: Color(0xFFD1BCFF),
    aisleCardSurface: Color(0xFFF8F1FF),
    border: Color(0xFFCBC3D6),
    textSecondary: Color(0xFF4A4454),
    fieldSurface: Color(0xFFF2EBFF),
    warningSurface: Color(0xFFFFDBD2),
    warningText: Color(0xFF881F00),
    softDestructive: Color(0xFFBA1A1A),
    shadowTint: Color(0x14531CB3),
  );

  static const dark = KarritoColors(
    accent: Color(0xFF8B5CF6),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFD0BCFF),
    accentContainer: Color(0xFF2E1E4E),
    onAccentContainer: Color(0xFFE9DDFF),
    cta: Color(0xFFFF6238),
    onCta: Color(0xFFFFFFFF),
    ctaContainer: Color(0xFF2D1815),
    onCtaContainer: Color(0xFFFFB4A1),
    lime: Color(0xFFCCFF00),
    onLime: Color(0xFF161E00),
    completed: Color(0xFFABD600),
    completedContainer: Color(0xFF1F2B0D),
    onCompletedContainer: Color(0xFFC3F400),
    checkedTileSurface: Color(0xFF221A36),
    checkedTileBorder: Color(0xFF4A3778),
    aisleCardSurface: Color(0xFF161422),
    border: Color(0xFF494454),
    textSecondary: Color(0xFFCBC3D7),
    fieldSurface: Color(0xFF252135),
    warningSurface: Color(0xFF2D1815),
    warningText: Color(0xFFFFB4A1),
    softDestructive: Color(0xFFFFB4AB),
    shadowTint: Color(0x6605030B),
  );

  @override
  KarritoColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? cta,
    Color? onCta,
    Color? ctaContainer,
    Color? onCtaContainer,
    Color? lime,
    Color? onLime,
    Color? completed,
    Color? completedContainer,
    Color? onCompletedContainer,
    Color? checkedTileSurface,
    Color? checkedTileBorder,
    Color? aisleCardSurface,
    Color? border,
    Color? textSecondary,
    Color? fieldSurface,
    Color? warningSurface,
    Color? warningText,
    Color? softDestructive,
    Color? shadowTint,
  }) {
    return KarritoColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
      cta: cta ?? this.cta,
      onCta: onCta ?? this.onCta,
      ctaContainer: ctaContainer ?? this.ctaContainer,
      onCtaContainer: onCtaContainer ?? this.onCtaContainer,
      lime: lime ?? this.lime,
      onLime: onLime ?? this.onLime,
      completed: completed ?? this.completed,
      completedContainer: completedContainer ?? this.completedContainer,
      onCompletedContainer: onCompletedContainer ?? this.onCompletedContainer,
      checkedTileSurface: checkedTileSurface ?? this.checkedTileSurface,
      checkedTileBorder: checkedTileBorder ?? this.checkedTileBorder,
      aisleCardSurface: aisleCardSurface ?? this.aisleCardSurface,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      fieldSurface: fieldSurface ?? this.fieldSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      warningText: warningText ?? this.warningText,
      softDestructive: softDestructive ?? this.softDestructive,
      shadowTint: shadowTint ?? this.shadowTint,
    );
  }

  @override
  KarritoColors lerp(ThemeExtension<KarritoColors>? other, double t) {
    if (other is! KarritoColors) return this;
    return KarritoColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      onAccentContainer: Color.lerp(
        onAccentContainer,
        other.onAccentContainer,
        t,
      )!,
      cta: Color.lerp(cta, other.cta, t)!,
      onCta: Color.lerp(onCta, other.onCta, t)!,
      ctaContainer: Color.lerp(ctaContainer, other.ctaContainer, t)!,
      onCtaContainer: Color.lerp(onCtaContainer, other.onCtaContainer, t)!,
      lime: Color.lerp(lime, other.lime, t)!,
      onLime: Color.lerp(onLime, other.onLime, t)!,
      completed: Color.lerp(completed, other.completed, t)!,
      completedContainer: Color.lerp(
        completedContainer,
        other.completedContainer,
        t,
      )!,
      onCompletedContainer: Color.lerp(
        onCompletedContainer,
        other.onCompletedContainer,
        t,
      )!,
      checkedTileSurface: Color.lerp(
        checkedTileSurface,
        other.checkedTileSurface,
        t,
      )!,
      checkedTileBorder: Color.lerp(
        checkedTileBorder,
        other.checkedTileBorder,
        t,
      )!,
      aisleCardSurface: Color.lerp(
        aisleCardSurface,
        other.aisleCardSurface,
        t,
      )!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      fieldSurface: Color.lerp(fieldSurface, other.fieldSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      softDestructive: Color.lerp(softDestructive, other.softDestructive, t)!,
      shadowTint: Color.lerp(shadowTint, other.shadowTint, t)!,
    );
  }
}

/// Material 3 Light & Dark themes for Karrito using the exact color tokens from
/// `electric_mercado_1/DESIGN.md` (Light) and `electric_mercado_2/DESIGN.md` (Dark).
class AppTheme {
  AppTheme._();

  // Electric Mercado 1 — Light palette
  static const Color lightBackground = Color(0xFFFDF7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightFieldSurface = Color(0xFFF2EBFF);
  static const Color lightPrimary = Color(0xFF531CB3);
  static const Color lightSecondary = Color(0xFFFF6238);
  static const Color lightLime = Color(0xFFABF926);
  static const Color lightCompleted = Color(0xFF314D00);
  static const Color lightTextPrimary = Color(0xFF1D1A28);
  static const Color lightTextSecondary = Color(0xFF4A4454);
  static const Color lightBorder = Color(0xFFCBC3D6);
  static const Color lightSwitchTrackOff = Color(0xFFE6DFF4);
  static const Color lightSwitchBorderOff = Color(0xFFCBC3D6);
  static const Color lightSwitchThumbOn = Color(0xFFFFFFFF);

  // Electric Mercado 2 — Dark AMOLED palette
  static const Color darkBackground = Color(0xFF12111A);
  static const Color darkSurface = Color(0xFF1E1B29);
  static const Color darkFieldSurface = Color(0xFF252135);
  static const Color darkPrimary = Color(0xFF8B5CF6);
  static const Color darkPrimaryFocus = Color(0xFFA078FF);
  static const Color darkSecondary = Color(0xFFFF6238);
  static const Color darkLime = Color(0xFFCCFF00);
  static const Color darkTextPrimary = Color(0xFFE5E0EE);
  static const Color darkTextSecondary = Color(0xFFCBC3D7);
  static const Color darkBorder = Color(0xFF494454);
  static const Color darkSwitchTrackOff = Color(0xFF161422);
  static const Color darkSwitchBorderOff = Color(0xFF494454);
  static const Color darkSwitchThumbOff = Color(0xFFE5E0EE);
  static const Color darkSwitchThumbOn = Color(0xFFCCFF00);

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE9DDFF),
      onPrimaryContainer: Color(0xFF23005B),
      secondary: lightSecondary,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFDBD2),
      onSecondaryContainer: Color(0xFF881F00),
      tertiary: lightLime,
      onTertiary: Color(0xFF111F00),
      tertiaryContainer: Color(0xFFECFFD0),
      onTertiaryContainer: Color(0xFF203500),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F1FF),
      surfaceContainer: lightFieldSurface,
      surfaceContainerHigh: Color(0xFFECE5FA),
      surfaceContainerHighest: Color(0xFFE6DFF4),
      outline: Color(0xFF7B7485),
      outlineVariant: lightBorder,
      shadow: Color(0x18531CB3),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: lightBackground,
      cardColor: lightSurface,
      borderColor: lightBorder,
      focusBorderColor: lightPrimary,
      textPrimary: lightTextPrimary,
      textSecondary: lightTextSecondary,
      karritoColors: KarritoColors.light,
      switchTrackOff: lightSwitchTrackOff,
      switchBorderOff: lightSwitchBorderOff,
      switchThumbOff: lightTextSecondary,
      switchThumbOn: lightSwitchThumbOn,
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF2E1E4E),
      onPrimaryContainer: Color(0xFFE9DDFF),
      secondary: darkSecondary,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF2D1815),
      onSecondaryContainer: Color(0xFFFFB4A1),
      tertiary: darkLime,
      onTertiary: Color(0xFF161E00),
      tertiaryContainer: Color(0xFF1F2B0D),
      onTertiaryContainer: Color(0xFFC3F400),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      surfaceContainerLowest: Color(0xFF0E0D16),
      surfaceContainerLow: Color(0xFF161422),
      surfaceContainer: darkSurface,
      surfaceContainerHigh: darkFieldSurface,
      surfaceContainerHighest: Color(0xFF35343E),
      outline: Color(0xFF958EA0),
      outlineVariant: darkBorder,
      shadow: Color(0x6605030B),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: darkBackground,
      cardColor: darkSurface,
      borderColor: darkBorder,
      focusBorderColor: darkPrimaryFocus,
      textPrimary: darkTextPrimary,
      textSecondary: darkTextSecondary,
      karritoColors: KarritoColors.dark,
      switchTrackOff: darkSwitchTrackOff,
      switchBorderOff: darkSwitchBorderOff,
      switchThumbOff: darkSwitchThumbOff,
      switchThumbOn: darkSwitchThumbOn,
    );
  }

  static const String fontFamily = 'Plus Jakarta Sans';

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color borderColor,
    required Color focusBorderColor,
    required Color textPrimary,
    required Color textSecondary,
    required KarritoColors karritoColors,
    required Color switchTrackOff,
    required Color switchBorderOff,
    required Color switchThumbOff,
    required Color switchThumbOn,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: <ThemeExtension<dynamic>>[karritoColors],
    );

    final textTheme = base.textTheme
        .copyWith(
          displayLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 48 / 40,
            letterSpacing: -1.0,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 34 / 26,
            letterSpacing: -0.39,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 30 / 22,
            letterSpacing: -0.22,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 24 / 18,
            letterSpacing: 0,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 26 / 20,
            letterSpacing: -0.2,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 22 / 16,
            letterSpacing: 0,
            color: textPrimary,
          ),
          titleSmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            height: 20 / 14.5,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 26 / 17,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 23 / 15,
            color: textPrimary,
          ),
          bodySmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 20 / 13,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 18 / 14,
            letterSpacing: 0.14,
            color: textPrimary,
          ),
          labelMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 16 / 12,
            letterSpacing: 0.24,
            color: textPrimary,
          ),
          labelSmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 14 / 11,
            letterSpacing: 0.33,
            color: textSecondary,
          ),
        )
        .apply(fontFamily: fontFamily);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: borderColor,
        dragHandleSize: const Size(42, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor.withValues(alpha: 0.65),
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return karritoColors.accent;
          }
          return switchTrackOff;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return switchBorderOff;
        }),
        trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return 0.0;
          }
          return 1.5;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return switchThumbOn;
          }
          return switchThumbOff;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 46)),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: borderColor, width: 1),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return karritoColors.accent;
            }
            return karritoColors.fieldSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return karritoColors.onAccent;
            }
            return textPrimary;
          }),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontFamily: fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: karritoColors.fieldSurface,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: TextStyle(fontFamily: fontFamily, color: textSecondary),
        labelStyle: TextStyle(fontFamily: fontFamily, color: textSecondary),
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: focusBorderColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: borderColor, width: 1.2),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: karritoColors.accentSoft,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: karritoColors.accentSoft,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: cardColor,
        selectedColor: karritoColors.accent,
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
      ),
    );
  }
}
