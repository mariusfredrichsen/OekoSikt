import 'package:flutter/material.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/utils/date_extention.dart';

class SpendingPeriodFilter extends StatelessWidget {
  final FilterScope scope;
  final DateTime referenceDate;
  final ValueChanged<DateTime> onReferenceDateChanged;

  const SpendingPeriodFilter({
    super.key,
    required this.scope,
    required this.referenceDate,
    required this.onReferenceDateChanged,
  });

  bool get _isAtPresent {
    if (scope == FilterScope.month) return referenceDate.isCurrentMonth;
    return referenceDate.isCurrentYear;
  }

  String get _label {
    if (scope == FilterScope.year) return '${referenceDate.year}';
    return referenceDate.toMonthTitle();
  }

  void _step(int direction) {
    final date = scope == FilterScope.month
        ? DateTime(referenceDate.year, referenceDate.month + direction)
        : DateTime(referenceDate.year + direction, referenceDate.month);
    onReferenceDateChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.chevron_left,
            enabled: true,
            onTap: () => _step(-1),
          ),
          _buildLabel(),
          _NavButton(
            icon: Icons.chevron_right,
            enabled: !_isAtPresent,
            onTap: () => _step(1),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5.0,
      children: [
        GestureDetector(
          onTap: () {
            // TODO: open calendar picker
          },
          child: const Icon(
            Icons.calendar_month,
            size: 14,
            color: AppColors.navy,
          ),
        ),
        Text(
          _label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.navy,
          ),
        ),
        if (_isAtPresent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'CURRENT',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: AppColors.gray200.withAlpha(enabled ? 200 : 20),
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.navy : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
