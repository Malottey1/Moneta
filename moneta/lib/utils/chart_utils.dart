import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:moneta/models/expense.dart';
import 'package:moneta/models/user.dart';

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  ExpenseChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Expense, String>> series = [
      charts.Series(
        id: 'Expenses',
        data: expenses,
        domainFn: (Expense expense, _) => expense.date.toString(),
        measureFn: (Expense expense, _) => expense.amount,
      ),
    ];

    return charts.BarChart(
      series,
      animate: true,
    );
  }
}