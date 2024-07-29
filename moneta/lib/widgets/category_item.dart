import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String category;
  final String amount;
  final String total;

  CategoryItem({required this.category, required this.amount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
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
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            total,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}