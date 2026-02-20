import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:frontend/core/models/transaction_model.dart';

class TransactionService {
  /// Loads transactions from the CSV file in assets
  static Future<List<Transaction>> loadTransactions() async {
    try {
      // Load the CSV file as a string
      final rawData = await rootBundle.loadString(
        'assets/Transaksjoner_2026-02-07.csv',
      );

      // Parse the CSV string into a list of lists
      // fieldDelimiter: ',' specifies comma-separated values
      // eol: '\n' specifies line breaks
      List<List<dynamic>> csvTable = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
      ).convert(rawData);

      // Remove the header row (first row)
      csvTable.removeAt(0);

      // Convert each CSV row into a Transaction object
      return csvTable.map((row) => Transaction.fromCsv(row)).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }
}
