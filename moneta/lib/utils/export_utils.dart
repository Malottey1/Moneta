import 'dart:io';
import 'package:moneta/models/expense.dart';
import 'package:moneta/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moneta/utils/pdf_utils.dart';

Future<void> exportToPDF(List<Expense> expenses) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/expenses.pdf');

  await generatePDF(expenses, file);
}