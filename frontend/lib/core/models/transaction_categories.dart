import 'package:flutter/material.dart';

enum TransactionCategory {
  all('All Categories', Icons.all_inclusive),
  food('Food & Dining', Icons.restaurant),
  shopping('Shopping', Icons.shopping_bag),
  housing('Housing & Rent', Icons.home),
  transport('Transportation', Icons.directions_car),
  utilities('Bills & Utilities', Icons.electrical_services),
  health('Health & Wellness', Icons.medical_services),
  entertainment('Entertainment', Icons.movie),
  income('Salary & Income', Icons.payments),
  transfer('Transfers', Icons.swap_horiz),
  other('Miscellaneous', Icons.more_horiz);

  final String label;
  final IconData icon;

  const TransactionCategory(this.label, this.icon);
}
