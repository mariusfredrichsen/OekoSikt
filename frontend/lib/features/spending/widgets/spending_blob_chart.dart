import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:bubble_chart/bubble_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/utils/transaction_list_extention.dart';

class SpendingBlobs extends StatefulWidget {
  final List<Transaction> allTransactions;

  const SpendingBlobs({super.key, required this.allTransactions});

  @override
  State<SpendingBlobs> createState() => _SpendingBlobsState();
}

class _SpendingBlobsState extends State<SpendingBlobs> {
  int _hoveredIndex = -1;
  int _selectedIndex = -1;
  int _pressedIndex = -1;

  bool _isLongPress = false;
  Timer? _longPressTimer;

  static const _longPressThreshold = Duration(milliseconds: 300);

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _onTapDown(int index) {
    _longPressTimer?.cancel();
    _isLongPress = false;

    setState(() {
      _pressedIndex = index;
      if (_selectedIndex != index) _selectedIndex = -1;
    });

    _longPressTimer = Timer(_longPressThreshold, () {
      if (mounted) setState(() => _isLongPress = true);
    });
  }

  void _onTapUp(int index) {
    _longPressTimer?.cancel();

    setState(() {
      _pressedIndex = -1;
      if (!_isLongPress) {
        _selectedIndex = _selectedIndex == index ? -1 : index;
      }
      _isLongPress = false;
    });
  }

  void _onTapCancel() {
    _longPressTimer?.cancel();
    setState(() {
      _pressedIndex = -1;
      _isLongPress = false;
    });
  }

  double _compress(double value) =>
      math.pow(value.clamp(0, double.infinity), 0.4).toDouble();

  Map<TransactionCategory, List<Transaction>> _groupTransactions(
    List<Transaction> transactions,
  ) {
    final grouped = <TransactionCategory, List<Transaction>>{};
    for (final t in transactions) {
      (grouped[t.category] ??= []).add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupTransactions(widget.allTransactions);

    final sortedEntries = groupedData.entries.toList()
      ..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));

    if (sortedEntries.isEmpty) return const Center(child: Text("No data"));

    final double grandTotal = sortedEntries.fold(
      0.0,
      (sum, e) => sum + e.value.totalSpent,
    );

    final int activeIndex = _pressedIndex != -1
        ? _pressedIndex
        : _selectedIndex;

    final double displayedAmount = activeIndex == -1
        ? grandTotal
        : sortedEntries[activeIndex].value.totalSpent;

    final String displayedLabel = activeIndex == -1
        ? 'TOTAL SPENDING'
        : '${sortedEntries[activeIndex].key.label.toUpperCase()} SPENDING';

    final compressedValues = sortedEntries
        .map((e) => _compress(e.value.totalSpent))
        .toList();

    final minC = compressedValues.reduce(math.min);
    final maxC = compressedValues.reduce(math.max);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(displayedLabel, displayedAmount, AppColors.navy),
        AspectRatio(
          aspectRatio: 1.2,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BubbleChartLayout(
              children: List.generate(sortedEntries.length, (index) {
                final cat = sortedEntries[index].key;
                final total = sortedEntries[index].value.totalSpent;
                final compressed = compressedValues[index];
                final isHovered = _hoveredIndex == index;
                final isSelected = _selectedIndex == index;

                final double t = maxC > minC
                    ? (compressed - minC) / (maxC - minC)
                    : 0.5;

                final double percentage = grandTotal > 0
                    ? (total / grandTotal) * 100
                    : 0;

                return BubbleNode.leaf(
                  value: compressed,
                  options: BubbleOptions(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.transparent, width: 0),
                    child: _BubbleContent(
                      cat: cat,
                      percentage: percentage,
                      isHovered: isHovered,
                      isSelected: isSelected,
                      isPressed: _pressedIndex == index,
                      sizeFraction: t,
                      onHoverChanged: (hovering) =>
                          setState(() => _hoveredIndex = hovering ? index : -1),
                      onTapDown: () => _onTapDown(index),
                      onTapUp: () => _onTapUp(index),
                      onTapCancel: _onTapCancel,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String label, double amount, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 1.2,
          ),
          child: Text(label),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: amount),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutExpo,
          builder: (context, value, _) {
            return Text(
              '${value.toStringAsFixed(0)} kr',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final TransactionCategory cat;
  final double percentage;
  final bool isHovered;
  final bool isSelected;
  final bool isPressed;
  final double sizeFraction;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  const _BubbleContent({
    required this.cat,
    required this.percentage,
    required this.isHovered,
    required this.isSelected,
    required this.isPressed,
    required this.sizeFraction,
    required this.onHoverChanged,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool highlighted = isHovered || isSelected || isPressed;

    final double iconSize = lerpDouble(20, 40, sizeFraction)!;
    final double labelSize = lerpDouble(9, 14, sizeFraction)!;
    final double amountSize = lerpDouble(10, 16, sizeFraction)!;

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        onTapDown: (_) => onTapDown(),
        onTapUp: (_) => onTapUp(),
        onTapCancel: onTapCancel,
        child: AnimatedScale(
          scale: highlighted ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: SizedBox.expand(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: highlighted
                      ? Color.lerp(cat.color, Colors.black, 0.12)
                      : cat.color,
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withAlpha(180),
                          width: 2.5,
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, color: Colors.white, size: iconSize),
                        SizedBox(height: iconSize * 0.1),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(220),
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: iconSize * 0.05),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: amountSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
