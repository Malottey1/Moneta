import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  final String category;
  final String description;
  final String amount;
  final String date;

  ExpenseItem({
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(Icons.category, color: Colors.teal),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}