extension DateNavigation on DateTime {
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isCurrentYear => year == DateTime.now().year;

  DateTime nextMonth() => DateTime(year, month + 1);
  DateTime prevMonth() => DateTime(year, month - 1);
  DateTime nextYear() => DateTime(year + 1, month);
  DateTime prevYear() => DateTime(year - 1, month);

  String toMonthTitle() {
    const months = [
      "",
      "JANUARY",
      "FEBRUARY",
      "MARCH",
      "APRIL",
      "MAY",
      "JUNE",
      "JULY",
      "AUGUST",
      "SEPTEMBER",
      "OCTOBER",
      "NOVEMBER",
      "DECEMBER",
    ];
    return "${months[month]} $year";
  }
}
