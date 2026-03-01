import 'package:flutter/material.dart';
import 'package:frontend/core/models/budget.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widget/bar/budget_bar.dart';
import 'package:frontend/core/widget/cards/card_container.dart';
import 'package:frontend/core/widget/icons/icon_container.dart';
import 'package:frontend/core/widget/labels/budget_tracking.dart';
import 'package:frontend/features/spending/pages/budget_page.dart';

class BudgetCard extends StatelessWidget {
  final Budget? budget;
  final List<TransactionCategorySummary> summaries;
  final Function(double) onBudgetUpdated;
  final ValueChanged<Set<TransactionCategory>> onCategoryFilterChanged;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.summaries,
    required this.onBudgetUpdated,
    required this.onCategoryFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (budget == null) return _buildEmptyState(context);

    final double totalSpent = summaries
        .where((s) => budget!.filtering.contains(s.category))
        .fold(0.0, (prev, s) => prev + s.categorySum.abs());

    final double progress = budget!.totalLimit > 0
        ? totalSpent / budget!.totalLimit
        : 0.0;

    return CardContainer(
      color: AppColors.softBlue,
      title: _buildHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          _buildProgressBar(progress),
          _buildFooter(totalSpent, progress),
          _buildCategoryChips(),
        ],
      ),
      actions: [Expanded(child: _buildEditButton(context, budget!.totalLimit))],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          spacing: 8,
          children: [
            IconContainer(
              color: AppColors.blue200,
              child: const Icon(Icons.savings, size: 18),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MONTHLY BUDGET",
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Tracked spending limit",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text("${budget!.totalLimit.round()} NOK", style: _valueStyle),
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

  Widget _buildCategoryChips() {
    final allExpense = TransactionCategory.expenseCategories;
    final filtered = budget!.filtering;
    final excluded = allExpense.where((c) => !filtered.contains(c)).toList();

    final double untrackedAmount = summaries
        .where((s) => !filtered.contains(s.category))
        .fold(0.0, (prev, s) => prev + s.categorySum.abs());

    if (excluded.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                spacing: 4,
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    "NOT COUNTED",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              if (untrackedAmount > 0)
                Row(
                  spacing: 3,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${untrackedAmount.toStringAsFixed(0)} NOK",
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: excluded.map((cat) => _buildChip(cat, false)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(TransactionCategory cat, bool included) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: included ? cat.color.withAlpha(20) : AppColors.gray100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: included ? cat.color.withAlpha(80) : AppColors.gray200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(
            cat.icon,
            size: 9,
            color: included ? cat.color : AppColors.gray400,
          ),
          Text(
            cat.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: included ? cat.color : AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CardContainer(
      color: AppColors.softBlue,
      title: Row(
        spacing: 8,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 14,
              color: AppColors.navy,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MONTHLY BUDGET",
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "Tracked spending limit",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        spacing: 12,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  "No budget set",
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Set a monthly limit to track your spending",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [Expanded(child: _buildCreateButton(context))],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openBudgetPage(context, 5000, {
          ...TransactionCategory.expenseCategories,
        }),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Icon(Icons.add, color: AppColors.surface, size: 14),
              Text(
                "CREATE BUDGET",
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, double limit) {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => _openBudgetPage(context, limit, budget!.filtering),
        child: const Text(
          "EDIT BUDGET",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _openBudgetPage(
    BuildContext context,
    double initialBudget,
    Set<TransactionCategory> initialFilter,
  ) async {
    final result = await Navigator.push<(double, Set<TransactionCategory>)>(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetPage(
          summaries: summaries,
          currentBudget: initialBudget,
          categoryFilter: initialFilter,
        ),
      ),
    );
    if (result != null) {
      final (newBudget, newFilter) = result;
      onBudgetUpdated(newBudget);
      onCategoryFilterChanged(newFilter);
    }
  }

  static const _labelStyle = TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
    fontSize: 10,
  );
  static const _valueStyle = TextStyle(
    color: AppColors.navy,
    fontWeight: FontWeight.w800,
    fontSize: 14,
  );
}
