import 'package:flutter/material.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String category;
  final String budget;
  final String spent;
  final double spentPercentage;
  final List<TransactionItem> transactions;

  CategoryDetailsScreen({
    required this.category,
    required this.budget,
    required this.spent,
    required this.spentPercentage,
    required this.transactions,
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
          category,
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
            _buildSpentBar(),
            SizedBox(height: 16.0),
            Text(
              'Budget: $budget',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionItem(transactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // Implement add transaction logic
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSpentBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              '${spentPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        LinearProgressIndicator(
          value: spentPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionItem transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.date,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transaction.description,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            transaction.amount,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem {
  final String date;
  final String description;
  final String amount;

  TransactionItem({
    required this.date,
    required this.description,
    required this.amount,
  });
}