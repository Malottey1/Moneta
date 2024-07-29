import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';

class ProfilePicturePage extends StatelessWidget {
  final String title;
  final String firstName;
  final RegisterController controller;

  ProfilePicturePage({
    required this.title,
    required this.firstName,
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
          SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 130,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.teal),
                    onPressed: () {
                      // Implement your logic to upload or take a picture
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              firstName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceGrotesk',
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    controller.goToHomeScreen(context);
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.teal),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    controller.skipPage();
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}