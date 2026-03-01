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
                aspectRatio: 1.5,
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
            : AppColors.gray300,
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
