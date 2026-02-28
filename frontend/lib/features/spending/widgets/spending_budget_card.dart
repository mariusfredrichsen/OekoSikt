import 'package:flutter/material.dart';
import 'package:frontend/core/models/budget.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widget/bar/budget_bar.dart';
import 'package:frontend/core/widget/cards/card_container.dart';
import 'package:frontend/core/widget/labels/budget_tracking.dart';
import 'package:frontend/features/spending/widgets/spending_budget_dialog.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final List<TransactionCategorySummary> summaries;
  final Function(double) onBudgetUpdated;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.summaries,
    required this.onBudgetUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final double totalSpent = summaries
        .fold(0.0, (prev, s) => prev + s.categorySum)
        .abs();

    final double progress = budget.totalLimit > 0
        ? totalSpent / budget.totalLimit
        : 0.0;

    return CardContainer(
      color: AppColors.softBlue,
      title: _buildHeader(),
      body: Column(
        children: [
          _buildProgressBar(progress),
          const SizedBox(height: 12),
          _buildFooter(totalSpent, progress),
        ],
      ),
      actions: [
        Expanded(
          child: _buildEditButton(context, totalSpent, budget.totalLimit),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, double spent, double limit) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () async {
        final double? result = await showDialog<double>(
          context: context,
          builder: (context) =>
              BudgetDialog(currentSpending: spent, currentBudget: limit),
        );
        if (result != null) onBudgetUpdated(result);
      },
      child: const Text(
        "EDIT BUDGET",
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("MONTHLY BUDGET", style: _labelStyle),
        Text("${budget.totalLimit.round()} NOK", style: _valueStyle),
      ],
    );
  }

  Widget _buildProgressBar(double value) {
    return SizedBox(
      width: double.infinity,
      child: BudgetBar(value: value.clamp(0.0, 1.0)),
    );
  }

  Widget _buildFooter(double totalSpent, double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              totalSpent.round().toString(),
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Text("NOK spent", style: _labelStyle),
          ],
        ),
        BudgetTracking(value: progress),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
    fontSize: 10,
  );
  static const _valueStyle = TextStyle(
    color: AppColors.navy,
    fontWeight: FontWeight.w800,
    fontSize: 13,
  );
}
