import 'package:flutter/cupertino.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/theme/app_colors.dart';

class SpendingScopeFilter extends StatelessWidget {
  final FilterScope selectedScope;
  final ValueChanged<FilterScope> onScopeChanged;

  const SpendingScopeFilter({
    super.key,
    required this.selectedScope,
    required this.onScopeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<FilterScope>(
        groupValue: selectedScope,
        backgroundColor: AppColors.divider,
        thumbColor: AppColors.navy,
        onValueChanged: (scope) => scope != null ? onScopeChanged(scope) : null,
        children: {
          FilterScope.month: _buildLabel("Month", FilterScope.month),
          FilterScope.year: _buildLabel("Year", FilterScope.year),
        },
      ),
    );
  }

  Widget _buildLabel(String text, FilterScope scope) {
    final isSelected = selectedScope == scope;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.background : AppColors.navy,
      ),
    );
  }
}
