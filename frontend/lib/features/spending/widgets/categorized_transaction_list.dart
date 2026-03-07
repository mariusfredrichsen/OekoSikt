import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/spending/pages/categorizing_page.dart';
import 'package:frontend/utils/string_extention.dart';

class CategorizedTransactionList extends StatelessWidget {
  final List<Transaction> allTransactions;

  const CategorizedTransactionList({super.key, required this.allTransactions});

  @override
  Widget build(BuildContext context) {
    final groupedMap = _createGroupedTransactions(allTransactions);

    final sortedEntries = groupedMap.entries.toList()
      ..sort((a, b) => _getTotal(b.value).compareTo(_getTotal(a.value)));

    return Column(
      children: sortedEntries.map((entry) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: _buildCategoryDropdown(entry.key, entry.value, context),
        );
      }).toList(),
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

  double _getTotal(List<Transaction> transactions) {
    return transactions.fold(
      0.0,
      (sum, t) => sum + (t.amountOut?.abs() ?? 0.0),
    );
  }

  Widget _buildCategoryDropdown(
    TransactionCategory cat,
    List<Transaction> transactions,
    BuildContext context,
  ) {
    final total = _getTotal(transactions);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorizingPage(transactions: transactions),
          ),
        );
      },
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        visualDensity: const VisualDensity(vertical: -4),
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Icon(cat.icon, color: cat.color, size: 18),
        title: Text(
          cat.name.capitalize(),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          "${transactions.length} items",
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${total.round()} kr",
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Icon(Icons.arrow_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
