import 'package:flutter/material.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/features/history/widgets/history_filter_bar.dart';
import 'package:frontend/features/history/widgets/transaction_list.dart';
import 'package:frontend/features/spending/widgets/spending_scope_filter.dart';

class HistoryPage extends StatefulWidget {
  final List<Transaction> transactions;
  const HistoryPage({super.key, required this.transactions});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? _expandedIndex;
  FilterState _filters = FilterState(scope: FilterScope.all);

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filters.applyFilter(widget.transactions);

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            HistoryFilterBar(
              selectedDirection: _filters.direction,
              selectedCategory: _filters.category,
              searchQuery: _filters.searchQuery,
              onDirectionChanged: (dir) =>
                  setState(() => _filters = _filters.copyWith(direction: dir)),
              onCategoryChanged: (cat) =>
                  setState(() => _filters = _filters.copyWith(category: cat)),
              onSearchQueryChanged: (query) => setState(
                () => _filters = _filters.copyWith(searchQuery: query),
              ),
            ),
            Expanded(
              child: TransactionList(
                transactions: filteredTransactions,
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
