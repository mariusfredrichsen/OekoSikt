import 'package:flutter/material.dart';

enum TransactionCategory {
  all('All', 'All transactions', Icons.all_inclusive, Color(0xFF64748B)),
  food('Food', 'Food & Dining', Icons.restaurant, Color(0xFFF59E0B)),
  shopping('Shopping', 'Shopping', Icons.shopping_bag, Color(0xFFEC4899)),
  housing('Housing', 'Housing & Rent', Icons.home, Color(0xFF3B82F6)),
  transport(
    'Transport',
    'Transportation',
    Icons.directions_car,
    Color(0xFF6366F1),
  ),
  utilities(
    'Bills',
    'Bills & Utilities',
    Icons.electrical_services,
    Color(0xFF06B6D4),
  ),
  health(
    'Health',
    'Health & Wellness',
    Icons.medical_services,
    Color(0xFF10B981),
  ),
  entertainment('Fun', 'Entertainment', Icons.movie, Color(0xFF8B5CF6)),
  income('Income', 'Salary & Income', Icons.payments, Color(0xFF22C55E)),
  transfer('Transfer', 'Transfers', Icons.swap_horiz, Color(0xFF94A3B8)),
  other('Other', 'Miscellaneous', Icons.more_horiz, Color(0xFF475569));

  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const TransactionCategory(
    this.label,
    this.description,
    this.icon,
    this.color,
  );

  static TransactionCategory fromString(String value) {
    final cleanValue = value.trim().toLowerCase();

    return TransactionCategory.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == cleanValue ||
          e.label.toLowerCase() == cleanValue ||
          e.description.toLowerCase() == cleanValue,
      orElse: () => TransactionCategory.other,
    );
  }

  static List<TransactionCategory> get expenseCategories {
    return TransactionCategory.values
        .where(
          (cat) => !{
            TransactionCategory.all,
            TransactionCategory.income,
          }.contains(cat),
        )
        .toList();
  }
}
