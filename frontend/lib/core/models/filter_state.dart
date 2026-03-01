import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';

enum FilterScope { month, year, all }

class FilterState {
  final TransactionDirection direction;
  final TransactionCategory category;
  final FilterScope scope;
  final DateTime referenceDate;
  final String searchQuery;
  final Set<TransactionCategory> categoryFilter;

  FilterState({
    this.direction = TransactionDirection.all,
    this.category = TransactionCategory.all,
    this.scope = FilterScope.month,
    this.searchQuery = "",
    DateTime? referenceDate,
    Set<TransactionCategory>? categoryFilter,
  }) : referenceDate =
           referenceDate ?? DateTime(DateTime.now().year, DateTime.now().month),
       categoryFilter =
           categoryFilter ?? {...TransactionCategory.expenseCategories};

  FilterState copyWith({
    TransactionDirection? direction,
    TransactionCategory? category,
    FilterScope? scope,
    DateTime? referenceDate,
    String? searchQuery,
    Set<TransactionCategory>? categoryFilter,
  }) {
    return FilterState(
      direction: direction ?? this.direction,
      category: category ?? this.category,
      scope: scope ?? this.scope,
      referenceDate: referenceDate ?? this.referenceDate,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  List<Transaction> applyFilter(List<Transaction> transactions) {
    return transactions.where((t) {
      final bool matchDir =
          direction == TransactionDirection.all ||
          (direction == TransactionDirection.outcome
              ? t.amountOut != null
              : t.amountIn != null);

      final bool matchCat =
          category == TransactionCategory.all || t.category == category;

      final bool matchQuery = t.cleanTitle.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      bool matchDate = true;

      if (scope == FilterScope.year) {
        matchDate = t.executionDate.year == referenceDate.year;
      } else if (scope == FilterScope.month) {
        matchDate =
            t.executionDate.year == referenceDate.year &&
            t.executionDate.month == referenceDate.month;
      }

      final bool matchCategoryList = categoryFilter.contains(t.category);

      return matchDir &&
          matchCat &&
          matchQuery &&
          matchDate &&
          matchCategoryList;
    }).toList();
  }
}
