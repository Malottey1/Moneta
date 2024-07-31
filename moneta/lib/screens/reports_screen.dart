import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:moneta/providers/user_provider.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseReportScreen extends StatefulWidget {
  @override
  _ExpenseReportScreenState createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  Map<String, dynamic> _summaryData = {};
  List<dynamic> _categoryWiseSpending = [];
  List<dynamic> _monthlySpendingTrends = [];
  List<dynamic> _detailedExpenses = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReportData();
    });
  }

  Future<void> _fetchReportData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      final summaryResponse = await http.get(Uri.parse('http://192.168.102.97/api/moneta/summary.php?user_id=$userId'));
      final categoryWiseResponse = await http.get(Uri.parse('http://192.168.102.97/api/moneta/category_wise_spending.php?user_id=$userId'));
      final monthlySpendingResponse = await http.get(Uri.parse('http://192.168.102.97/api/moneta/monthly_spending_trends.php?user_id=$userId'));
      final detailedExpensesResponse = await http.get(Uri.parse('http://192.168.102.97/api/moneta/detailed_expenses.php?user_id=$userId'));

      if (summaryResponse.statusCode == 200 &&
          categoryWiseResponse.statusCode == 200 &&
          monthlySpendingResponse.statusCode == 200 &&
          detailedExpensesResponse.statusCode == 200) {
        
        setState(() {
          _summaryData = json.decode(summaryResponse.body);
          _categoryWiseSpending = json.decode(categoryWiseResponse.body) ?? [];
          _monthlySpendingTrends = json.decode(monthlySpendingResponse.body) ?? [];
          _detailedExpenses = json.decode(detailedExpensesResponse.body) ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdfReport() async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized

    final pdf = pw.Document();
    final logo = (await rootBundle.load('assets/images/moneta-logo-2.png')).buffer.asUint8List();

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        children: [
          pw.Image(pw.MemoryImage(logo), height: 100, width: 100),
          pw.Text('Moneta Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
          pw.SizedBox(height: 20),
          pw.Text('Table of Contents', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('1. Summary'),
          pw.Text('2. Category-wise Spending'),
          pw.Text('3. Monthly Spending Trends'),
          pw.Text('4. Detailed Expenses'),
          pw.SizedBox(height: 20),
          pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Total Expenses: \$${_summaryData['total_expenses']}'),
          pw.Text('Categories: ${(_summaryData['categories'] is List) ? _summaryData['categories'].join(', ') : _summaryData['categories']}'),
          pw.SizedBox(height: 20),
          pw.Text('Category-wise Spending', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('Monthly Spending Trends', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('Detailed Expenses', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ));

    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/expense_report.pdf");
      await file.writeAsBytes(await pdf.save());
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'expense_report.pdf');
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Report',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Error loading data.', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 16, color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16.0),
                        children: [
                          Text('Summary', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Total Expenses: \$${_summaryData['total_expenses']}', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                          Text('Categories: ${(_summaryData['categories'] is List) ? _summaryData['categories'].join(', ') : _summaryData['categories']}', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                          SizedBox(height: 20),
                          Text('Category-wise Spending', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_categoryWiseSpending.isNotEmpty) ...[
                            Container(
                              height: 400,
                              child: SfCircularChart(
                                legend: Legend(isVisible: true),
                                series: <CircularSeries>[
                                  PieSeries<dynamic, String>(
                                    dataSource: _categoryWiseSpending,
                                    xValueMapper: (dynamic data, _) => data['category_name'] ?? '',
                                    yValueMapper: (dynamic data, _) => double.parse(data['total_amount'] ?? '0'),
                                    dataLabelMapper: (dynamic data, _) => data['category_name'] ?? '',
                                    dataLabelSettings: DataLabelSettings(isVisible: true),
                                    radius: '80%',
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Center(child: Text('No category-wise spending data available.', style: TextStyle(fontFamily: 'SpaceGrotesk'))),
                          ],
                          SizedBox(height: 20),
                          Text('Monthly Spending Trends', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_monthlySpendingTrends.isNotEmpty) ...[
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Month', textStyle: TextStyle(fontFamily: 'SpaceGrotesk'))),
                              primaryYAxis: NumericAxis(title: AxisTitle(text: 'Amount', textStyle: TextStyle(fontFamily: 'SpaceGrotesk'))),
                              legend: Legend(isVisible: true),
                              series: <ChartSeries>[
                                ColumnSeries<dynamic, String>(
                                  dataSource: _monthlySpendingTrends,
                                  xValueMapper: (dynamic data, _) => data['month'] ?? '',
                                  yValueMapper: (dynamic data, _) => double.parse(data['total_amount'] ?? '0'),
                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                ),
                              ],
                            ),
                          ] else ...[
                            Center(child: Text('No monthly spending trends data available.', style: TextStyle(fontFamily: 'SpaceGrotesk'))),
                          ],
                          SizedBox(height: 20),
                          Text('Detailed Expenses', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_detailedExpenses.isNotEmpty) ...[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _detailedExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = _detailedExpenses[index];
                                return ListTile(
                                                                   title: Text(expense['description'] ?? '', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                                  subtitle: Text('${expense['category_name']} - \$${expense['amount']}', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                                  trailing: Text(expense['date'], style: TextStyle(fontFamily: 'SpaceGrotesk')),
                                );
                              },
                            ),
                          ] else ...[
                            Center(child: Text('No detailed expenses data available.', style: TextStyle(fontFamily: 'SpaceGrotesk'))),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _generatePdfReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Export PDF',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _generatePdfReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Preview PDF',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}