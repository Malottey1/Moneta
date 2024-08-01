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

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? dateOfBirthError;

  void onPageChanged(int index) {
    currentPage = index;
  }

  void nextPage() {
    if (validateCurrentPage()) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  bool validateCurrentPage() {
    switch (currentPage) {
      case 0:
        return validatePersonalInfo();
      case 1:
        return validatePassword();
      case 2:
        return validateAdditionalInfo();
      default:
        return false;
    }
  }

  bool validatePersonalInfo() {
    firstNameError = null;
    lastNameError = null;
    emailError = null;

    if (firstName.isEmpty) {
      firstNameError = 'First name is required';
    } else if (RegExp(r'[0-9]').hasMatch(firstName)) {
      firstNameError = 'First name cannot contain numbers';
    }

    if (lastName.isEmpty) {
      lastNameError = 'Last name is required';
    } else if (RegExp(r'[0-9]').hasMatch(lastName)) {
      lastNameError = 'Last name cannot contain numbers';
    }

    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailError = 'Enter a valid email';
    } else if (email.length < 5 || email.length > 255) {
      emailError = 'Email length should be between 5 and 255 characters';
    }
    // Add unique email check logic here if needed

    return firstNameError == null && lastNameError == null && emailError == null;
  }

  bool validatePassword() {
    passwordError = null;
    confirmPasswordError = null;

    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 8 || password.length > 32) {
      passwordError = 'Password length should be between 8 and 32 characters';
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(password)) {
      passwordError = 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirm password is required';
    } else if (password != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    return passwordError == null && confirmPasswordError == null;
  }

  bool validateAdditionalInfo() {
    dateOfBirthError = null;

    if (dateOfBirth.isEmpty) {
      dateOfBirthError = 'Date of birth is required';
    } else {
      DateTime dob = DateTime.parse(dateOfBirth);
      int age = DateTime.now().year - dob.year;
      if (age < 18) {
        dateOfBirthError = 'You must be at least 18 years old';
      }
    }

    return dateOfBirthError == null;
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

    final Uri registerUrl = Uri.parse('https://moneta.icu/api/register.php');
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