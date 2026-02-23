import 'package:flutter/cupertino.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/theme/app_colors.dart';

class ScopeFilter extends StatelessWidget {
  final FilterScope selectedScope;
  final ValueChanged<FilterScope> onScopeChanged;

  const ScopeFilter({
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
          FilterScope.month: _buildSegmentText("Month", FilterScope.month),
          FilterScope.year: _buildSegmentText("Year", FilterScope.year),
        },
      ),
    );
  }

  Widget _buildSegmentText(String text, FilterScope scope) {
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
