import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_filter.dart';
import 'package:frontend/core/models/transaction_model.dart';
import 'package:frontend/features/movement/widgets/activity_filter_bar.dart';
import 'package:frontend/features/movement/widgets/transaction_list.dart';

class ActivityTabView extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionFilter selectedTransactionFilter;
  final ValueChanged<TransactionFilter> onFilterChange;
  final int? selectedIndex;
  final ValueChanged<int?> onSelectTransaction;
  final TransactionCategory selectedTransactionCategory;
  final ValueChanged<TransactionCategory> onCategoryChange;

  const ActivityTabView({
    super.key,
    required this.transactions,
    required this.selectedTransactionFilter,
    required this.onFilterChange,
    required this.selectedIndex,
    required this.onSelectTransaction,
    required this.selectedTransactionCategory,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActivityFilterBar(
          selectedTransactionFilter: selectedTransactionFilter,
          onFilterChange: onFilterChange,
          selectedTransactionCategory: selectedTransactionCategory,
          onCategoryChange: onCategoryChange,
        ),
        Expanded(
          child: TransactionList(
            transactions: transactions, // transactions,
            selectedIndex: selectedIndex,
            onSelectTransaction: onSelectTransaction,
          ),
        ),
      ],
    );
  }
}
