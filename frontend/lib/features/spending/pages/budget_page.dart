import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_category_summary.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widget/bar/budget_bar.dart';
import 'package:frontend/core/widget/cards/card_container.dart';
import 'package:frontend/core/widget/labels/budget_tracking.dart';

class BudgetPage extends StatefulWidget {
  final List<TransactionCategorySummary> summaries;
  final double currentBudget;
  final Set<TransactionCategory> categoryFilter;

  const BudgetPage({
    super.key,
    required this.summaries,
    required this.currentBudget,
    required this.categoryFilter,
  });

  @override
  State<StatefulWidget> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late double _newBudget;
  late Set<TransactionCategory> _newCategoryFilter;
  late TextEditingController _amountController;

  double get _filteredSpending => widget.summaries
      .where((s) => _newCategoryFilter.contains(s.category))
      .fold(0.0, (prev, s) => prev + s.categorySum.abs());

  @override
  void initState() {
    super.initState();
    _newBudget = widget.currentBudget;
    _newCategoryFilter = {...widget.categoryFilter};
    _amountController = TextEditingController(
      text: _newBudget.round().toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setBudgetFromUI(double value) {
    setState(() {
      _newBudget = value;
      _amountController.value = TextEditingValue(
        text: value.round().toString(),
        selection: TextSelection.collapsed(
          offset: value.round().toString().length,
        ),
      );
    });
  }

  void _setBudgetFromInput(double value) {
    setState(() => _newBudget = value);
  }

  void _toggleCategory(TransactionCategory cat) {
    setState(() {
      if (_newCategoryFilter.contains(cat)) {
        _newCategoryFilter = {..._newCategoryFilter}..remove(cat);
      } else {
        _newCategoryFilter = {..._newCategoryFilter, cat};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.background),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text("Edit Budget"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBudgetPreview(),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  spacing: 16,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          spacing: 16,
                          children: [
                            _buildInputField(),
                            _buildQuickSelect(),
                            _buildSlider(),
                          ],
                        ),
                      ),
                    ),
                    _buildCategoryCard(),
                  ],
                ),
              ),
            ),

            const Divider(
              height: 1,
              color: AppColors.borderDefault,
              thickness: 2,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Material(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.of(
                          context,
                        ).pop((_newBudget, _newCategoryFilter)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.check,
                                color: AppColors.surface,
                                size: 16,
                              ),
                              Text(
                                "SAVE BUDGET",
                                style: TextStyle(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPreview() {
    final double spending = _filteredSpending;
    final double usageRatio = _newBudget > 0 ? spending / _newBudget : 0.0;

    final Color spendingColor = usageRatio >= 1.0
        ? AppColors.red600
        : usageRatio >= 0.8
        ? AppColors.amber600
        : AppColors.emerald600;

    return CardContainer(
      color: AppColors.softBlue,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              const Text(
                "BUDGET",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "${_newBudget.round()} NOK",
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              const Text(
                "SPENT",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "${spending.round()} NOK",
                style: TextStyle(
                  color: spendingColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
      footer: Column(
        spacing: 8,
        children: [
          BudgetBar(value: usageRatio.clamp(0.0, 1.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(usageRatio * 100).toStringAsFixed(0)}% USED",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              BudgetTracking(value: usageRatio),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    final int selectedCount = _newCategoryFilter.length;
    final int totalCount = TransactionCategory.expenseCategories.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubTitle("TRACK CATEGORIES"),
                Text(
                  "$selectedCount / $totalCount",
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const Text(
              "Choose which categories count toward your budget",
              style: TextStyle(color: AppColors.navy, fontSize: 12),
            ),
            const SizedBox(height: 4),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.2,
              children: TransactionCategory.expenseCategories.map((cat) {
                final bool selected = _newCategoryFilter.contains(cat);
                return Material(
                  color: selected ? cat.color.withAlpha(30) : AppColors.gray100,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _toggleCategory(cat),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: selected
                                  ? cat.color.withAlpha(50)
                                  : AppColors.gray200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              cat.icon,
                              size: 14,
                              color: selected ? cat.color : AppColors.gray400,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected ? cat.color : AppColors.gray500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, size: 14, color: cat.color)
                          else
                            const Icon(
                              Icons.circle_outlined,
                              size: 14,
                              color: AppColors.gray300,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubTitle("SET BUDGET AMOUNT"),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: "Enter amount",
            suffixIcon: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Text(
                    "NOK",
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.navy),
            ),
          ),
          onChanged: (val) {
            final double? parsed = double.tryParse(val);
            _setBudgetFromInput(parsed ?? 0);
          },
        ),
      ],
    );
  }

  Widget _buildSubTitle(String subTitle) {
    return Text(
      subTitle,
      style: const TextStyle(
        color: AppColors.gray500,
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _buildSubTitle("OR USE SLIDER"),
        Slider(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          value: _newBudget.clamp(1000.0, 50000.0),
          label: _newBudget.toStringAsFixed(0),
          min: 1000,
          max: 50000,
          divisions: 98,
          onChanged: _setBudgetFromUI,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["1K", "25K", "50K"].map((label) {
              return Text(
                label,
                style: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _buildSubTitle("QUICK SELECT"),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3,
          children: [5000, 7500, 10000, 15000, 20000, 30000].map((val) {
            final bool selected = _newBudget == val.toDouble();
            return Material(
              color: selected ? AppColors.navy : AppColors.gray200,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _setBudgetFromUI(val.toDouble()),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${val ~/ 1000}K",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.surface : AppColors.gray700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
