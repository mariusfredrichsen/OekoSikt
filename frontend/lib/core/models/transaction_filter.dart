enum TransactionFilter {
  all('ALL'),
  outcome('OUT'),
  income('IN');

  final String label;
  const TransactionFilter(this.label);
}
