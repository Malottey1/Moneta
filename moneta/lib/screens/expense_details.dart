import 'package:flutter/material.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final String category;
  final String description;
  final String amount;
  final String date;

  ExpenseDetailsScreen({
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

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
          'Expense Details',
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
            Text(
              'Category',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              category,
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
              description,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Amount',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              amount,
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
              date,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16.0),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}