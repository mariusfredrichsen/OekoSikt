enum TimePeriod {
  week("Past week"),
  month("Past month"),
  year("");

  final String label;

  const TimePeriod(this.label);
}
