import 'package:flutter/material.dart';
import 'package:frontend/core/models/budget.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/features/spending/widgets/budget_card.dart';
import 'package:frontend/features/spending/widgets/categorized_transaction_list.dart';
import 'package:frontend/features/spending/widgets/spending_bar_chart.dart';
import 'package:frontend/features/spending/widgets/spending_pie_chart.dart';

class SpendingContent extends StatelessWidget {
  final List<TransactionCategorySummary> summaries;
  final Budget? budget;
  final FilterScope scope;
  final int touchedIndex;
  final ValueChanged<int> onTouchedIndexChanged;

  final ValueChanged<double>? onBudgetUpdated;
  final ValueChanged<Set<TransactionCategory>>? onCategoryFilterChanged;

  const SpendingContent({
    super.key,
    required this.summaries,
    required this.budget,
    required this.scope,
    required this.touchedIndex,
    required this.onTouchedIndexChanged,
    this.onBudgetUpdated,
    this.onCategoryFilterChanged,
  });

  bool get _showBudget =>
      scope == FilterScope.month &&
      onBudgetUpdated != null &&
      onCategoryFilterChanged != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  if (_showBudget)
                    BudgetCard(
                      budget: budget,
                      summaries: summaries,
                      onBudgetUpdated: onBudgetUpdated!,
                      onCategoryFilterChanged: onCategoryFilterChanged!,
                    ),
                  SpendingPieChart(
                    categorySummaries: summaries,
                    touchedIndex: touchedIndex,
                    onTouchedIndexChanged: onTouchedIndexChanged,
                  ),
                  SpendingBarChart(
                    categorySummaries: summaries,
                    touchedIndex: touchedIndex,
                  ),
                ],
              ),
            ),
          ),
          const Card(child: CategorizedTransactionList()),
        ],
      ),
    );
  }
}
