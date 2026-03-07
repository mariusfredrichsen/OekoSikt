import 'package:frontend/core/models/transaction_categories.dart';
import 'package:frontend/utils/transaction_categorizer.dart';

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

  /// CSV columns (0-indexed, no category column):
  ///  0  Utført dato        → executionDate
  ///  1  Bokført dato       → postedDate
  ///  2  Rentedato          → valueDate
  ///  3  Beskrivelse        → description
  ///  4  Type               → type
  ///  5  Undertype          → subType
  ///  6  Fra konto          → fromAccount
  ///  7  Avsender           → sender
  ///  8  Til konto          → toAccount
  ///  9  Mottakernavn       → recipientName
  /// 10  Beløp inn          → amountIn
  /// 11  Beløp ut           → amountOut
  /// 12  Valuta             → currency
  /// 13  Status             → status
  /// 14  Melding/KID/Fakt.  → customerReferenceNumber
  /// 15  eFaktura           → isEInvoice
  /// 16  eFaktura eier      → eInvoiceOwner
  /// 17  eFaktura type      → eInvoiceType
  /// 18  Melding            → message
  /// 19  KID                → kid
  /// 20  Faktura nr.        → invoiceNumber
  factory Transaction.fromCsv(List<dynamic> row) {
    String asString(dynamic value) => value?.toString() ?? '';

    DateTime parseDate(String s) {
      if (s.isEmpty) return DateTime.now();
      final p = s.split('.');
      if (p.length < 3) return DateTime.now();
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }

    double? parseAmount(String s) {
      if (s.isEmpty) return null;
      return double.tryParse(s.replaceAll(',', '.'));
    }

    final description = asString(row[3]);
    final type = asString(row[4]);
    final subType = asString(row[5]);
    final recipientName = asString(row[9]);
    final amountIn = parseAmount(asString(row[10]));
    final amountOut = parseAmount(asString(row[11]));
    // row[14] is Melding/KID/Fakt.nr — used as the rich message field for categorisation
    final message = asString(row[14]);

    return Transaction(
      executionDate: parseDate(asString(row[0])),
      postedDate: parseDate(asString(row[1])),
      valueDate: parseDate(asString(row[2])),
      description: description,
      type: type,
      subType: subType,
      fromAccount: asString(row[6]),
      sender: asString(row[7]),
      toAccount: asString(row[8]),
      recipientName: recipientName,
      amountIn: amountIn,
      amountOut: amountOut,
      currency: asString(row[12]),
      status: asString(row[13]),
      customerReferenceNumber: message.isEmpty ? null : message,
      isEInvoice: asString(row[15]).isNotEmpty,
      eInvoiceOwner: asString(row[16]).isEmpty ? null : asString(row[16]),
      eInvoiceType: asString(row[17]).isEmpty ? null : asString(row[17]),
      message: asString(row[18]).isEmpty ? null : asString(row[18]),
      kid: asString(row[19]).isEmpty ? null : asString(row[19]),
      invoiceNumber: asString(row[20]).isEmpty ? null : asString(row[20]),
      // Auto-classify — no category column in CSV anymore
      category: TransactionCategorizer.categorize(
        description: description,
        type: type,
        subType: subType,
        recipientName: recipientName,
        message: message,
        amountIn: amountIn,
        amountOut: amountOut,
      ),
    );
  }

  String get cleanTitle {
    String raw = description;
    raw = raw.replaceAll(
      RegExp(r'^\d{2}\.\d{2}\s+'),
      '',
    ); // leading date "05.02 "
    raw = raw.replaceAll(RegExp(r'\s*\(\d+\)'), ''); // "(12242602267)"
    raw = raw.replaceAll(
      RegExp(r'^(Vipps\*|ZETTLE_\*|DNH\*)'),
      '',
    ); // payment prefixes
    return raw.trim();
  }
}
