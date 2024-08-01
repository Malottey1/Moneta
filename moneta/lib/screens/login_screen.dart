import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneta/services/api_service.dart';
import 'package:moneta/providers/user_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      return false;
    }
    String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(email)) {
      setState(() {
        _emailError = 'Enter a valid email';
      });
      return false;
    }
    if (email.length < 5 || email.length > 255) {
      setState(() {
        _emailError = 'Email length should be between 5 and 255 characters';
      });
      return false;
    }
    setState(() {
      _emailError = null;
    });
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return false;
    }
    setState(() {
      _passwordError = null;
    });
    return true;
  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (!_validateEmail(email) || !_validatePassword(password)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('Attempting to login with email: $email and password: $password');

    try {
      final response = await ApiService().loginUser(
        email,
        password,
      );

      print('Login response: $response');

      if (response['status'] == 'success') {
        // Check if the necessary fields are present
        if (response.containsKey('user_id') &&
            response.containsKey('first_name') &&
            response.containsKey('last_name') &&
            response.containsKey('email') &&
            response.containsKey('profile_picture') &&
            response['user_id'] != null &&
            response['first_name'] != null &&
            response['last_name'] != null &&
            response['email'] != null) {

          Provider.of<UserProvider>(context, listen: false).updateUser(
            response['user_id'],
            response['first_name'],
            response['last_name'],
            response['email'],
            'https://moneta.icu/api/profile-photos/${response['profile_picture']}'
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('Missing fields in response: $response');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid response from server. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login. Please try again.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

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
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email Address',
                errorText: _emailError,
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
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                errorText: _passwordError,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30.0),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _login,
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