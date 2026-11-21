import 'package:flutter/material.dart';

/// Custom semantic colors for Karrito beyond Material 3 defaults (60-30-10).
@immutable
class KarritoColors extends ThemeExtension<KarritoColors> {
  const KarritoColors({
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.completed,
    required this.completedContainer,
    required this.onCompletedContainer,
    required this.border,
    required this.textSecondary,
    required this.fieldSurface,
    required this.warningSurface,
    required this.warningText,
    required this.softDestructive,
  });

  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;
  final Color completed;
  final Color completedContainer;
  final Color onCompletedContainer;
  final Color border;
  final Color textSecondary;
  final Color fieldSurface;
  final Color warningSurface;
  final Color warningText;
  final Color softDestructive;

  static const light = KarritoColors(
    accent: Color(0xFF00C2B5),
    onAccent: Color(0xFF151515),
    accentContainer: Color(0xFFD6F5F2),
    onAccentContainer: Color(0xFF0C4F4A),
    completed: Color(0xFF1E8E6E),
    completedContainer: Color(0xFFDCEFE8),
    onCompletedContainer: Color(0xFF115240),
    border: Color(0xFFD8CCB4),
    textSecondary: Color(0xFF5B5449),
    fieldSurface: Color(0xFFF8F2E6),
    warningSurface: Color(0xFFFAEBDC),
    warningText: Color(0xFF7D3B08),
    softDestructive: Color(0xFFC43E35),
  );

  static const dark = KarritoColors(
    accent: Color(0xFFFF5A12),
    onAccent: Color(0xFF13285A),
    accentContainer: Color(0xFF472C3D),
    onAccentContainer: Color(0xFFFFD8C4),
    completed: Color(0xFF38D39F),
    completedContainer: Color(0xFF164A58),
    onCompletedContainer: Color(0xFFBDF7E2),
    border: Color(0xFF2E4E99),
    textSecondary: Color(0xFFB5C2DF),
    fieldSurface: Color(0xFF22418A),
    warningSurface: Color(0xFF3F2B3E),
    warningText: Color(0xFFFFB78A),
    softDestructive: Color(0xFFFF8A80),
  );

  @override
  KarritoColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? completed,
    Color? completedContainer,
    Color? onCompletedContainer,
    Color? border,
    Color? textSecondary,
    Color? fieldSurface,
    Color? warningSurface,
    Color? warningText,
    Color? softDestructive,
  }) {
    return KarritoColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
      completed: completed ?? this.completed,
      completedContainer: completedContainer ?? this.completedContainer,
      onCompletedContainer: onCompletedContainer ?? this.onCompletedContainer,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      fieldSurface: fieldSurface ?? this.fieldSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      warningText: warningText ?? this.warningText,
      softDestructive: softDestructive ?? this.softDestructive,
    );
  }

  @override
  KarritoColors lerp(ThemeExtension<KarritoColors>? other, double t) {
    if (other is! KarritoColors) return this;
    return KarritoColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      onAccentContainer: Color.lerp(
        onAccentContainer,
        other.onAccentContainer,
        t,
      )!,
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
    );
  }
}

/// Material 3 Light & Dark themes for Karrito using the official 60-30-10
/// palette documented in `.agents/memory.md` and `karrito-ui-selectors`.
class AppTheme {
  AppTheme._();

  // Official 60-30-10 Light palette
  static const Color lightBackground = Color(0xFFEEE3CC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightFieldSurface = Color(0xFFF8F2E6);
  static const Color lightPrimary = Color(0xFF151515);
  static const Color lightAccent = Color(0xFF00C2B5);
  static const Color lightCompleted = Color(0xFF1E8E6E);
  static const Color lightTextPrimary = Color(0xFF151515);
  static const Color lightTextSecondary = Color(0xFF5B5449);
  static const Color lightBorder = Color(0xFFD8CCB4);
  static const Color lightSwitchTrackOff = Color(0xFFE4D8C1);
  static const Color lightSwitchBorderOff = Color(0xFFC6B79B);

  // Official 60-30-10 Dark palette
  static const Color darkBackground = Color(0xFF13285A);
  static const Color darkSurface = Color(0xFF1B3573);
  static const Color darkFieldSurface = Color(0xFF22418A);
  static const Color darkPrimary = Color(0xFFFF5A12);
  static const Color darkSecondary = Color(0xFFECE6DC);
  static const Color darkCompleted = Color(0xFF38D39F);
  static const Color darkTextPrimary = Color(0xFFECE6DC);
  static const Color darkTextSecondary = Color(0xFFB5C2DF);
  static const Color darkBorder = Color(0xFF2E4E99);
  static const Color darkSwitchTrackOff = Color(0xFF22418A);
  static const Color darkSwitchBorderOff = Color(0xFF4163B5);
  static const Color darkSwitchThumbOff = Color(0xFFECE6DC);

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD6F5F2),
      onPrimaryContainer: Color(0xFF0C4F4A),
      secondary: lightAccent,
      onSecondary: lightPrimary,
      secondaryContainer: Color(0xFFD6F5F2),
      onSecondaryContainer: Color(0xFF0C4F4A),
      tertiary: lightCompleted,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFDCEFE8),
      onTertiaryContainer: Color(0xFF115240),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: lightFieldSurface,
      surfaceContainer: Color(0xFFF2E9D7),
      surfaceContainerHigh: Color(0xFFEAE0CB),
      surfaceContainerHighest: lightBorder,
      outline: lightBorder,
      outlineVariant: lightBorder,
      shadow: Color(0x1A151515),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: lightBackground,
      cardColor: lightSurface,
      borderColor: lightBorder,
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
      onPrimary: darkBackground,
      primaryContainer: Color(0xFF472C3D),
      onPrimaryContainer: Color(0xFFFFD8C4),
      secondary: darkPrimary,
      onSecondary: darkBackground,
      secondaryContainer: Color(0xFF284896),
      onSecondaryContainer: darkTextPrimary,
      tertiary: darkCompleted,
      onTertiary: Color(0xFF082E22),
      tertiaryContainer: Color(0xFF164A58),
      onTertiaryContainer: Color(0xFFBDF7E2),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF4A0D0A),
      errorContainer: Color(0xFF6B1E25),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      surfaceContainerLowest: darkBackground,
      surfaceContainerLow: Color(0xFF18316B),
      surfaceContainer: darkSurface,
      surfaceContainerHigh: darkFieldSurface,
      surfaceContainerHighest: darkBorder,
      outline: darkBorder,
      outlineVariant: darkBorder,
      shadow: Color(0x5208122B),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: darkBackground,
      cardColor: darkSurface,
      borderColor: darkBorder,
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
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 44)),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
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
            TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
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
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: karritoColors.accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: borderColor, width: 1.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.brightness == Brightness.dark
              ? karritoColors.accent
              : karritoColors.onAccentContainer,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: karritoColors.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: cardColor,
        selectedColor: karritoColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
