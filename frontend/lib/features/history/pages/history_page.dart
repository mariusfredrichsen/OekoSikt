import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/features/history/widgets/activity_filter_bar.dart';
import 'package:frontend/features/history/widgets/activity_transaction_list.dart';

class HistoryPage extends StatefulWidget {
  final List<Transaction> transactions;
  const HistoryPage({super.key, required this.transactions});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TransactionDirection _selectedDirection = TransactionDirection.all;
  TransactionCategory _selectedCategory = TransactionCategory.all;
  int? _expandedIndex;

  List<Transaction> get _filteredTransactions {
    return widget.transactions.where((t) {
      final matchDir =
          _selectedDirection == TransactionDirection.all ||
          (_selectedDirection == TransactionDirection.outcome
              ? t.amountOut != null
              : t.amountIn != null);
      final matchCat =
          _selectedCategory == TransactionCategory.all ||
          t.category == _selectedCategory;
      return matchDir && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: Column(
        children: [
          FilterBar(
            selectedDirection: _selectedDirection,
            selectedCategory: _selectedCategory,
            onDirectionChanged: (dir) =>
                setState(() => _selectedDirection = dir),
            onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          ),
          Expanded(
            child: TransactionList(
              transactions: _filteredTransactions,
              expandedIndex: _expandedIndex,
              onTransactionTapped: (idx) => setState(
                () => _expandedIndex = (_expandedIndex == idx ? null : idx),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
