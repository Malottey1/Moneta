import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; // Import the HomeScreen

class RegisterController {
  final PageController pageController = PageController();
  int currentPage = 0;
  String firstName = '';

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
}