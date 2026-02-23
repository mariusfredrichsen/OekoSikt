import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/utils/format_date.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final bool isExpanded;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amountIn != null && transaction.amountIn! > 0;
    final amount = transaction.amountIn ?? transaction.amountOut ?? 0.0;

    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isIncome
                            ? Color.lerp(AppColors.income, Colors.white, 0.75)
                            : AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 0.25,
                            offset: Offset(0.25, 1.25),
                            spreadRadius: 0.15,
                          ),
                        ],
                      ),
                      child: RotatedBox(
                        quarterTurns: isIncome ? 2 : 0,
                        child: Icon(
                          Icons.arrow_outward,
                          color: isIncome ? AppColors.income : AppColors.navy,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      transaction.cleanTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    subtitle: Row(
                      children: [
                        Icon(transaction.category.icon, size: 14),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatDate(transaction.executionDate),
                            maxLines: 1,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isIncome ? '+' : '-'}${amount.abs().toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isIncome ? AppColors.income : AppColors.expense,
                      ),
                    ),
                    Text(
                      transaction.currency,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  ),
                ),
              ],
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildExpandedDetails(),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the expanded details section
  Widget _buildExpandedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _buildDetailRow('Status', transaction.status),
        _buildDetailRow('Type', transaction.type),
        if (transaction.recipientName.isNotEmpty)
          _buildDetailRow('Recipient', transaction.recipientName),
        if (transaction.fromAccount.isNotEmpty)
          _buildDetailRow('From Account', transaction.fromAccount),
        if (transaction.message != null)
          _buildDetailRow('Message', transaction.message!),
        if (transaction.kid != null) _buildDetailRow('KID', transaction.kid!),
      ],
    );
  }

  /// Helper to build a detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
