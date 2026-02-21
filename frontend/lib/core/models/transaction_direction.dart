enum TransactionDirection {
  all('ALL'),
  outcome('OUT'),
  income('IN');

  final String label;
  const TransactionDirection(this.label);
}
