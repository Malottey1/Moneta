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
  List<dynamic> filteredExpenses = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'Newest';

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses({String sort = 'date_desc', String search = ''}) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    try {
      final fetchedExpenses = await ApiService().getExpenses(userId, sort: sort, search: search);
      setState(() {
        expenses = fetchedExpenses;
        filteredExpenses = fetchedExpenses;
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
      selectedFilter = filter;
      switch (filter) {
        case 'Newest':
          fetchExpenses(sort: 'date_desc', search: searchQuery);
          break;
        case 'Oldest':
          fetchExpenses(sort: 'date_asc', search: searchQuery);
          break;
        case 'Highest':
          fetchExpenses(sort: 'amount_desc', search: searchQuery);
          break;
        case 'Lowest':
          fetchExpenses(sort: 'amount_asc', search: searchQuery);
          break;
        default:
          fetchExpenses(sort: 'date_desc', search: searchQuery);
      }
    });
  }

  void _searchExpenses(String query) {
    setState(() {
      searchQuery = query;
      fetchExpenses(sort: selectedFilter.toLowerCase(), search: query);
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
                  hintStyle: TextStyle(fontFamily: 'SpaceGrotesk'),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                  contentPadding: EdgeInsets.all(16.0),
                ),
                style: TextStyle(fontFamily: 'SpaceGrotesk'),
                onChanged: (value) {
                  _searchExpenses(value);
                },
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterChip(
                  label: Text('Newest', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                  selected: selectedFilter == 'Newest',
                  onSelected: (selected) {
                    _filterExpenses('Newest');
                  },
                ),
                FilterChip(
                  label: Text('Oldest', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                  selected: selectedFilter == 'Oldest',
                  onSelected: (selected) {
                    _filterExpenses('Oldest');
                  },
                ),
                FilterChip(
                  label: Text('Highest', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                  selected: selectedFilter == 'Highest',
                  onSelected: (selected) {
                    _filterExpenses('Highest');
                  },
                ),
                FilterChip(
                  label: Text('Lowest', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                  selected: selectedFilter == 'Lowest',
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
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
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
                                  receiptImageUrl: 'https://moneta.icu/api/receipts/${expense['receipt_image']}', // Assuming this is the path structure
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