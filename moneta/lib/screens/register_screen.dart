import 'package:flutter/material.dart';
import 'package:moneta/widgets/profile_picture_page.dart';
import 'package:moneta/widgets/sign_up_page.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController _controller = RegisterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 150),
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: PageView(
                  controller: _controller.pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _controller.onPageChanged(page);
                    });
                  },
                  children: <Widget>[
                                        SignUpPage(
                      title: 'Welcome, Sign Up Here',
                      subtitle: 'Already Have An Account, Log in',
                      fields: [
                        'First Name',
                        'Last Name',
                        'Email Address',
                      ],
                      buttonText: 'Next',
                      controller: _controller,
                    ),
                    SignUpPage(
                      title: 'Set Up A Password',
                      fields: [
                        'Password',
                        'Confirm Password',
                      ],
                      buttonText: 'Next',
                      controller: _controller,
                    ),
                    SignUpPage(
                      title: 'Additional Information',
                      fields: [
                        'Gender',
                        'Date Of Birth',
                      ],
                      buttonText: 'Next',
                      controller: _controller,
                    ),
                    ProfilePicturePage(
                      title: 'Set Up Your Profile Picture',
                      firstName: _controller.firstName,
                      controller: _controller,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => buildRectangleIndicator(index)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
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