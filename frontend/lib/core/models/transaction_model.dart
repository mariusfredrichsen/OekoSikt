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
  });
}
