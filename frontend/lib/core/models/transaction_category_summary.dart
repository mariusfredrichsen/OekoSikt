import 'package:frontend/core/models/transaction_categories.dart';

class TransactionCategorySummary {
  final TransactionCategory category;
  final double categorySum;
  final double totalSum;

  TransactionCategorySummary({
    required this.category,
    required this.categorySum,
    required this.totalSum,
  });
}
