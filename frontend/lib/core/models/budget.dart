import 'package:frontend/core/models/transaction_categories.dart';

class Budget {
  final DateTime month;
  final double totalLimit;
  final Set<TransactionCategory> filtering;

  Budget({
    required this.month,
    this.totalLimit = 5000.0,
    Set<TransactionCategory>? filtering,
  }) : filtering = filtering ?? {...TransactionCategory.values};

  Budget copyWith({
    DateTime? month,
    double? totalLimit,
    Set<TransactionCategory>? filtering,
  }) {
    return Budget(
      month: month ?? this.month,
      totalLimit: totalLimit ?? this.totalLimit,
      filtering: filtering ?? this.filtering,
    );
  }

  bool isForDate(DateTime date) {
    return month.year == date.year && month.month == date.month;
  }
}
