import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widget/bar/budget_bar.dart';
import 'package:frontend/core/widget/cards/card_container.dart';
import 'package:frontend/core/widget/icons/icon_container.dart';
import 'package:frontend/core/widget/labels/budget_tracking.dart';

class BudgetDialog extends StatefulWidget {
  final double currentSpending;
  final double currentBudget;

  const BudgetDialog({
    super.key,
    required this.currentSpending,
    required this.currentBudget,
  });

  @override
  State<StatefulWidget> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  late double _newBudget;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _newBudget = widget.currentBudget;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.all(16),
      title: _buildTitle(),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              _buildBudgetPreview(),
              _buildQuickSelect(),
              _buildSlider(),
              _buildInputField(),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("CANCEL"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_newBudget),
                child: const Text("SAVE"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "OR ENTER EXACT AMOUNT",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
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
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
            fillColor: AppColors.divider.withAlpha(125),
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

  Widget _buildSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ADJUST WITH SLIDER",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
        Slider(
          value: _newBudget.clamp(1000.0, 50000.0),
          min: 1000,
          max: 50000,
          divisions: 98,
          onChanged: _setBudgetFromUI,
        ),
      ],
    );
  }

  Widget _buildQuickSelect() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [5000, 7500, 10000, 15000, 20000, 30000].map((val) {
        bool selected = _newBudget == val.toDouble();
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? AppColors.navy : AppColors.divider,
            foregroundColor: selected ? Colors.white : AppColors.navy,
            elevation: 0,
          ),
          onPressed: () => _setBudgetFromUI(val.toDouble()),
          child: Text(
            "${val ~/ 1000}K",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const IconContainer(
          color: AppColors.softBlue,
          child: Icon(Icons.edit, color: AppColors.navy, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "EDIT BUDGET",
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              "Set your monthly spending limit",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetPreview() {
    final double usageRatio = _newBudget > 0
        ? widget.currentSpending / _newBudget
        : 0.0;
    return CardContainer(
      color: AppColors.softBlue,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "NEW BUDGET",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 9,
            ),
          ),
          Text(
            "SPENDING",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 9,
            ),
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${_newBudget.round()} NOK",
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Text(
            "${widget.currentSpending.round()} NOK",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
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
}
