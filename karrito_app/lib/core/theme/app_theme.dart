import 'package:flutter/material.dart';

/// Custom semantic colors for Karrito beyond Material 3 defaults.
@immutable
class KarritoColors extends ThemeExtension<KarritoColors> {
  const KarritoColors({
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
    completed: Color(0xFF2B6E4E),
    completedContainer: Color(0xFFE4F2EA),
    onCompletedContainer: Color(0xFF1A4732),
    border: Color(0xFFE5DFD5),
    textSecondary: Color(0xFF6B6268),
    fieldSurface: Color(0xFFF5F1EA),
    warningSurface: Color(0xFFFAF0E4),
    warningText: Color(0xFF8C490F),
    softDestructive: Color(0xFFC4453D),
  );

  static const dark = KarritoColors(
    completed: Color(0xFF5EC293),
    completedContainer: Color(0xFF1B3529),
    onCompletedContainer: Color(0xFFB7EAD2),
    border: Color(0xFF362D33),
    textSecondary: Color(0xFFA89DA4),
    fieldSurface: Color(0xFF2B2329),
    warningSurface: Color(0xFF332316),
    warningText: Color(0xFFF0A35E),
    softDestructive: Color(0xFFF28B82),
  );

  @override
  KarritoColors copyWith({
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

/// Material 3 Light & Dark themes for Karrito using exact `.agents/memory.md`
/// palette and native system typography (100% offline-capable).
class AppTheme {
  AppTheme._();

  // Exact Light palette
  static const Color lightBackground = Color(0xFFFAF7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF4E1A3D);
  static const Color lightSecondary = Color(0xFFC86D1F);
  static const Color lightCompleted = Color(0xFF2B6E4E);
  static const Color lightTextPrimary = Color(0xFF1F1A1D);
  static const Color lightTextSecondary = Color(0xFF6B6268);
  static const Color lightBorder = Color(0xFFE5DFD5);
  static const Color lightSwitchTrackOff = Color(0xFFEDE7DF);
  static const Color lightSwitchBorderOff = Color(0xFFD0C7BC);

  // Exact Dark palette
  static const Color darkBackground = Color(0xFF141013);
  static const Color darkSurface = Color(0xFF211B20);
  static const Color darkPrimary = Color(0xFFE08EC3);
  static const Color darkSecondary = Color(0xFFF0A35E);
  static const Color darkCompleted = Color(0xFF5EC293);
  static const Color darkTextPrimary = Color(0xFFF5F0F3);
  static const Color darkTextSecondary = Color(0xFFA89DA4);
  static const Color darkBorder = Color(0xFF362D33);
  static const Color darkSwitchTrackOff = Color(0xFF2B2329);
  static const Color darkSwitchBorderOff = Color(0xFF4A3F46);
  static const Color darkSwitchThumbOff = Color(0xFFD6CCD2);

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFF3E2ED),
      onPrimaryContainer: lightPrimary,
      secondary: lightSecondary,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFAE8D6),
      onSecondaryContainer: Color(0xFF5A2B04),
      tertiary: lightCompleted,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFE4F2EA),
      onTertiaryContainer: Color(0xFF1A4732),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF5F1EA),
      surfaceContainer: Color(0xFFEFEAE2),
      surfaceContainerHigh: Color(0xFFE9E3D9),
      surfaceContainerHighest: Color(0xFFE5DFD5),
      outline: lightBorder,
      outlineVariant: lightBorder,
      shadow: Color(0x1A1F1A1D),
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
      onPrimary: Color(0xFF380D29),
      primaryContainer: Color(0xFF4E1A3D),
      onPrimaryContainer: Color(0xFFFADDF0),
      secondary: darkSecondary,
      onSecondary: Color(0xFF452002),
      secondaryContainer: Color(0xFF5A2D08),
      onSecondaryContainer: Color(0xFFFFDFC4),
      tertiary: darkCompleted,
      onTertiary: Color(0xFF0A3321),
      tertiaryContainer: Color(0xFF1B3529),
      onTertiaryContainer: Color(0xFFB7EAD2),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      surfaceContainerLowest: Color(0xFF141013),
      surfaceContainerLow: Color(0xFF1D171C),
      surfaceContainer: Color(0xFF211B20),
      surfaceContainerHigh: Color(0xFF2B2329),
      surfaceContainerHighest: Color(0xFF362D33),
      outline: darkBorder,
      outlineVariant: darkBorder,
      shadow: Color(0x40000000),
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
            return colorScheme.primary;
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
            return colorScheme.onPrimary;
          }
          return switchThumbOff;
        }),
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
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
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
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
