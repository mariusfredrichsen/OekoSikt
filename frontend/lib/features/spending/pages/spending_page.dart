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

  static final DateTime _epoch = DateTime(2020, 1);

  late final PageController _monthPageController;
  late final PageController _yearPageController;

  int _monthToPage(DateTime date) =>
      (date.year - _epoch.year) * 12 + (date.month - _epoch.month);

  DateTime _pageToMonth(int page) {
    final totalMonths = _epoch.month + page - 1;
    return DateTime(_epoch.year + totalMonths ~/ 12, totalMonths % 12 + 1);
  }

  int _yearToPage(int year) => year - _epoch.year;
  int _pageToYear(int page) => _epoch.year + page;

  @override
  void initState() {
    super.initState();
    _monthPageController = PageController(
      initialPage: _monthToPage(_filters.referenceDate),
    );
    _yearPageController = PageController(
      initialPage: _yearToPage(_filters.referenceDate.year),
    );
    _loadBudgets();
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    _yearPageController.dispose();
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

  void _onScopeChanged(FilterScope scope) {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    setState(() {
      _filters = _filters.copyWith(scope: scope, referenceDate: now);
      _touchedIndex = -1;
    });
    if (_monthPageController.hasClients) {
      _monthPageController.jumpToPage(_monthToPage(now));
    }
    if (_yearPageController.hasClients) {
      _yearPageController.jumpToPage(_yearToPage(now.year));
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _filters = _filters.copyWith(referenceDate: date);
      _touchedIndex = -1;
    });
    _syncPageControllers(date, animate: true);
  }

  void _syncPageControllers(DateTime date, {bool animate = false}) {
    final monthPage = _monthToPage(date);
    final yearPage = _yearToPage(date.year);

    void jump(PageController c, int page) {
      if (c.hasClients) c.jumpToPage(page);
    }

    void go(PageController c, int page) {
      if (!c.hasClients) return;
      animate
          ? c.animateToPage(
              page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
          : c.jumpToPage(page);
    }

    if (_filters.scope == FilterScope.month) {
      go(_monthPageController, monthPage);
      jump(_yearPageController, yearPage);
    } else {
      go(_yearPageController, yearPage);
      jump(_monthPageController, monthPage);
    }
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
          Expanded(child: _buildPageViews()),
        ],
      ),
    );
  }

  Widget _buildPageViews() {
    if (_filters.scope == FilterScope.month) {
      return PageView.builder(
        controller: _monthPageController,
        itemCount: _monthToPage(DateTime.now()) + 1,
        onPageChanged: (page) {
          final date = _pageToMonth(page);
          setState(() {
            _filters = _filters.copyWith(referenceDate: date);
            _touchedIndex = -1;
          });
          if (_yearPageController.hasClients) {
            _yearPageController.jumpToPage(_yearToPage(date.year));
          }
        },
        itemBuilder: (context, page) {
          final date = _pageToMonth(page);
          final summaries = _buildSummaries(
            _filters.copyWith(referenceDate: date),
          );
          return SpendingContent(
            summaries: summaries,
            budget: _budgetFor(date),
            scope: _filters.scope,
            touchedIndex: _touchedIndex,
            onTouchedIndexChanged: (i) => setState(() => _touchedIndex = i),
            onBudgetUpdated: (limit) => _updateBudgetLimit(date, limit),
            onCategoryFilterChanged: (filter) =>
                _updateCategoryFilter(date, filter),
          );
        },
      );
    }

    return PageView.builder(
      controller: _yearPageController,
      itemCount: _yearToPage(DateTime.now().year) + 1,
      onPageChanged: (page) {
        final date = DateTime(_pageToYear(page), _filters.referenceDate.month);
        setState(() {
          _filters = _filters.copyWith(referenceDate: date);
          _touchedIndex = -1;
        });
        if (_monthPageController.hasClients) {
          _monthPageController.jumpToPage(_monthToPage(date));
        }
      },
      itemBuilder: (context, page) {
        final date = DateTime(_pageToYear(page), _filters.referenceDate.month);
        final summaries = _buildSummaries(
          _filters.copyWith(referenceDate: date),
        );
        return SpendingContent(
          summaries: summaries,
          budget: null,
          scope: _filters.scope,
          touchedIndex: _touchedIndex,
          onTouchedIndexChanged: (i) => setState(() => _touchedIndex = i),
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
