import 'package:flutter/material.dart';
import '../controllers/onboarding_controller.dart';
import 'register_screen.dart'; // Replace with your actual next screen

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingController _controller = OnboardingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _controller.pageController,
              onPageChanged: (int page) {
                setState(() {
                  _controller.onPageChanged(page);
                });
              },
              itemCount: _controller.pages.length,
              itemBuilder: (context, index) {
                final page = _controller.pages[index];
                return OnboardPage(
                  image: page.image,
                  title: page.title,
                  description: page.description,
                  currentPage: _controller.currentPage,
                  pageController: _controller.pageController,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_controller.pages.length, (index) => buildRectangleIndicator(index)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildRectangleIndicator(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 4,
      width: _controller.currentPage == index ? 40 : 20,
      decoration: BoxDecoration(
        color: _controller.currentPage == index ? Colors.teal : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final int currentPage;
  final PageController pageController;

  OnboardPage({
    required this.image,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceGrotesk',
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceGrotesk',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Image.asset(image, height: 350, fit: BoxFit.cover),
          SizedBox(height: 30),
          currentPage < 3
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()), // Replace with your actual next screen
                    );
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}