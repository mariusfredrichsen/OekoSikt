import 'package:flutter/material.dart';
import 'package:frontend/core/models/budget.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/services/budget_service.dart';
import 'package:frontend/features/spending/widgets/spending_content.dart';
import 'package:frontend/features/spending/widgets/spending_period_filter.dart';
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
  List<Budget> _budgets = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _touchedIndex = -1;

  static const int _epochYear = 2020;
  static const int _epochMonth = 1;

  static const int _epochAbsMonth = _epochYear * 12 + _epochMonth - 1;

  late PageController _pageController;

  int _monthToPage(DateTime d) => (d.year * 12 + d.month - 1) - _epochAbsMonth;

  DateTime _pageToMonth(int page) {
    final abs = _epochAbsMonth + page;
    return DateTime(abs ~/ 12, abs % 12 + 1);
  }

  int _yearToPage(int year) => year - _epochYear;
  int _pageToYear(int page) => _epochYear + page;

  int get _currentPage => _filters.scope == FilterScope.month
      ? _monthToPage(_filters.referenceDate)
      : _yearToPage(_filters.referenceDate.year);

  int get _maxPage {
    final now = DateTime.now();
    return _filters.scope == FilterScope.month
        ? _monthToPage(DateTime(now.year, now.month))
        : _yearToPage(now.year);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _loadBudgets();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    try {
      final budgets = await BudgetService.loadMonthlyBudgets();
      setState(() {
        _budgets = budgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load budgets: $e';
        _isLoading = false;
      });
    }
  }

  Budget? _budgetFor(DateTime date) {
    try {
      return _budgets.firstWhere((b) => b.month.isSameMonth(date));
    } catch (_) {
      return null;
    }
  }

  void _updateBudgetLimit(DateTime date, double newLimit) {
    setState(() {
      final i = _budgets.indexWhere((b) => b.month.isSameMonth(date));
      if (i != -1) {
        _budgets[i] = _budgets[i].copyWith(totalLimit: newLimit);
      } else {
        _budgets.add(Budget(month: date, totalLimit: newLimit));
      }
    });
  }

  void _updateCategoryFilter(DateTime date, Set<TransactionCategory> filter) {
    setState(() {
      final i = _budgets.indexWhere((b) => b.month.isSameMonth(date));
      if (i != -1) {
        _budgets[i] = _budgets[i].copyWith(filtering: filter);
      }
    });
  }

  void _onScopeChanged(FilterScope newScope) {
    if (newScope == _filters.scope) return;

    final now = DateTime(DateTime.now().year, DateTime.now().month);
    final newFilters = _filters.copyWith(scope: newScope, referenceDate: now);

    final newPage = newScope == FilterScope.month
        ? _monthToPage(now)
        : _yearToPage(now.year);

    _pageController.dispose();
    _pageController = PageController(initialPage: newPage);

    setState(() {
      _filters = newFilters;
      _touchedIndex = -1;
    });
  }

  void _onDateChanged(DateTime date) {
    final newPage = _filters.scope == FilterScope.month
        ? _monthToPage(date)
        : _yearToPage(date.year);

    setState(() {
      _filters = _filters.copyWith(referenceDate: date);
      _touchedIndex = -1;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        newPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    final date = _filters.scope == FilterScope.month
        ? _pageToMonth(page)
        : DateTime(_pageToYear(page), _filters.referenceDate.month);

    setState(() {
      _filters = _filters.copyWith(referenceDate: date);
      _touchedIndex = -1;
    });
  }

  List<TransactionCategorySummary> _buildSummaries(FilterState filters) {
    final transactions = filters
        .applyFilter(widget.transactions)
        .where((t) => t.category != TransactionCategory.transfer)
        .toList();

    final total = transactions.fold(0.0, (sum, t) => sum + (t.amountOut ?? 0));

    final grouped = <TransactionCategory, double>{};
    for (final t in transactions) {
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
        .where((s) => s.categorySum != 0)
        .toList()
      ..sort((a, b) => a.categorySum.compareTo(b.categorySum));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Insights')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              spacing: 8,
              children: [
                SpendingScopeFilter(
                  selectedScope: _filters.scope,
                  onScopeChanged: _onScopeChanged,
                ),
                SpendingPeriodFilter(
                  scope: _filters.scope,
                  referenceDate: _filters.referenceDate,
                  onReferenceDateChanged: _onDateChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildPageView()),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      key: ValueKey(_filters.scope),
      controller: _pageController,
      itemCount: _maxPage + 1,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, page) {
        final date = _filters.scope == FilterScope.month
            ? _pageToMonth(page)
            : DateTime(_pageToYear(page), _filters.referenceDate.month);

        final pageFilters = _filters.copyWith(referenceDate: date);
        final summaries = _buildSummaries(pageFilters);
        final isMonthScope = _filters.scope == FilterScope.month;

        return SpendingContent(
          summaries: summaries,
          budget: isMonthScope ? _budgetFor(date) : null,
          scope: _filters.scope,
          touchedIndex: _touchedIndex,
          onTouchedIndexChanged: (i) => setState(() => _touchedIndex = i),
          onBudgetUpdated: isMonthScope
              ? (limit) => _updateBudgetLimit(date, limit)
              : null,
          onCategoryFilterChanged: isMonthScope
              ? (filter) => _updateCategoryFilter(date, filter)
              : null,
        );
      },
    );
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
                _loadBudgets();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
