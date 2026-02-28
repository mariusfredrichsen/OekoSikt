import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class BudgetBar extends StatelessWidget {
  final double value;

  const BudgetBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 12,
        backgroundColor: AppColors.surface,
        valueColor: AlwaysStoppedAnimation<Color?>(
          value < 0.8
              ? AppColors.income
              : (value < 1.0 ? Colors.orange : AppColors.error),
        ),
      ),
    );
  }
}
