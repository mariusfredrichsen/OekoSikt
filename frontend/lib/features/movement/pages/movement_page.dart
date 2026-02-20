import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_filter.dart';
import 'package:frontend/core/models/transaction_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/movement/tabs/activity_tab_view.dart';
import 'package:frontend/features/movement/tabs/analysis_tab_view.dart';
import 'package:frontend/core/services/transaction_service.dart'; // Add this import

class MovementPage extends StatefulWidget {
  const MovementPage({super.key});

  @override
  State<MovementPage> createState() => _MovementPageState();
}

class _MovementPageState extends State<MovementPage> {
  List<Transaction> transactions = [];
  List<Transaction> filtedTransactions = [];
  bool isLoading = true;
  String? errorMessage;
  TransactionFilter selectedTransactionFilter = TransactionFilter.all;
  int? selectedIndex;
  TransactionCategory selectedTransactionCategory = TransactionCategory.all;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final loadedTransactions = await TransactionService.loadTransactions();
      setState(() {
        transactions = loadedTransactions;
        filtedTransactions = loadedTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load transactions: $e';
        isLoading = false;
      });
    }
  }

  void onFilterChange(TransactionFilter transactionFilter) {
    setState(() {
      selectedTransactionFilter = transactionFilter;
      filtedTransactions = transactions.where((transaction) {
        bool result = true;
        if (selectedTransactionFilter == TransactionFilter.income) {
          result = transaction.amountIn != null;
        } else if (selectedTransactionFilter == TransactionFilter.outcome) {
          result = transaction.amountOut != null;
        }
        return result;
      }).toList();
    });
  }

  void onSelectTransaction(int? index) {
    setState(() {
      selectedIndex = (index == selectedIndex) ? null : index;
    });
  }

  void onCategoryChange(TransactionCategory category) {
    setState(() {
      selectedTransactionCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: _buildBody(),
    );
  }

  /// Builds the body based on current state (loading, error, or data)
  Widget _buildBody() {
    // Show loading spinner while data loads
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message if loading failed
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadTransactions(); // Retry loading
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    // Show the list of transactions
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Transaction movement"),
          bottom: const TabBar(
            labelColor: AppColors.background,
            tabs: [
              Tab(text: "Activity"),
              Tab(text: "Analysis"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ActivityTabView(
              transactions: filtedTransactions,
              selectedTransactionFilter: selectedTransactionFilter,
              onFilterChange: onFilterChange,
              selectedIndex: selectedIndex,
              onSelectTransaction: onSelectTransaction,
              selectedTransactionCategory: selectedTransactionCategory,
              onCategoryChange: onCategoryChange,
            ),
            const AnalysisTabView(),
          ],
        ),
      ),
    );
  }
}
