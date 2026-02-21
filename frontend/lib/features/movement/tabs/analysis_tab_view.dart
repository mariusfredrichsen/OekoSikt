import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/time_period.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/movement/widgets/analysis_spending_bar_chart.dart';
import 'package:frontend/features/movement/widgets/analysis_spending_pie_chart.dart';

class AnalysisTabView extends StatelessWidget {
  final TimePeriod selectedTimePeriod;
  final ValueChanged<TimePeriod> onTimePeriodChanged;
  final List<Transaction> transactions;

  const AnalysisTabView({
    super.key,
    required this.selectedTimePeriod,
    required this.onTimePeriodChanged,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<TimePeriod>(
              groupValue: selectedTimePeriod,
              backgroundColor: AppColors.divider,
              thumbColor: AppColors.surface,
              onValueChanged: (value) =>
                  value != null ? onTimePeriodChanged(value) : null,
              children: {
                TimePeriod.week: _buildSegmentText(TimePeriod.week),
                TimePeriod.month: _buildSegmentText(TimePeriod.month),
                TimePeriod.year: _buildSegmentText(TimePeriod.year),
              },
            ),
          ),
          SpendingBarChart(
            categorySummaries: _createSpendingSummaries(transactions),
          ),
          SpendingPieChart(
            categorySummaries: _createSpendingSummaries(transactions),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentText(TimePeriod period) {
    final isSelected = selectedTimePeriod == period;
    return Text(
      period.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.navy : AppColors.textSecondary,
      ),
    );
  }

  List<TransactionCategorySummary> _createSpendingSummaries(
    List<Transaction> transactions,
  ) {
    double total = transactions.fold(
      0,
      (sum, item) => sum + (item.amountOut ?? 0),
    );

    Map<TransactionCategory, double> grouped = {};
    for (var t in transactions) {
      grouped[t.category] = (grouped[t.category] ?? 0) + (t.amountOut ?? 0);
    }

    return grouped.entries
        .map((e) {
          return TransactionCategorySummary(
            category: e.key,
            totalSum: total,
            categorySum: e.value,
          );
        })
        .where((e) {
          return e.categorySum != 0;
        })
        .toList()
      ..sort((a, b) => a.categorySum.compareTo(b.categorySum));
  }
}
