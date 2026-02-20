import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_filter.dart';
import 'package:frontend/core/models/transaction_model.dart';
import 'package:frontend/features/movement/widgets/transaction_card.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.selectedIndex,
    required this.onSelectTransaction,
  });

  final List<Transaction> transactions;
  final int? selectedIndex;
  final ValueChanged<int?> onSelectTransaction;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionCard(
          transaction: transactions[index],
          selected: selectedIndex == index,
          onClick: () => onSelectTransaction(index),
        );
      },
    );
  }
}
