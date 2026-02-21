import 'package:frontend/core/models/time_period.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';

class TransactionFilterState {
  final TransactionDirection direction;
  final TransactionCategory category;
  final TimePeriod period;

  TransactionFilterState({
    this.direction = TransactionDirection.all,
    this.category = TransactionCategory.all,
    this.period = TimePeriod.month,
  });

  TransactionFilterState copyWith({
    TransactionDirection? direction,
    TransactionCategory? category,
    TimePeriod? period,
  }) {
    return TransactionFilterState(
      direction: direction ?? this.direction,
      category: category ?? this.category,
      period: period ?? this.period,
    );
  }
}
