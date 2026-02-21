import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/main_navigation.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/movement/pages/movement_page.dart';

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
        // Using the Surface colors for the main Scaffold background
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.navy,
          onPrimary: Colors.white,
          primaryContainer: AppColors.softBlue,
          onPrimaryContainer: AppColors.navy,
          secondary: AppColors.gold,
          onSecondary: AppColors.textPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          outlineVariant: AppColors.divider,
          error: AppColors.error,
          onError: Colors.white,
        ),

        // Global AppBar styling
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Typography settings using your Slate scale
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),

        // Segmented Control and Divider defaults
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
      ),

      home: const MainNavigation(),
    );
  }
}
