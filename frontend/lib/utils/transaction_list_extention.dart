import 'package:frontend/core/models/transaction.dart';

extension TransactionListX on List<Transaction> {
  double get totalSpent {
    return fold(0.0, (sum, t) => sum + (t.amountOut?.abs() ?? 0.0));
  }

  double get totalIncome {
    return fold(0.0, (sum, t) => sum + (t.amountIn ?? 0.0));
  }

  double get netBalance => totalIncome - totalSpent;
}
