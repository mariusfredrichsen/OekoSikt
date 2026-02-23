import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/features/history/widgets/history_filter_bar.dart';
import 'package:frontend/features/history/widgets/transaction_list.dart';

class HistoryPage extends StatefulWidget {
  final List<Transaction> transactions;
  const HistoryPage({super.key, required this.transactions});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TransactionDirection _selectedDirection = TransactionDirection.all;
  TransactionCategory _selectedCategory = TransactionCategory.all;
  String _searchQuery = "";
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
      final matchQuery = t.cleanTitle.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      return matchDir && matchCat && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            HistoryFilterBar(
              selectedDirection: _selectedDirection,
              selectedCategory: _selectedCategory,
              searchQuery: _searchQuery,
              onDirectionChanged: (dir) =>
                  setState(() => _selectedDirection = dir),
              onCategoryChanged: (cat) =>
                  setState(() => _selectedCategory = cat),
              onSearchQueryChanged: (query) =>
                  setState(() => _searchQuery = query),
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
      ),
    );
  }
}
