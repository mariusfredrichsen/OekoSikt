import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/core/theme/app_colors.dart';

class FilterBar extends StatelessWidget {
  final TransactionDirection selectedDirection;
  final TransactionCategory selectedCategory;
  final ValueChanged<TransactionDirection> onDirectionChanged;
  final ValueChanged<TransactionCategory> onCategoryChanged;

  const FilterBar({
    super.key,
    required this.selectedDirection,
    required this.selectedCategory,
    required this.onDirectionChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 32,
              child: CupertinoSlidingSegmentedControl<TransactionDirection>(
                groupValue: selectedDirection,
                backgroundColor: AppColors.divider,
                thumbColor: AppColors.surface,
                onValueChanged: (value) =>
                    value != null ? onDirectionChanged(value) : null,
                children: {
                  TransactionDirection.all: _buildSegmentText(
                    TransactionDirection.all,
                  ),
                  TransactionDirection.outcome: _buildSegmentText(
                    TransactionDirection.outcome,
                  ),
                  TransactionDirection.income: _buildSegmentText(
                    TransactionDirection.income,
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
                  value: selectedCategory,
                  items: TransactionCategory.values.map((tc) {
                    return DropdownMenuItem<TransactionCategory>(
                      value: tc,
                      child: Row(
                        children: [
                          Icon(tc.icon, size: 16, color: AppColors.navy),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tc.label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      newValue != null ? onCategoryChanged(newValue) : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentText(TransactionDirection direction) {
    final isSelected = selectedDirection == direction;
    return Text(
      direction.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.navy : AppColors.textSecondary,
      ),
    );
  }
}
