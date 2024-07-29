import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';

class SignUpPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> fields;
  final String buttonText;
  final RegisterController controller;

  SignUpPage({
    required this.title,
    this.subtitle,
    required this.fields,
    required this.buttonText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Image.asset(
                'assets/images/moneta-logo-2.png',
                width: 50, // Adjust the width as needed
                height: 50, // Adjust the height as needed
              ),
            ],
          ),
          SizedBox(height: 50),
          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceGrotesk',
              color: Colors.black,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                subtitle!,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.grey,
                ),
              ),
            ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields.map((field) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  onChanged: (value) {
                    if (field == 'First Name') {
                      controller.firstName = value;
                    }
                  },
                  decoration: InputDecoration(
                    hintText: field,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                controller.nextPage();
              },
              child: Text(
                buttonText,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}