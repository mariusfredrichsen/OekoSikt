import 'package:flutter/material.dart';
import 'package:frontend/core/models/time_period.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/spending/widgets/spending_bar_chart.dart';
import 'package:frontend/features/spending/widgets/spending_filter_bar.dart';
import 'package:frontend/features/spending/widgets/spending_pie_chart.dart';

class SpendingPage extends StatefulWidget {
  final List<Transaction> transactions;
  const SpendingPage({super.key, required this.transactions});

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  TimePeriod _selectedPeriod = TimePeriod.month;
  late List<TransactionCategorySummary> categorySummaries = _createSummaries(
    widget.transactions,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spending Insights")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SpendingFilterBar(
                selectedPeriod: _selectedPeriod,
                onTimePeriodChanged: (period) => {
                  setState(() => _selectedPeriod = period),
                },
              ),

              Card(
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
                      const SizedBox(height: 20),
                      SpendingPieChart(categorySummaries: categorySummaries),
                      const SizedBox(height: 20),
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
    List<Transaction> filteredTransactions = transactions.where((t) {
      return t.category != TransactionCategory.transfer;
    }).toList();
    double total = filteredTransactions.fold(
      0,
      (sum, item) => sum + (item.amountOut ?? 0),
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
