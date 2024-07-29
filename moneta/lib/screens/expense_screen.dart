import 'package:flutter/material.dart';
import 'package:moneta/screens/expense_logging_screen.dart';
import '../widgets/expense.dart';

class ExpenseScreen extends StatelessWidget {
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
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterChip(
                  label: Text('Newest'),
                  onSelected: (selected) {
                    // Implement filter logic
                  },
                ),
                FilterChip(
                  label: Text('Oldest'),
                  onSelected: (selected) {
                    // Implement filter logic
                  },
                ),
                FilterChip(
                  label: Text('Highest'),
                  onSelected: (selected) {
                    // Implement filter logic
                  },
                ),
                FilterChip(
                  label: Text('Lowest'),
                  onSelected: (selected) {
                    // Implement filter logic
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  ExpenseItem(
                    category: 'Food',
                    description: 'Lunch at cafe',
                    amount: 'GHS 17.90',
                    date: '22-07-2024',
                  ),
                  ExpenseItem(
                    category: 'Travel',
                    description: 'Taxi fare',
                    amount: 'GHS 17.90',
                    date: '22-07-2024',
                  ),
                ],
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
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}