import 'package:flutter/material.dart';
import 'package:frontend/core/models/budget.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/services/budget_service.dart';
import 'package:frontend/features/spending/widgets/spending_bar_chart.dart';
import 'package:frontend/features/spending/widgets/budget_card.dart';
import 'package:frontend/features/spending/widgets/spending_period_filter.dart';
import 'package:frontend/features/spending/widgets/spending_pie_chart.dart';
import 'package:frontend/features/spending/widgets/spending_scope_filter.dart';
import 'package:frontend/utils/date_extention.dart';

class SpendingPage extends StatefulWidget {
  final List<Transaction> transactions;
  const SpendingPage({super.key, required this.transactions});

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  FilterState _filters = FilterState(scope: FilterScope.month);
  List<Budget> _allBudgets = [];
  bool _isLoading = true;
  String? _errorMessage = "";
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await BudgetService.loadMonthlyBudgets();
      setState(() {
        _allBudgets = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingView();
    if (_errorMessage != null) return _buildErrorView();
    return _buildMainBody();
  }

  Widget _buildLoadingView() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildErrorView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildMainBody() {
    List<TransactionCategorySummary> categorySummaries = _createSummaries(
      widget.transactions,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Spending Insights")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 4,
            children: [
              ScopeFilter(
                selectedScope: _filters.scope,
                onScopeChanged: (scope) => {
                  setState(
                    () => _filters = _filters.copyWith(
                      scope: scope,
                      referenceDate: DateTime.now(),
                    ),
                  ),
                },
              ),
              Card(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    spacing: 16,
                    children: [
                      PeriodFilter(
                        scope: _filters.scope,
                        referenceDate: _filters.referenceDate,
                        onReferenceDateChanged: (period) => {
                          setState(
                            () => _filters = _filters.copyWith(
                              referenceDate: period,
                            ),
                          ),
                        },
                      ),
                      if (_filters.scope == FilterScope.month)
                        BudgetCard(
                          budget: _allBudgets.firstWhere(
                            (b) => b.month.isSameMonth(_filters.referenceDate),
                          ),
                          summaries: categorySummaries,
                          onBudgetUpdated: (newLimit) {
                            setState(() {
                              int index = _allBudgets.indexWhere(
                                (b) =>
                                    b.month.isSameMonth(_filters.referenceDate),
                              );
                              if (index != -1) {
                                _allBudgets[index] = _allBudgets[index]
                                    .copyWith(totalLimit: newLimit);
                              }
                            });
                          },
                        ),
                      SpendingPieChart(
                        categorySummaries: categorySummaries,
                        touchedIndex: touchedIndex,
                        onTouchedIndexChanged: (index) =>
                            setState(() => touchedIndex = index),
                      ),
                      SpendingBarChart(
                        categorySummaries: categorySummaries,
                        touchedIndex: touchedIndex,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TransactionCategorySummary> _createSummaries(
    List<Transaction> transactions,
  ) {
    List<Transaction> filteredTransactions = _filters
        .applyFilter(transactions)
        .where((t) {
          return t.category != TransactionCategory.transfer;
        })
        .toList();
    double total = filteredTransactions.fold(
      0,
      (prev, t) => prev + (t.amountOut ?? 0),
    );

    Map<TransactionCategory, double> grouped = {};
    for (var t in filteredTransactions) {
      grouped[t.category] = (grouped[t.category] ?? 0) + (t.amountOut ?? 0);
    }

    return grouped.entries
        .map((e) {
          return TransactionCategorySummary(
            category: e.key,
            totalSum: total,
            categorySum: e.value,
          );
        })
        .where((e) {
          return e.categorySum != 0;
        })
        .toList()
      ..sort((a, b) => a.categorySum.compareTo(b.categorySum));
  }
}
