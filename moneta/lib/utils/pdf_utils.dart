import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:moneta/models/expense.dart';

Future<File> generatePDF(List<Expense> expenses, File file) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Table.fromTextArray(
        data: <List<String>>[
          <String>['Date', 'Description', 'Amount'],
          ...expenses.map((expense) => [
                expense.date.toString(),
                expense.description,
                expense.amount.toString(),
              ])
        ],
      ),
    ),
  );

  final output = await file.writeAsBytes(await pdf.save());
  return output;
}