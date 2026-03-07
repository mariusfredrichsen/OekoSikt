import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/utils/transaction_list_extention.dart';

class SpendingBlobs extends StatelessWidget {
  final List<Transaction> allTransactions;

  const SpendingBlobs({super.key, required this.allTransactions});

  @override
  Widget build(BuildContext context) {
    final groupedData = _createGroupedTransactions(allTransactions);

    final sortedEntries = groupedData.entries.toList()
      ..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));

    if (sortedEntries.isEmpty) return const Center(child: Text("No data"));

    return AspectRatio(
      aspectRatio: 1,
      child: BubbleChartLayout(
        children: sortedEntries.map((entry) {
          final cat = entry.key;
          final total = entry.value.totalSpent;

          return BubbleNode.leaf(
            value: total,
            options: BubbleOptions(
              color: cat.color.withAlpha(50),
              border: Border.all(color: cat.color.withAlpha(200), width: 1.5),
              child: _BubbleContent(cat: cat, amount: total),
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<TransactionCategory, List<Transaction>> _createGroupedTransactions(
    List<Transaction> transactions,
  ) {
    final grouped = <TransactionCategory, List<Transaction>>{};
    for (final t in transactions) {
      (grouped[t.category] ??= []).add(t);
    }
    return grouped;
  }
}

class _BubbleContent extends StatelessWidget {
  final TransactionCategory cat;
  final double amount;

  const _BubbleContent({required this.cat, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat.icon, color: cat.color, size: 20),
            const SizedBox(height: 3),
            Text(
              cat.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: cat.color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              "${amount.round()} kr",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
