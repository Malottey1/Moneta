import 'package:flutter/material.dart';
import '../models/onboard_page_model.dart';

class OnboardingController {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<OnboardPageModel> pages = [
    OnboardPageModel(
      image: 'assets/images/on-boarding-screen-first.png',
      title: 'Welcome to MONETA',
      description: 'Manage your finances effortlessly with Moneta. Let’s begin your journey to smarter spending and saving!',
    ),
    OnboardPageModel(
      image: 'assets/images/on-boarding-screen-second.png',
      title: 'Simplified Expense Logging',
      description: 'Easily log your expenses with categories, amounts, and receipt photos. Stay on top of your spending with just a few taps.',
    ),
    OnboardPageModel(
      image: 'assets/images/on-boarding-screen-third.png',
      title: 'Insights and Reports',
      description: 'Visualize your spending habits with detailed reports and charts. Understand where your money goes and make informed financial decisions.',
    ),
    OnboardPageModel(
      image: 'assets/images/on-boarding-screen-fourth.png',
      title: 'Budgeting Made Easy',
      description: 'Set and monitor budgets for various categories. Keep your spending in check and achieve your financial goals with ease.',
    ),
  ];

  void onPageChanged(int index) {
    currentPage = index;
  }
}