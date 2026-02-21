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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      formatDate(transaction.executionDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          transaction.category.icon,
                          size: 16,
                          color: AppColors.navy,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Text(
                  "${isIncome ? '+' : '-'}${amount.abs().toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
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
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
