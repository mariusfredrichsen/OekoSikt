import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';

class SpendingPieChart extends StatefulWidget {
  final List<TransactionCategorySummary> categorySummaries;

  const SpendingPieChart({super.key, required this.categorySummaries});

  @override
  State<SpendingPieChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categorySummaries.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return Card(
      child: Container(
        padding: EdgeInsets.all(12),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Row(
            children: <Widget>[
              const SizedBox(height: 18),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 1,
                      centerSpaceRadius: 35,
                      sections: _showingSections(),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.categorySummaries.map((summary) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _Indicator(
                      color: summary.category.color,
                      text: summary.category.label,
                      isSquare: true,
                      textColor:
                          touchedIndex ==
                              widget.categorySummaries.indexOf(summary)
                          ? AppColors.navy
                          : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(widget.categorySummaries.length, (i) {
      final summary = widget.categorySummaries[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;

      // Calculate percentage for the label
      final double percentage = (summary.categorySum / summary.totalSum) * 100;

      return PieChartSectionData(
        color: summary.category.color,
        value: summary.categorySum,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // High contrast
        ),
      );
    });
  }
}

// Simple internal Indicator widget since you were using it in your snippet
class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final Color? textColor;

  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            borderRadius: isSquare ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
