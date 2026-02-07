import 'package:flutter/material.dart';
import 'package:frontend/core/models/transaction_model.dart';
import 'package:intl/intl.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  List<Transaction> transactions = [
    Transaction(
      executionDate: DateTime(2026, 2, 5),
      postedDate: DateTime(
        2026,
        2,
        5,
      ), // Antatt samme som execution der det er tomt
      valueDate: DateTime(2026, 2, 5),
      description: 'INFORMATIKKKAFE',
      type: 'Varekjøp',
      subType: '',
      fromAccount: '2220 32 43751',
      sender: 'Velvet',
      toAccount: '',
      recipientName: '',
      amountIn: null,
      amountOut: -71.51,
      currency: 'NOK',
      status: 'Reservert',
      customerReferenceNumber: 'INFORMATIKKKAFE',
    ),
    Transaction(
      executionDate: DateTime(2026, 2, 5),
      postedDate: DateTime(2026, 2, 5),
      valueDate: DateTime(2026, 2, 5),
      description: 'Betaling',
      type: 'Betaling innland',
      subType: '',
      fromAccount: '2220 32 43751',
      sender: '',
      toAccount: '',
      recipientName: '',
      amountIn: null,
      amountOut: -185.0,
      currency: 'NOK',
      status: 'Bekreftet',
      customerReferenceNumber: '',
    ),
    Transaction(
      executionDate: DateTime(2026, 2, 5),
      postedDate: DateTime(2026, 2, 5),
      valueDate: DateTime(2026, 2, 5),
      description: '04.02 KIWI 274 HASLEV HASLEVEIEN 1 OSLO',
      type: 'Varekjøp',
      subType: '',
      fromAccount: '2220 32 43751',
      sender: 'Velvet',
      toAccount: '',
      recipientName: '',
      amountIn: null,
      amountOut: -131.6,
      currency: 'NOK',
      status: 'Bekreftet',
      customerReferenceNumber: '04.02 KIWI 274 HASLEV HASLEVEIEN 1 OSLO',
    ),
    Transaction(
      executionDate: DateTime(2026, 2, 5),
      postedDate: DateTime(2026, 2, 5),
      valueDate: DateTime(2026, 2, 5),
      description: '04.02 KIWI 307 KRINGS OLAV M. TROV OSLO',
      type: 'Varekjøp',
      subType: '',
      fromAccount: '2220 32 43751',
      sender: 'Velvet',
      toAccount: '',
      recipientName: '',
      amountIn: null,
      amountOut: -252.4,
      currency: 'NOK',
      status: 'Bekreftet',
      customerReferenceNumber: '04.02 KIWI 307 KRINGS OLAV M. TROV OSLO',
    ),
  ];

  final DateFormat formattedDate = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('Here is a overview of all your transactions:'),
            ...transactions.map(
              (t) => ListTile(
                title: Text(t.description),
                subtitle: Text(formattedDate.format(t.executionDate)),
                trailing: Text('${t.amountOut ?? t.amountIn} ${t.currency}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
