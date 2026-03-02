import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';

class CategorizedTransactionList extends StatelessWidget {
  const CategorizedTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: TransactionCategory.expenseCategories.map((cat) {
        return Text(cat.label, style: TextStyle(color: cat.color));
      }).toList(),
    );
  }
}
