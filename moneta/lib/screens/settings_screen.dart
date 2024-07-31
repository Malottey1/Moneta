import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/settings_utils.dart';
import '../widgets/settings_widgets.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _offlineAccess = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _offlineAccess = prefs.getBool('offlineAccess') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('pushNotifications', _pushNotifications);
    prefs.setBool('offlineAccess', _offlineAccess);
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      print('Selected image path: ${pickedImage.path}');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final newProfilePicture = File(pickedImage.path);

      // Upload the new profile picture to your server
      final url = Uri.parse('http://192.168.102.97/api/moneta/upload_profile_picture.php');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('profile_picture', newProfilePicture.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          final newProfilePictureUrl = responseData['url'];
          userProvider.setProfilePictureUrl(newProfilePictureUrl);

          // Log the updated profile picture URL
          print('Updated profile picture URL: $newProfilePictureUrl');

          // Log the current profile picture URL in the UserProvider
          print('Profile picture URL set in UserProvider: ${userProvider.profilePictureUrl}');
        } else {
          print('Error uploading profile picture: ${responseData['message']}');
        }
      } else {
        print('Error uploading profile picture: ${response.statusCode}');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _changePassword() async {
    String oldPassword = '', newPassword = '', confirmPassword = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Old Password'),
                onChanged: (value) {
                  oldPassword = value;
                },
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                onChanged: (value) {
                  newPassword = value;
                },
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                onChanged: (value) {
                  confirmPassword = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newPassword == confirmPassword) {
                  // Implement logic to change password, e.g., API call
                }
                Navigator.of(context).pop();
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Log the current profile picture URL
    if (userProvider.profilePictureUrl != null) {
      print('Current profile picture URL: ${userProvider.profilePictureUrl}');
    } else {
      print('No profile picture set.');
    }

    // Log the current user details
    print('User details: ${userProvider.firstName} ${userProvider.lastName}, ${userProvider.email}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userProvider.profilePictureUrl != null
                            ? NetworkImage(userProvider.profilePictureUrl!)
                            : AssetImage('assets/images/moneta-logo-2.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _changeProfilePicture,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${userProvider.firstName} ${userProvider.lastName}',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${userProvider.firstName.toLowerCase()}${userProvider.lastName.toLowerCase()}',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            buildSectionTitle('Account'),
            buildListTile(Icons.person, 'Name', '${userProvider.firstName} ${userProvider.lastName}'),
            buildListTile(Icons.mail, 'Email Address', userProvider.email),
            buildListTile(Icons.lock, 'Password', '', trailing: Icon(Icons.chevron_right), onTap: _changePassword),
            SizedBox(height: 24.0),
            buildSectionTitle('Notifications'),
            buildSwitchListTile(
              Icons.notifications,
              'Push Notifications',
              _pushNotifications,
              (bool newValue) {
                setState(() {
                  _pushNotifications = newValue;
                  _saveSettings();
                  if (newValue) {
                    showNotification();
                  }
                });
              },
            ),
            buildSwitchListTile(
              Icons.cloud_off,
              'Offline Access',
              _offlineAccess,
              (bool newValue) {
                setState(() {
                  _offlineAccess = newValue;
                  _saveSettings();
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.sync),
              title: Text(
                'Sync Data',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: TextButton(
                onPressed: () {
                  // Implement your logic here
                },
                child: Text(
                  'Sync Now',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            buildSectionTitle('Support'),
            buildListTile(Icons.help, 'Help Center', '', trailing: Icon(Icons.chevron_right)),
            buildListTile(
              Icons.feedback,
              'Send Feedback',
              '',
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                sendFeedback();
              },
            ),
          ],
        ),
      ),
    );
  }
}