import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      
      // ─── Transitions (Fade Only) ────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      // ─── Color Scheme ───────────────────────────────────────────────────
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.background,
        secondaryContainer: AppColors.surfaceVariant,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.success,
        onTertiary: AppColors.background,
        tertiaryContainer: AppColors.surfaceVariant,
        onTertiaryContainer: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        errorContainer: Color(0xFF4D0000),
        onErrorContainer: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.divider,
        outlineVariant: AppColors.cardBorder,
        shadow: Colors.black,
        scrim: AppColors.overlay,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
        inversePrimary: AppColors.primaryDark,
      ),

      // ─── Typography ─────────────────────────────────────────────────────
      textTheme: _buildTextTheme(),

      // ─── App Bar ────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppFontSize.xl,
          fontWeight: AppFontWeight.semiBold,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      // ─── Bottom Nav ─────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: AppFontSize.xs,
          fontWeight: AppFontWeight.semiBold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppFontSize.xs,
          fontWeight: AppFontWeight.regular,
        ),
      ),

      // ─── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.lg,
            fontWeight: AppFontWeight.bold,
            letterSpacing: 2.0,
            fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
          ),
        ),
      ),

      // ─── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.lg,
            fontWeight: AppFontWeight.bold,
            letterSpacing: 2.0,
            fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
          ),
        ),
      ),

      // ─── Text Button ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          textStyle: const TextStyle(
            fontSize: AppFontSize.md,
            fontWeight: AppFontWeight.bold,
            letterSpacing: 1.5,
            fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
          ),
        ),
      ),

      // ─── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: AppFontSize.md,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppFontSize.md,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: AppFontSize.sm,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: AppFontSize.sm,
        ),
      ),

      // ─── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),

      // ─── Chip ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceVariant,
        deleteIconColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppFontSize.sm,
          fontWeight: AppFontWeight.medium,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.background,
          fontSize: AppFontSize.sm,
          fontWeight: AppFontWeight.semiBold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),

      // ─── Divider ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ─── Icon ────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // ─── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppFontSize.xl,
          fontWeight: AppFontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppFontSize.md,
        ),
      ),

      // ─── Bottom Sheet ────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
      ),

      // ─── Snack Bar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppFontSize.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Progress Indicator ──────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
        circularTrackColor: AppColors.surfaceVariant,
      ),

      // ─── Slider ─────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.15),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.background,
          fontSize: AppFontSize.sm,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),

      // ─── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.background;
          }
          return AppColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariant;
        }),
      ),

      // ─── Tab Bar ────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: AppFontSize.md,
          fontWeight: AppFontWeight.semiBold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppFontSize.md,
          fontWeight: AppFontWeight.regular,
        ),
      ),

      // ─── List Tile ──────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        subtitleTextStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppFontSize.sm,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ─── Floating Action Button ──────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.hero,
        fontWeight: AppFontWeight.extraBold,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.display,
        fontWeight: AppFontWeight.bold,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.xxxl,
        fontWeight: AppFontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.xxl,
        fontWeight: AppFontWeight.extraBold,
        letterSpacing: 2.0,
        height: 1.3,
        fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.xl,
        fontWeight: AppFontWeight.bold,
        letterSpacing: 2.0,
        height: 1.3,
        fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.lg,
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0,
        height: 1.4,
      ),

      // Title styles
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.lg,
        fontWeight: AppFontWeight.bold,
        letterSpacing: 2.0,
        height: 1.4,
        fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.md,
        fontWeight: AppFontWeight.bold,
        letterSpacing: 2.0,
        height: 1.4,
        fontFeatures: [FontFeature.enable('c2sc'), FontFeature.enable('smcp')],
      ),
      titleSmall: TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppFontSize.sm,
        fontWeight: AppFontWeight.medium,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // Body styles
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.lg,
        fontWeight: AppFontWeight.regular,
        letterSpacing: 0.1,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.md,
        fontWeight: AppFontWeight.regular,
        letterSpacing: 0.2,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppFontSize.sm,
        fontWeight: AppFontWeight.regular,
        letterSpacing: 0.3,
        height: 1.6,
      ),

      // Label styles
      labelLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.md,
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppFontSize.sm,
        fontWeight: AppFontWeight.medium,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        color: AppColors.textDisabled,
        fontSize: AppFontSize.xs,
        fontWeight: AppFontWeight.medium,
        letterSpacing: 0.8,
        height: 1.4,
      ),
    );
  }
}
