import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneta/screens/login_screen.dart';
import 'dart:io';
import '../controllers/register_controller.dart';

class ProfilePicturePage extends StatefulWidget {
  final String title;
  final String firstName;
  final RegisterController controller;

  ProfilePicturePage({
    required this.title,
    required this.firstName,
    required this.controller,
  });

  @override
  _ProfilePicturePageState createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        widget.controller.profilePicture = _imageFile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image.asset(
                  'assets/images/moneta-logo-2.png',
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              widget.title,
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
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 30,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 30, color: Colors.teal),
                      onPressed: () {
                        _showPicker(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                widget.firstName,
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
                    onPressed: () async {
                      await widget.controller.registerUser(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}