import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/main_navigation.dart';
import 'package:frontend/core/theme/app_colors.dart';

void main() {
  runApp(const MobileBankApp());
}

class MobileBankApp extends StatelessWidget {
  const MobileBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileBank',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background, // #F3F4F6

        colorScheme: const ColorScheme(
          brightness: Brightness.light,

          // ── Primary: Navy #002C5E ──
          primary:
              AppColors.navy, // AppBar, buttons, active pills, bar chart fill
          onPrimary: Colors.white, // Text/icons on navy surfaces
          primaryContainer: AppColors
              .blue50, // #EFF6FF — budget card bg, info banners, expense icon bg
          onPrimaryContainer:
              AppColors.navy, // Navy text inside blue-50 containers
          // ── Secondary: Navy Hover #003875 ──
          secondary: AppColors.navyHover, // Pressed/hover navy buttons
          onSecondary: Colors.white,

          // ── Tertiary: Accent Blue #2563EB ──
          tertiary: AppColors.blue600, // Checkmark circles, "Select All" links
          onTertiary: Colors.white,

          // ── Surface & Text ──
          surface: AppColors.surface, // #FFFFFF — cards, bottom nav, modals
          onSurface: AppColors
              .navy, // #002C5E — primary text (account names, amounts, descriptions)
          onSurfaceVariant: AppColors
              .gray400, // #9CA3AF — timestamps, "SEK" labels, nav inactive icons
          // ── Surface Containers ──
          surfaceContainerLowest:
              AppColors.gray50, // #F9FAFB — dividers, input bg, hover bg
          surfaceContainerLow: AppColors
              .gray100, // #F3F4F6 — card borders, category tag bg, empty state bg
          surfaceContainer: AppColors
              .gray200, // #E5E7EB — pill container bg, slider track, input borders
          surfaceContainerHigh: AppColors
              .gray300, // #D1D5DB — disabled icons, excluded category dot
          surfaceContainerHighest:
              AppColors.gray200, // #E5E7EB — segmented control container
          // ── Outline & Borders ──
          outline: AppColors.gray200, // #E5E7EB — input borders, nav top border
          outlineVariant: AppColors
              .gray50, // #F9FAFB — subtle row dividers (divide-gray-50)
          // ── Error ──
          error: AppColors
              .red600, // #DC2626 — "Over Budget" text/icon, validation error
          onError: Colors.white,
          errorContainer: AppColors
              .red50, // #FEF2F2 — over-budget banner bg, error input bg
          onErrorContainer:
              AppColors.red700, // #B91C1C — over-budget detail text
        ),

        // ── AppBar ──
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy, // #002C5E
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600, // Matches React's font-semibold
            color: Colors.white,
          ),
        ),

        // ── Typography ──
        textTheme: const TextTheme(
          // Large display values (balance card: text-3xl font-bold)
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          // Budget value (text-4xl font-black)
          headlineMedium: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w900,
          ),
          // Account names (text-lg font-bold)
          headlineSmall: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
          // Page title, card headers (font-bold text-[#002C5E])
          titleLarge: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
          // Sub-headers (text-sm font-bold)
          titleMedium: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
          // Transaction description (font-bold text-[15px])
          titleSmall: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
          // General body text
          bodyLarge: TextStyle(color: AppColors.navy),
          bodyMedium: TextStyle(color: AppColors.navy),
          // Timestamps, secondary descriptions
          bodySmall: TextStyle(color: AppColors.gray400),
          // Section headers — "MY ACCOUNTS", "RECENT TRANSACTIONS"
          // (text-sm font-bold uppercase tracking-widest text-gray-500)
          labelLarge: TextStyle(
            color: AppColors.gray500,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
          // Sub-labels — "Quick Select", "Or Use Slider"
          // (text-[10px] font-bold text-gray-400 uppercase tracking-wider)
          labelMedium: TextStyle(
            color: AppColors.gray400,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          // Micro text — currency labels, category tags, nav labels
          // (text-[10px] font-medium uppercase tracking-wider)
          labelSmall: TextStyle(
            color: AppColors.gray400,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),

        // ── Bottom Navigation Bar ──
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface, // White
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.navy, // Active: navy
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              );
            }
            return const TextStyle(
              color: AppColors.gray400, // Inactive: gray-400
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.navy, size: 24);
            }
            return const IconThemeData(color: AppColors.gray400, size: 24);
          }),
        ),

        // ── Dividers ──
        dividerTheme: const DividerThemeData(
          color: AppColors.gray50, // #F9FAFB — matches React's divide-gray-50
          thickness: 1,
          space: 1,
        ),

        // ── Input Fields ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.gray50, // bg-gray-50 / bg-white
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.navy, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.red300),
          ),
          hintStyle: const TextStyle(color: AppColors.gray400),
        ),

        // ── Elevated Buttons (primary navy) ──
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0x331E3A8A), // shadow-blue-900/20
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // ── Outlined Buttons (cancel/secondary) ──
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gray600,
            backgroundColor: AppColors.gray100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // ── Cards ──
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.gray100),
          ),
        ),
      ),

      home: const MainNavigation(),
    );
  }
}
