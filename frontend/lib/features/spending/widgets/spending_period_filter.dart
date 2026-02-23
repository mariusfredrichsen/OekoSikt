import 'package:flutter/material.dart';
import 'package:frontend/core/models/filter_state.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/utils/date_extention.dart';

class PeriodFilter extends StatelessWidget {
  final FilterScope scope;
  final DateTime referenceDate;
  final ValueChanged<DateTime> onReferenceDateChanged;

  const PeriodFilter({
    super.key,
    required this.scope,
    required this.referenceDate,
    required this.onReferenceDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCalenderButton(
            icon: Icons.chevron_left,
            onTap: () {
              _handleStep(-1);
            },
            enabled: true,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5.0,
            children: [
              GestureDetector(
                child: Icon(
                  Icons.calendar_month,
                  size: 14,
                  color: AppColors.navy,
                ),
                onTap: () {
                  // select a month with a calender popup
                },
              ),
              Text(
                _getLabel(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.navy,
                ),
              ),
              ?(scope == FilterScope.month && referenceDate.isCurrentMonth ||
                      scope == FilterScope.year && referenceDate.isCurrentYear)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Text(
                        "CURRENT",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : null,
            ],
          ),
          _buildCalenderButton(
            icon: Icons.chevron_right,
            onTap: () {
              _handleStep(1);
            },
            enabled: !_isFuture(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalenderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.grey.withAlpha(enabled ? 50 : 5),
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

  void _handleStep(int step) {
    if (scope == FilterScope.month) {
      onReferenceDateChanged(
        DateTime(referenceDate.year, referenceDate.month + step),
      );
    } else {
      onReferenceDateChanged(
        DateTime(referenceDate.year + step, referenceDate.month),
      );
    }
  }

  String _getLabel() {
    if (scope == FilterScope.year) return "${referenceDate.year}";
    return referenceDate.toMonthTitle();
  }

  bool _isFuture() {
    final now = DateTime.now();
    if (scope == FilterScope.month) {
      return referenceDate.year >= now.year && referenceDate.month >= now.month;
    }
    return referenceDate.year >= now.year;
  }
}
