import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/spending/widgets/spending_bar_chart.dart';
import 'package:frontend/features/spending/widgets/spending_period_filter.dart';
import 'package:frontend/features/spending/widgets/spending_pie_chart.dart';
import 'package:frontend/features/spending/widgets/spending_scope_filter.dart';

class SpendingPage extends StatefulWidget {
  final List<Transaction> transactions;
  const SpendingPage({super.key, required this.transactions});

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  FilterState _filters = FilterState(scope: FilterScope.month);

  @override
  Widget build(BuildContext context) {
    List<TransactionCategorySummary> categorySummaries = _createSummaries(
      widget.transactions,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Spending Insights")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ScopeFilter(
                selectedScope: _filters.scope,
                onScopeChanged: (scope) => {
                  setState(
                    () => _filters = _filters.copyWith(
                      scope: scope,
                      referenceDate: DateTime.now(),
                    ),
                  ),
                },
              ),
              Card(
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      PeriodFilter(
                        scope: _filters.scope,
                        referenceDate: _filters.referenceDate,
                        onReferenceDateChanged: (period) => {
                          setState(
                            () => _filters = _filters.copyWith(
                              referenceDate: period,
                            ),
                          ),
                        },
                      ),
                      SpendingPieChart(categorySummaries: categorySummaries),
                      SpendingBarChart(categorySummaries: categorySummaries),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TransactionCategorySummary> _createSummaries(
    List<Transaction> transactions,
  ) {
    List<Transaction> filteredTransactions = _filters
        .applyFilter(transactions)
        .where((t) {
          return t.category != TransactionCategory.transfer;
        })
        .toList();
    double total = filteredTransactions.fold(
      0,
      (prev, t) => prev + (t.amountOut ?? 0),
    );

    Map<TransactionCategory, double> grouped = {};
    for (var t in filteredTransactions) {
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
