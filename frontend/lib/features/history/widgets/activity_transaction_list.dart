import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/history/widgets/activity_transaction_card.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final int? expandedIndex;
  final ValueChanged<int?> onTransactionTapped;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.expandedIndex,
    required this.onTransactionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TransactionCard(
                transaction: transactions[index],
                isExpanded: expandedIndex == index,
                onTap: () => onTransactionTapped(index),
              ),
              Divider(color: AppColors.divider, thickness: 2),
            ],
          ),
        );
      },
    );
  }
}
