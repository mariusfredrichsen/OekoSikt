import 'package:flutter/material.dart';

enum NavigationItem {
  home("Home", Icons.home),
  history("History", Icons.history),
  spending("Spendings", Icons.bar_chart);

  final String label;
  final IconData icon;
  const NavigationItem(this.label, this.icon);
}
