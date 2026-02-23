import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/features/spending/widgets/spending_bar.dart';

class SpendingBarChart extends StatelessWidget {
  final List<TransactionCategorySummary> categorySummaries;
  const SpendingBarChart({super.key, required this.categorySummaries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...categorySummaries.map(
          (element) => Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: SpendingBar(categorySummary: element),
          ),
        ),
      ],
    );
  }
}
