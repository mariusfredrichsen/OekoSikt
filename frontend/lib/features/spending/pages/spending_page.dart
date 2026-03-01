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
  String? _errorMessage;
  int touchedIndex = -1;

  late final PageController _pageController;

  static final _epoch = DateTime(2020, 1);

  int _dateToPage(DateTime date) =>
      (date.year - _epoch.year) * 12 + (date.month - _epoch.month);

  DateTime _pageToDate(int page) {
    final months = _epoch.month + page - 1;
    return DateTime(_epoch.year + months ~/ 12, months % 12 + 1);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _dateToPage(_filters.referenceDate),
    );
    _fetchData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        _errorMessage = 'Failed to load budgets: $e';
        _isLoading = false;
      });
    }
  }

  Budget? _budgetForDate(DateTime date) {
    try {
      return _allBudgets.firstWhere((b) => b.month.isSameMonth(date));
    } catch (_) {
      return null;
    }
  }

  void _updateBudgetLimit(DateTime date, double newLimit) {
    setState(() {
      final index = _allBudgets.indexWhere((b) => b.month.isSameMonth(date));
      if (index != -1) {
        _allBudgets[index] = _allBudgets[index].copyWith(totalLimit: newLimit);
      } else {
        _allBudgets.add(Budget(month: date, totalLimit: newLimit));
      }
    });
  }

  void _updateCategoryFilter(
    DateTime date,
    Set<TransactionCategory> newFilter,
  ) {
    setState(() {
      final index = _allBudgets.indexWhere((b) => b.month.isSameMonth(date));
      if (index != -1) {
        _allBudgets[index] = _allBudgets[index].copyWith(filtering: newFilter);
      }
    });
  }

  void _goToPage(DateTime date) {
    _pageController.animateToPage(
      _dateToPage(date),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<TransactionCategorySummary> _createSummaries(
    FilterState filters,
    List<Transaction> transactions,
  ) {
    final filtered = filters
        .applyFilter(transactions)
        .where((t) => t.category != TransactionCategory.transfer)
        .toList();

    final double total = filtered.fold(
      0,
      (prev, t) => prev + (t.amountOut ?? 0),
    );

    final Map<TransactionCategory, double> grouped = {};
    for (final t in filtered) {
      grouped[t.category] = (grouped[t.category] ?? 0) + (t.amountOut ?? 0);
    }

    return grouped.entries
        .map(
          (e) => TransactionCategorySummary(
            category: e.key,
            totalSum: total,
            categorySum: e.value,
          ),
        )
        .where((e) => e.categorySum != 0)
        .toList()
      ..sort((a, b) => a.categorySum.compareTo(b.categorySum));
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

  Widget _buildMainBody() {
    return Scaffold(
      appBar: AppBar(title: const Text("Spending Insights")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              spacing: 8,
              children: [
                ScopeFilter(
                  selectedScope: _filters.scope,
                  onScopeChanged: (scope) => setState(
                    () => _filters = _filters.copyWith(
                      scope: scope,
                      referenceDate: DateTime.now(),
                    ),
                  ),
                ),
                PeriodFilter(
                  scope: _filters.scope,
                  referenceDate: _filters.referenceDate,
                  onReferenceDateChanged: (date) {
                    setState(() {
                      _filters = _filters.copyWith(referenceDate: date);
                      touchedIndex = -1;
                    });
                    if (_filters.scope == FilterScope.month) _goToPage(date);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _filters.scope == FilterScope.month
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _dateToPage(DateTime.now()) + 1,
                    onPageChanged: (page) {
                      setState(() {
                        _filters = _filters.copyWith(
                          referenceDate: _pageToDate(page),
                        );
                        touchedIndex = -1;
                      });
                    },
                    itemBuilder: (context, page) {
                      final pageDate = _pageToDate(page);
                      final pageFilters = _filters.copyWith(
                        referenceDate: pageDate,
                      );
                      final summaries = _createSummaries(
                        pageFilters,
                        widget.transactions,
                      );
                      final budget = _budgetForDate(pageDate);

                      return _buildPageContent(
                        summaries: summaries,
                        budget: budget,
                        pageDate: pageDate,
                      );
                    },
                  )
                : _buildPageContent(
                    summaries: _createSummaries(_filters, widget.transactions),
                    budget: null,
                    pageDate: _filters.referenceDate,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({
    required List<TransactionCategorySummary> summaries,
    required Budget? budget,
    required DateTime pageDate,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              if (_filters.scope == FilterScope.month)
                BudgetCard(
                  budget: budget,
                  summaries: summaries,
                  onBudgetUpdated: (newLimit) =>
                      _updateBudgetLimit(pageDate, newLimit),
                  onCategoryFilterChanged: (newFilter) =>
                      _updateCategoryFilter(pageDate, newFilter),
                ),
              SpendingPieChart(
                categorySummaries: summaries,
                touchedIndex: touchedIndex,
                onTouchedIndexChanged: (index) =>
                    setState(() => touchedIndex = index),
              ),
              SpendingBarChart(
                categorySummaries: summaries,
                touchedIndex: touchedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
