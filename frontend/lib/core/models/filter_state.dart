import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';

enum FilterScope { month, year, all } // Added 'all'

class FilterState {
  final TransactionDirection direction;
  final TransactionCategory category;
  final FilterScope scope;
  final DateTime referenceDate;
  final String searchQuery;

  FilterState({
    this.direction = TransactionDirection.all,
    this.category = TransactionCategory.all,
    this.scope = FilterScope.month, // Default for Spending
    this.searchQuery = "",
    DateTime? referenceDate,
  }) : referenceDate =
           referenceDate ?? DateTime(DateTime.now().year, DateTime.now().month);

  FilterState copyWith({
    TransactionDirection? direction,
    TransactionCategory? category,
    FilterScope? scope,
    DateTime? referenceDate,
    String? searchQuery,
  }) {
    return FilterState(
      direction: direction ?? this.direction,
      category: category ?? this.category,
      scope: scope ?? this.scope,
      referenceDate: referenceDate ?? this.referenceDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Transaction> applyFilter(List<Transaction> transactions) {
    return transactions.where((t) {
      // 1. Direction Filter
      final bool matchDir =
          direction == TransactionDirection.all ||
          (direction == TransactionDirection.outcome
              ? t.amountOut != null
              : t.amountIn != null);

      // 2. Category Filter
      final bool matchCat =
          category == TransactionCategory.all || t.category == category;

      // 3. Search Query Filter
      final bool matchQuery = t.cleanTitle.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      // 4. Time Filter (Now includes 'all' check)
      bool matchDate =
          true; // Default to true so it doesn't block if scope is 'all'

      if (scope == FilterScope.year) {
        matchDate = t.executionDate.year == referenceDate.year;
      } else if (scope == FilterScope.month) {
        matchDate =
            t.executionDate.year == referenceDate.year &&
            t.executionDate.month == referenceDate.month;
      }
      // If scope is FilterScope.all, matchDate stays true.

      return matchDir && matchCat && matchQuery && matchDate;
    }).toList();
  }
}
