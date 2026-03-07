import 'package:flutter/material.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/features/history/widgets/history_filter_bar.dart';
import 'package:frontend/features/history/widgets/transaction_list.dart';

class CategorizingPage extends StatefulWidget {
  final List<Transaction> transactions;
  const CategorizingPage({super.key, required this.transactions});

  @override
  State<CategorizingPage> createState() => _CategorizingPageState();
}

class _CategorizingPageState extends State<CategorizingPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Categorizing")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: TransactionList(
                transactions: widget.transactions,
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
