import 'package:flutter/material.dart';
import 'expense_edit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpenseDetailsScreen extends StatefulWidget {
  final String id;
  final String category;
  final String description;
  final String amount;
  final String date;
  final String receiptImageUrl;

  ExpenseDetailsScreen({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.receiptImageUrl,
  });

  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  late Future<void> _expenseDetailsFuture;

  @override
  void initState() {
    super.initState();
    _expenseDetailsFuture = _fetchExpenseDetails();
  }

  Future<void> _fetchExpenseDetails() async {
    // Fetch the expense details from your API or database
  }

  Future<void> deleteExpense(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.102.97/api/moneta/delete_expense.php'),
      body: {
        'expense_id': widget.id,
      },
    );

    final responseData = json.decode(response.body);
    if (responseData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense deleted successfully.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense.')),
      );
    }
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
          'Expense',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchExpenseDetails,
        child: FutureBuilder<void>(
          future: _expenseDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.amount,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.date,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  if (widget.receiptImageUrl.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receipt',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              widget.receiptImageUrl,
                              height: 300, // Made the receipt image bigger
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8.0), // Made the space between the receipt and the edit button smaller
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditExpenseScreen(
                              id: widget.id,
                              category: widget.category,
                              description: widget.description,
                              amount: widget.amount,
                              date: widget.date,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _expenseDetailsFuture = _fetchExpenseDetails();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10), // Made the button width longer and height smaller
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Edit expense',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Made the text color white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        deleteExpense(context);
                      },
                      child: Text(
                        'Delete expense',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Made the text color black
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}