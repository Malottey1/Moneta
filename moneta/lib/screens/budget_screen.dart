import 'package:flutter/material.dart';
import 'package:moneta/widgets/budget_item.dart';


class BudgetsScreen extends StatelessWidget {
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
          'Budgets',
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
              'Your budgets',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            BudgetItem(
              category: 'Groceries',
              allocated: 'GHS 200.00',
              spent: 'GHS 150.00',
              progress: 75,
            ),
            BudgetItem(
              category: 'Restaurants',
              allocated: 'GHS 100.00',
              spent: 'GHS 80.00',
              progress: 80,
            ),
            BudgetItem(
              category: 'Utilities',
              allocated: 'GHS 50.00',
              spent: 'GHS 30.00',
              progress: 60,
            ),
            BudgetItem(
              category: 'Entertainment',
              allocated: 'GHS 150.00',
              spent: 'GHS 100.00',
              progress: 70,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () {
          // Implement add budget logic
        },
        icon: Icon(Icons.add),
        label: Text('Set New Budget'),
      ),
    );
  }
}