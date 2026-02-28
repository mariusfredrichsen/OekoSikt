import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';

class SpendingPieChart extends StatelessWidget {
  final List<TransactionCategorySummary> categorySummaries;
  final int touchedIndex;
  final ValueChanged<int> onTouchedIndexChanged;

  const SpendingPieChart({
    super.key,
    required this.categorySummaries,
    required this.touchedIndex,
    required this.onTouchedIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (categorySummaries.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final double totalSum = categorySummaries.fold(0.0, (prev, cat) {
      return prev + cat.categorySum * -1;
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                onTouchedIndexChanged(
                                  (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null)
                                      ? -1
                                      : pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex,
                                );
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 55,
                        sections: _showingSections(),
                      ),
                    ),
                    Center(
                      child: _buildCenterTotal(
                        touchedIndex == -1
                            ? totalSum
                            : categorySummaries[touchedIndex].categorySum * -1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(categorySummaries.length, (index) {
                final summary = categorySummaries[index];
                return _buildIndicator(
                  color: touchedIndex == -1 || touchedIndex == index
                      ? summary.category.color
                      : Colors.grey,
                  text: summary.category.label,
                  isSelected: touchedIndex == index,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildCenterTotal(double totalSum) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "TOTAL",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 8,
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: totalSum),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutExpo,
          builder: (context, value, child) {
            return Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            );
          },
        ),
        Text(
          "NOK",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required Color color,
    required String text,
    required bool isSelected,
  }) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 14 : 10,
                height: isSelected ? 14 : 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Opacity(
                opacity: 0,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.navy : AppColors.textSecondary,
                ),
                child: Text(text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(categorySummaries.length, (i) {
      final summary = categorySummaries[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 14.0 : 10.0;
      final radius = isTouched ? 45.0 : 35.0;

      final double percentage = (summary.categorySum / summary.totalSum) * 100;

      return PieChartSectionData(
        color: touchedIndex == -1 || isTouched
            ? summary.category.color
            : Colors.grey,
        value: summary.categorySum,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
