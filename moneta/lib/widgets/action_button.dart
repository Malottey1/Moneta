import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  ActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, shape: CircleBorder(), backgroundColor: Colors.teal,
            padding: EdgeInsets.all(20), // Icon color
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 30),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}