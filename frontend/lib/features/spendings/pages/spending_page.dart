import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/time_period.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/features/spendings/widgets/analysis_spending_bar_chart.dart';
import 'package:frontend/features/spendings/widgets/analysis_spending_pie_chart.dart';

class SpendingPage extends StatefulWidget {
  final List<Transaction> transactions;
  const SpendingPage({super.key, required this.transactions});

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spending Insights")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl<TimePeriod>(
                groupValue: _selectedPeriod,
                onValueChanged: (p) => setState(() => _selectedPeriod = p!),
                children: {
                  TimePeriod.week: Text("Week"),
                  TimePeriod.month: Text("Month"),
                  TimePeriod.year: Text("Year"),
                },
              ),
              const SizedBox(height: 20),
              // We pass the raw transactions; AnalysisTabView logic handles the grouping
              SpendingPieChart(
                categorySummaries: _createSummaries(widget.transactions),
              ),
              const SizedBox(height: 20),
              SpendingBarChart(
                categorySummaries: _createSummaries(widget.transactions),
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
