import 'package:frontend/core/models/transaction_categories.dart';

class Transaction {
  final DateTime executionDate;
  final DateTime postedDate;
  final DateTime valueDate;
  final String description;
  final String type;
  final String subType;

  final String fromAccount;
  final String sender;
  final String toAccount;
  final String recipientName;

  final double? amountIn;
  final double? amountOut;
  final String currency;
  final String status;

  final String? customerReferenceNumber;
  final bool isEInvoice;
  final String? eInvoiceOwner;
  final String? eInvoiceType;
  final String? message;
  final String? kid;
  final String? invoiceNumber;

  final TransactionCategory category;

  Transaction({
    required this.executionDate,
    required this.postedDate,
    required this.valueDate,
    required this.description,
    required this.type,
    required this.subType,
    required this.fromAccount,
    required this.sender,
    required this.toAccount,
    required this.recipientName,
    this.amountIn,
    this.amountOut,
    required this.currency,
    required this.status,
    this.customerReferenceNumber,
    this.isEInvoice = false,
    this.eInvoiceOwner,
    this.eInvoiceType,
    this.message,
    this.kid,
    this.invoiceNumber,
    required this.category,
  });

  factory Transaction.fromCsv(List<dynamic> row) {
    // Helper to safely convert any value to String
    String asString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    // Helper function to parse Norwegian date format (dd.MM.yyyy)
    DateTime parseDate(String dateStr) {
      if (dateStr.isEmpty) return DateTime.now();
      final parts = dateStr.split('.');
      return DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );
    }

    // Helper function to parse amount (handles comma as decimal separator)
    double? parseAmount(String amountStr) {
      if (amountStr.isEmpty) return null;
      return double.tryParse(amountStr.replaceAll(',', '.'));
    }

    final categoryRaw = row.length > 21 ? asString(row[21]) : '';

    return Transaction(
      executionDate: parseDate(asString(row[0])),
      postedDate: parseDate(asString(row[1])),
      valueDate: parseDate(asString(row[2])),
      description: asString(row[3]),
      type: asString(row[4]),
      subType: asString(row[5]),
      fromAccount: asString(row[6]),
      sender: asString(row[7]),
      toAccount: asString(row[8]),
      recipientName: asString(row[9]),
      amountIn: parseAmount(asString(row[10])),
      amountOut: parseAmount(asString(row[11])),
      currency: asString(row[12]),
      status: asString(row[13]),
      customerReferenceNumber: asString(row[14]).isEmpty
          ? null
          : asString(row[14]),
      isEInvoice: asString(row[15]).isNotEmpty,
      eInvoiceOwner: asString(row[16]).isEmpty ? null : asString(row[16]),
      eInvoiceType: asString(row[17]).isEmpty ? null : asString(row[17]),
      message: asString(row[18]).isEmpty ? null : asString(row[18]),
      kid: asString(row[19]).isEmpty ? null : asString(row[19]),
      invoiceNumber: asString(row[20]).isEmpty ? null : asString(row[20]),
      category: TransactionCategory.fromString(categoryRaw),
    );
  }

  String get cleanTitle {
    // 1. Get the raw description (assuming your model has a 'description' field)
    String rawName = description;

    // 2. Remove leading dates like "05.02 " or "31.12 "
    // \d{2}\.\d{2}\s+ looks for two digits, a dot, two digits, and a space at the start
    rawName = rawName.replaceAll(RegExp(r'^\d{2}\.\d{2}\s+'), '');

    // 3. Remove parentheses with numbers inside like " (12242602267)"
    // \s*\(\d+\) looks for optional spaces followed by numbers in parentheses
    rawName = rawName.replaceAll(RegExp(r'\s*\(\d+\)'), '');

    // 4. Remove common prefixes like "Vipps*" or "ZETTLE_*"
    rawName = rawName.replaceAll(RegExp(r'^(Vipps\*|ZETTLE_\*|DNH\*)'), '');

    // 5. Trim any leftover white spaces from the beginning or end
    return rawName.trim();
  }
}
