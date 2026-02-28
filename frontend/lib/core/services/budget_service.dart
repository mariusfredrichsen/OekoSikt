import 'package:frontend/core/models/budget.dart';

class BudgetService {
  static Future<List<Budget>> loadMonthlyBudgets() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final List<Budget> dummyBudgets = [];
    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);

      final double variedBudget = 5000 + i * 100;

      dummyBudgets.add(Budget(month: monthDate, totalLimit: variedBudget));
    }

    return dummyBudgets;
  }

  static Future<void> saveMonthylyBudgets() async {
    // change or do a post request
  }
}
