import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class RegisterController {
  final PageController pageController = PageController();
  int currentPage = 0;
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String gender = 'Male';
  String dateOfBirth = '';
  File? profilePicture;

  void onPageChanged(int index) {
    currentPage = index;
  }

  void nextPage() {
    if (currentPage < 3) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void skipPage() {
    pageController.jumpToPage(3);
  }

  void goToHomeScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    if (password != confirmPassword) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      pageController.jumpToPage(1);
      return;
    }

    final Uri registerUrl = Uri.parse('http://192.168.102.97/api/moneta/register.php');
    final request = http.MultipartRequest('POST', registerUrl);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['gender'] = gender;
    request.fields['date_of_birth'] = dateOfBirth;

    if (profilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        profilePicture!.path,
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // Log the response body
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      final responseData = json.decode(responseBody);

      if (responseData['status'] == 'success') {
        // Navigate to login screen after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register. Please try again.')),
      );
    }
  }
}