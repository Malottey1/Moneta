import 'package:flutter/material.dart';

class BudgetItem extends StatelessWidget {
  final String category;
  final String allocated;
  final String spent;
  final double progress;

  BudgetItem({
    required this.category,
    required this.allocated,
    required this.spent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Allocated: $allocated, Spent: $spent',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}