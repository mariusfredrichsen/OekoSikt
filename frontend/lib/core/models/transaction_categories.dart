import 'package:flutter/material.dart';

enum TransactionCategory {
  all('All Categories', Icons.all_inclusive, Color(0xFF64748B)), // Slate Grey
  food('Food & Dining', Icons.restaurant, Color(0xFFF59E0B)), // Amber/Orange
  shopping('Shopping', Icons.shopping_bag, Color(0xFFEC4899)), // Pink
  housing('Housing & Rent', Icons.home, Color(0xFF3B82F6)), // Blue
  transport(
    'Transportation',
    Icons.directions_car,
    Color(0xFF6366F1),
  ), // Indigo
  utilities(
    'Bills & Utilities',
    Icons.electrical_services,
    Color(0xFF06B6D4),
  ), // Cyan
  health(
    'Health & Wellness',
    Icons.medical_services,
    Color(0xFF10B981),
  ), // Emerald/Teal
  entertainment('Entertainment', Icons.movie, Color(0xFF8B5CF6)), // Purple
  income('Salary & Income', Icons.payments, Color(0xFF22C55E)), // Green
  transfer('Transfers', Icons.swap_horiz, Color(0xFF94A3B8)), // Light Slate
  other('Miscellaneous', Icons.more_horiz, Color(0xFF475569)); // Dark Grey

  final String label;
  final IconData icon;
  final Color color; // The new color property

  const TransactionCategory(this.label, this.icon, this.color);

  static TransactionCategory fromString(String value) {
    final cleanValue = value.trim().toLowerCase();

    return TransactionCategory.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == cleanValue ||
          e.label.toLowerCase() == cleanValue,
      orElse: () => TransactionCategory.other,
    );
  }
}
