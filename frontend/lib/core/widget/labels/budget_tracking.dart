import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class BudgetTracking extends StatelessWidget {
  final double value;

  const BudgetTracking({super.key, required this.value});

  ({String label, Color? color, IconData icon}) _getStatus() {
    if (value >= 1.0) {
      return (
        label: "OVER BUDGET",
        color: AppColors.error,
        icon: Icons.trending_up,
      );
    } else if (value >= 0.8) {
      return (
        label: "WATCH IT",
        color: AppColors.amber500,
        icon: Icons.trending_up,
      );
    } else {
      return (
        label: "ON TRACK",
        color: AppColors.income,
        icon: Icons.trending_down,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, color: status.color, size: 14),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: TextStyle(
            color: status.color,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
