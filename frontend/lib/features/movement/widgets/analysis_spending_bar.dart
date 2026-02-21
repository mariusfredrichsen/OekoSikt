import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';

class SpendingBar extends StatelessWidget {
  final TransactionCategorySummary categorySummary;

  const SpendingBar({super.key, required this.categorySummary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categorySummary.category.label,
              style: TextStyle(color: AppColors.navy, fontSize: 12),
            ),
            Text(
              "${categorySummary.categorySum.toStringAsFixed(1)}\$",
              style: TextStyle(color: AppColors.navy, fontSize: 12),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(8),
          child: LinearProgressIndicator(
            value: categorySummary.categorySum / categorySummary.totalSum,
            minHeight: 12,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              categorySummary.category.color,
            ),
          ),
        ),
      ],
    );
  }
}
