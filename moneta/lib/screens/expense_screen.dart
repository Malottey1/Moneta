import 'package:flutter/material.dart';
import 'package:moneta/screens/expense_details.dart';
import 'package:provider/provider.dart';
import 'package:moneta/services/api_service.dart';
import 'package:moneta/providers/user_provider.dart';
import 'package:moneta/screens/expense_logging_screen.dart';
import '../widgets/expense.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<dynamic> expenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    try {
      final fetchedExpenses = await ApiService().getExpenses(userId);
      setState(() {
        expenses = fetchedExpenses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load expenses. Please try again.')),
      );
    }
  }

  void _filterExpenses(String filter) {
    setState(() {
      if (filter == 'Newest') {
        expenses.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      } else if (filter == 'Oldest') {
        expenses.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      } else if (filter == 'Highest') {
        expenses.sort((a, b) => b['amount'].compareTo(a['amount']));
      } else if (filter == 'Lowest') {
        expenses.sort((a, b) => a['amount'].compareTo(b['amount']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Expenses',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Expenses',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                  contentPadding: EdgeInsets.all(16.0),
                ),
                onChanged: (value) {
                  // Implement search logic
                },
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterChip(
                  label: Text('Newest'),
                  onSelected: (selected) {
                    _filterExpenses('Newest');
                  },
                ),
                FilterChip(
                  label: Text('Oldest'),
                  onSelected: (selected) {
                    _filterExpenses('Oldest');
                  },
                ),
                FilterChip(
                  label: Text('Highest'),
                  onSelected: (selected) {
                    _filterExpenses('Highest');
                  },
                ),
                FilterChip(
                  label: Text('Lowest'),
                  onSelected: (selected) {
                    _filterExpenses('Lowest');
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpenseDetailsScreen(
                                  id: expense['expense_id'].toString(),
                                  category: expense['category_name'],
                                  description: expense['description'],
                                  amount: 'GHS ${expense['amount']}',
                                  date: expense['date'],
                                  receiptImageUrl: 'http://192.168.102.97/api/moneta/receipts/${expense['receipt_image']}', // Assuming this is the path structure
                                ),
                              ),
                            );
                          },
                          child: ExpenseItem(
                            category: expense['category_name'],
                            description: expense['description'],
                            amount: 'GHS ${expense['amount']}',
                            date: expense['date'],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseLoggingScreen()),
          ).then((_) {
            fetchExpenses(); // Refresh the list after logging a new expense
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}