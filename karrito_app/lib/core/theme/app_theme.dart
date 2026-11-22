import 'package:flutter/material.dart';

/// Custom semantic colors for Karrito following the official "Electric Mercado"
/// design system (`.agents/figma_ref/DESIGN.md` & `karrito-ui-selectors`).
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
    required this.border,
    required this.textSecondary,
    required this.fieldSurface,
    required this.warningSurface,
    required this.warningText,
    required this.softDestructive,
    required this.shadowTint,
  });

  /// Deep Violet Berry (Light) / Electric Violet (Dark) — navigation, active tabs,
  /// primary buttons, checkboxes, toggles, focus rings.
  final Color accent;
  final Color onAccent;

  /// High-contrast violet text/icon accent readable directly on card & canvas surfaces.
  final Color accentSoft;
  final Color accentContainer;
  final Color onAccentContainer;

  /// Neon Papaya — high-energy secondary / conversion CTA accent.
  final Color cta;
  final Color onCta;
  final Color ctaContainer;
  final Color onCtaContainer;

  /// Electric Lime — freshness badges, 1-tap highlights, live tags.
  final Color lime;
  final Color onLime;

  /// Readable completed checkmark/status ink & containers.
  final Color completed;
  final Color completedContainer;
  final Color onCompletedContainer;

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
    accentSoft: Color(0xFF531CB3),
    accentContainer: Color(0xFFE9DDFF),
    onAccentContainer: Color(0xFF23005B),
    cta: Color(0xFFFF6238),
    onCta: Color(0xFF13101E),
    ctaContainer: Color(0xFFFFDBD2),
    onCtaContainer: Color(0xFF7A2006),
    lime: Color(0xFF9AE600),
    onLime: Color(0xFF13101E),
    completed: Color(0xFF315C00),
    completedContainer: Color(0xFFECFFD0),
    onCompletedContainer: Color(0xFF203A00),
    border: Color(0xFFD8D0E6),
    textSecondary: Color(0xFF4A4454),
    fieldSurface: Color(0xFFF2EFFB),
    warningSurface: Color(0xFFFFDBD2),
    warningText: Color(0xFF7A2006),
    softDestructive: Color(0xFFBA1A1A),
    shadowTint: Color(0x12531CB3),
  );

  static const dark = KarritoColors(
    accent: Color(0xFF7438F5),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFD1BCFF),
    accentContainer: Color(0xFF2E1A5E),
    onAccentContainer: Color(0xFFE9DDFF),
    cta: Color(0xFFFF6238),
    onCta: Color(0xFF13101E),
    ctaContainer: Color(0xFF3D1D17),
    onCtaContainer: Color(0xFFFFB8A6),
    lime: Color(0xFF9AE600),
    onLime: Color(0xFF13101E),
    completed: Color(0xFF9AE600),
    completedContainer: Color(0xFF1F3008),
    onCompletedContainer: Color(0xFFC8FA6B),
    border: Color(0xFF352B4D),
    textSecondary: Color(0xFFB9B0C9),
    fieldSurface: Color(0xFF251D38),
    warningSurface: Color(0xFF3D1D17),
    warningText: Color(0xFFFFB8A6),
    softDestructive: Color(0xFFFFB4AB),
    shadowTint: Color(0x5205020A),
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

/// Material 3 Light & Dark themes for Karrito using the official
/// **Electric Mercado** design system (`.agents/figma_ref/DESIGN.md`).
class AppTheme {
  AppTheme._();

  // Electric Mercado — Light palette
  static const Color lightBackground = Color(0xFFF9F8F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightFieldSurface = Color(0xFFF2EFFB);
  static const Color lightPrimary = Color(0xFF531CB3);
  static const Color lightSecondary = Color(0xFFFF6238);
  static const Color lightLime = Color(0xFF9AE600);
  static const Color lightCompleted = Color(0xFF315C00);
  static const Color lightTextPrimary = Color(0xFF13101E);
  static const Color lightTextSecondary = Color(0xFF4A4454);
  static const Color lightBorder = Color(0xFFD8D0E6);
  static const Color lightSwitchTrackOff = Color(0xFFE4DDF2);
  static const Color lightSwitchBorderOff = Color(0xFFBDB2D4);

  // Electric Mercado — Dark palette
  static const Color darkBackground = Color(0xFF0F0B1A);
  static const Color darkSurface = Color(0xFF1A1429);
  static const Color darkFieldSurface = Color(0xFF251D38);
  static const Color darkPrimary = Color(0xFF7438F5);
  static const Color darkPrimaryFocus = Color(0xFF9D6BFF);
  static const Color darkSecondary = Color(0xFFFF6238);
  static const Color darkLime = Color(0xFF9AE600);
  static const Color darkTextPrimary = Color(0xFFF5EEFF);
  static const Color darkTextSecondary = Color(0xFFB9B0C9);
  static const Color darkBorder = Color(0xFF352B4D);
  static const Color darkSwitchTrackOff = Color(0xFF251D38);
  static const Color darkSwitchBorderOff = Color(0xFF4E426E);
  static const Color darkSwitchThumbOff = Color(0xFFE4DCF5);

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE9DDFF),
      onPrimaryContainer: Color(0xFF23005B),
      secondary: lightSecondary,
      onSecondary: Color(0xFF13101E),
      secondaryContainer: Color(0xFFFFDBD2),
      onSecondaryContainer: Color(0xFF7A2006),
      tertiary: lightLime,
      onTertiary: Color(0xFF13101E),
      tertiaryContainer: Color(0xFFECFFD0),
      onTertiaryContainer: Color(0xFF203A00),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF8C1010),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F1FF),
      surfaceContainer: lightFieldSurface,
      surfaceContainerHigh: Color(0xFFECE5FA),
      surfaceContainerHighest: Color(0xFFE6DFF4),
      outline: lightBorder,
      outlineVariant: Color(0xFFE5DFEE),
      shadow: Color(0x1A531CB3),
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
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF2E1A5E),
      onPrimaryContainer: Color(0xFFE9DDFF),
      secondary: darkSecondary,
      onSecondary: Color(0xFF13101E),
      secondaryContainer: Color(0xFF3D1D17),
      onSecondaryContainer: Color(0xFFFFB8A6),
      tertiary: darkLime,
      onTertiary: Color(0xFF13101E),
      tertiaryContainer: Color(0xFF1F3008),
      onTertiaryContainer: Color(0xFFC8FA6B),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF5C0A0A),
      errorContainer: Color(0xFF5C1414),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      surfaceContainerLowest: darkBackground,
      surfaceContainerLow: Color(0xFF151023),
      surfaceContainer: darkSurface,
      surfaceContainerHigh: darkFieldSurface,
      surfaceContainerHighest: darkBorder,
      outline: darkBorder,
      outlineVariant: Color(0xFF2D2442),
      shadow: Color(0x5C05020A),
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
    );
  }

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
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: <ThemeExtension<dynamic>>[karritoColors],
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
          color: textPrimary,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
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
          borderRadius: BorderRadius.circular(24),
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
        color: borderColor,
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
            return karritoColors.onAccent;
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
            TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: karritoColors.fieldSurface,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: TextStyle(color: textSecondary),
        labelStyle: TextStyle(color: textSecondary),
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: focusBorderColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
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
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: karritoColors.accentSoft,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
