import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  final String date;
  final String category;
  final String amount;

  ExpenseItem({
    required this.date,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              date,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}