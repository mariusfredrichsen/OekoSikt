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
      spacing: 6,
      children: List.generate(categorySummaries.length, (index) {
        return _buildSpendingBar(
          categorySummaries[index],
          touchedIndex == index,
          touchedIndex != -1,
        );
      }),
    );
  }

  Widget _buildSpendingBar(
    TransactionCategorySummary categorySummary,
    bool isSelected,
    bool otherSelected,
  ) {
    final color = touchedIndex == -1 || isSelected
        ? categorySummary.category.color
        : AppColors.gray300;

    return Row(
      spacing: 8,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            categorySummary.category.label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.navy
                  : otherSelected
                  ? AppColors.textSecondary
                  : AppColors.gray500,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: categorySummary.categorySum / categorySummary.totalSum,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color?>(color),
            ),
          ),
        ),

        SizedBox(
          width: 72,
          child: Text(
            "${categorySummary.categorySum.toStringAsFixed(1)} kr",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isSelected
                  ? AppColors.navy
                  : otherSelected
                  ? AppColors.textSecondary
                  : AppColors.navy,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
