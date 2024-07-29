import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(flex: 2),  // Add space at the top
            Row(
              children: [
                Image.asset(
                  'assets/images/moneta-logo-2.png',
                  width: 50, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                ),
              ],
            ),
            SizedBox(height: 30.0),
            Text(
              'Hey,\nLogin Now.',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnboardingScreen(),
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: 'If you’re new, ',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Create An Account',
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email Address',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 30.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  // Add your login logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Spacer(flex: 3),  // Add space at the bottom
          ],
        ),
      ),
    );
  }
}