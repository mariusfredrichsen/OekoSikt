import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widget/cards/card_container.dart';

class CategorizedTransactionList extends StatelessWidget {
  const CategorizedTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = TransactionCategory.values
        .where((cat) => cat != TransactionCategory.all)
        .toList();

    return Column(
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: _buildCategoryDropdown(cat),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown(TransactionCategory cat) {
    return Card(
      color: AppColors.softBlue,
      child: ExpansionTile(
        leading: Icon(cat.icon, color: cat.color),
        title: Text(
          cat.label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.navy),

        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "RECENT TRANSACTIONS",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTransactionRow("REMA 1000", "- 450 NOK"),
                _buildTransactionRow("KIWI", "- 120 NOK"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.navy),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
