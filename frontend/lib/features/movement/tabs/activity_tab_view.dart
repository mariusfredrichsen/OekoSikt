import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/features/movement/widgets/activity_filter_bar.dart';
import 'package:frontend/features/movement/widgets/activity_transaction_list.dart';

class ActivityTabView extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionDirection selectedDirection;
  final TransactionCategory selectedCategory;
  final int? expandedIndex;

  final ValueChanged<TransactionDirection> onDirectionChanged;
  final ValueChanged<TransactionCategory> onCategoryChanged;
  final ValueChanged<int?> onTransactionTapped;

  const ActivityTabView({
    super.key,
    required this.transactions,
    required this.selectedDirection,
    required this.selectedCategory,
    required this.expandedIndex,
    required this.onDirectionChanged,
    required this.onCategoryChanged,
    required this.onTransactionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterBar(
          selectedDirection: selectedDirection,
          selectedCategory: selectedCategory,
          onDirectionChanged: onDirectionChanged,
          onCategoryChanged: onCategoryChanged,
        ),
        Expanded(
          child: TransactionList(
            transactions: transactions,
            expandedIndex: expandedIndex,
            onTransactionTapped: onTransactionTapped,
          ),
        ),
      ],
    );
  }
}
