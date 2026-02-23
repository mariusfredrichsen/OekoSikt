import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/models/transaction_direction.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HistoryFilterBar extends StatefulWidget {
  final TransactionDirection selectedDirection;
  final TransactionCategory selectedCategory;
  final String searchQuery;
  final ValueChanged<TransactionDirection> onDirectionChanged;
  final ValueChanged<TransactionCategory> onCategoryChanged;
  final ValueChanged<String> onSearchQueryChanged;

  const HistoryFilterBar({
    super.key,
    required this.selectedDirection,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onDirectionChanged,
    required this.onCategoryChanged,
    required this.onSearchQueryChanged,
  });

  @override
  State<HistoryFilterBar> createState() => _HistoryFilterBarState();
}

class _HistoryFilterBarState extends State<HistoryFilterBar> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchQueryChanged(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 8),
          _buildDirectionSegmentedControl(),
          const SizedBox(height: 8),
          _buildCategoryChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: _searchFocusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.navy.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        cursorColor: AppColors.navy,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: "Search transactions...",
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _debounce?.cancel();
                    _searchController.clear();
                    _searchFocusNode.requestFocus();
                    widget.onSearchQueryChanged('');
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.cancel,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 32,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 32,
          ),
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.divider),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildDirectionSegmentedControl() {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<TransactionDirection>(
        groupValue: widget.selectedDirection,
        backgroundColor: AppColors.divider,
        thumbColor: AppColors.navy,
        onValueChanged: (value) =>
            value != null ? widget.onDirectionChanged(value) : null,
        children: {
          TransactionDirection.all: _buildSegmentText(
            "All",
            TransactionDirection.all,
          ),
          TransactionDirection.outcome: _buildSegmentText(
            "Outcome",
            TransactionDirection.outcome,
          ),
          TransactionDirection.income: _buildSegmentText(
            "Income",
            TransactionDirection.income,
          ),
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TransactionCategory.values.map((cat) {
            final isSelected = cat == widget.selectedCategory;

            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ChoiceChip(
                showCheckmark: false,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 14,
                      color: isSelected ? AppColors.background : AppColors.navy,
                    ),
                    const SizedBox(width: 4),
                    Text(cat.label),
                  ],
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                selected: isSelected,
                onSelected: (_) => widget.onCategoryChanged(cat),

                backgroundColor: AppColors.surface,
                selectedColor: AppColors.navy,
                disabledColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.navy : AppColors.divider,
                ),
                surfaceTintColor: Colors.transparent,

                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSegmentText(String text, TransactionDirection direction) {
    final isSelected = widget.selectedDirection == direction;
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
