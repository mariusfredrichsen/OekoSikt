import 'package:flutter/material.dart';
import 'package:frontend/core/models/time_period.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/core/models/transaction_filter_state.dart';
import 'package:frontend/core/models/transaction.dart';
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
  // data
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];

  // ui
  bool _isLoading = true;
  String? _errorMessage;
  int? _expandedIndex;

  // filters
  TransactionFilterState _filters = TransactionFilterState();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final loadedTransactions = await TransactionService.loadTransactions();
      setState(() {
        _allTransactions = loadedTransactions;
        _filteredTransactions = loadedTransactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((t) {
        final matchDirection = switch (_filters.direction) {
          TransactionDirection.all => true,
          TransactionDirection.outcome => t.amountOut != null,
          TransactionDirection.income => t.amountIn != null,
        };

        final matchCategory =
            TransactionCategory.all == _filters.category ||
            t.category == _filters.category;

        return matchDirection && matchCategory;
      }).toList();
      _expandedIndex = null;
    });
  }

  void _updateFilters(TransactionFilterState transactionFilter) {
    _filters = transactionFilter;
    _applyFilters();
  }

  void onSelectTransaction(int? index) {
    setState(() {
      _expandedIndex = (index == _expandedIndex) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentView();
  }

  Widget _buildCurrentView() {
    if (_isLoading) return _buildLoadingView();
    if (_errorMessage != null) return _buildErrorView();
    if (_allTransactions.isEmpty) return _buildIsEmptyView();
    return _buildMainBody();
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadTransactions(); // Retry loading
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildIsEmptyView() {
    return Center(child: Text('No transactions found'));
  }

  Widget _buildMainBody() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Movements"),
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
              transactions: _filteredTransactions,
              selectedDirection: _filters.direction,
              selectedCategory: _filters.category,
              expandedIndex: _expandedIndex,
              onDirectionChanged: (dir) =>
                  _updateFilters(_filters.copyWith(direction: dir)),
              onCategoryChanged: (cat) =>
                  _updateFilters(_filters.copyWith(category: cat)),
              onTransactionTapped: (idx) => onSelectTransaction(idx),
            ),
            AnalysisTabView(
              selectedTimePeriod: _filters.period,
              onTimePeriodChanged: (period) =>
                  _updateFilters(_filters.copyWith(period: period)),
              transactions: _allTransactions,
            ),
          ],
        ),
      ),
    );
  }
}
