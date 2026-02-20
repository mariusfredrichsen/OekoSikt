import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_filter.dart';
import 'package:frontend/core/theme/app_colors.dart';

class ActivityFilterBar extends StatelessWidget {
  const ActivityFilterBar({
    super.key,
    required this.selectedTransactionFilter,
    required this.onFilterChange,
    required this.selectedTransactionCategory,
    required this.onCategoryChange,
  });

  final TransactionFilter selectedTransactionFilter;
  final ValueChanged<TransactionFilter> onFilterChange;
  final TransactionCategory selectedTransactionCategory;
  final ValueChanged<TransactionCategory> onCategoryChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 32,
              child: CupertinoSlidingSegmentedControl<TransactionFilter>(
                groupValue: selectedTransactionFilter,
                backgroundColor: AppColors.divider,
                thumbColor: AppColors.surface,
                onValueChanged: (value) =>
                    value != null ? onFilterChange(value) : null,
                children: {
                  TransactionFilter.all: _buildSegmentText(
                    'ALL',
                    TransactionFilter.all,
                  ),
                  TransactionFilter.outcome: _buildSegmentText(
                    'OUT',
                    TransactionFilter.outcome,
                  ),
                  TransactionFilter.income: _buildSegmentText(
                    'IN',
                    TransactionFilter.income,
                  ),
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TransactionCategory>(
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.navy,
                  ),
                  value: selectedTransactionCategory,
                  items: TransactionCategory.values.map((tc) {
                    return DropdownMenuItem<TransactionCategory>(
                      value: tc,
                      child: Row(
                        children: [
                          Icon(tc.icon, size: 16, color: AppColors.navy),
                          const SizedBox(width: 8),
                          Text(
                            tc.label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      newValue != null ? onCategoryChange(newValue) : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentText(String text, TransactionFilter filter) {
    final isSelected = selectedTransactionFilter == filter;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.navy : AppColors.textSecondary,
      ),
    );
  }
}
