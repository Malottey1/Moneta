import 'package:flutter/material.dart';

class BudgetItem extends StatelessWidget {
  final String category;
  final String allocated;
  final String spent;
  final int progress;

  const BudgetItem({
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
            'Allocated: $allocated, \nSpent: $spent',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                '$progress',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}