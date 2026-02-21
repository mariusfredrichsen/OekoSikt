import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/movement/widgets/analysis_spending_bar.dart';

class SpendingBarChart extends StatelessWidget {
  final List<TransactionCategorySummary> categorySummaries;
  const SpendingBarChart({super.key, required this.categorySummaries});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "SPENDING BY CATEGORY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navy,
                  ),
                ),

                Text(
                  "${categorySummaries.fold<double>(0, (prev, cs) => prev + cs.categorySum)}\$",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(color: AppColors.divider, thickness: 2),
            ),
            ...categorySummaries.map(
              (element) => Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: SpendingBar(categorySummary: element),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
