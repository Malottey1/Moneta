import 'package:flutter/material.dart';

class BudgetSummaryItem extends StatelessWidget {
  final String category;
  final String budget;
  final String spent;

  BudgetSummaryItem({required this.category, required this.budget, required this.spent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          category,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          budget,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          spent,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}