import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  final String date;
  final String category;
  final String amount;

  ExpenseItem({required this.date, required this.category, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          category,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Text(
          amount,
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