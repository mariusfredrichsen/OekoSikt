import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';

class SpendingBarChart extends StatelessWidget {
  final List<TransactionCategorySummary> categorySummaries;
  final int touchedIndex;

  const SpendingBarChart({
    super.key,
    required this.categorySummaries,
    required this.touchedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(categorySummaries.length, (index) {
        TransactionCategorySummary summary = categorySummaries[index];

        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: _buildSpendingBar(summary, touchedIndex == index),
        );
      }),
    );
  }

  Widget _buildSpendingBar(
    TransactionCategorySummary categorySummary,
    bool isSelected,
  ) {
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
              "${categorySummary.categorySum.toStringAsFixed(1)} kr",
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
            valueColor: AlwaysStoppedAnimation<Color?>(
              touchedIndex == -1 || isSelected
                  ? categorySummary.category.color
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
