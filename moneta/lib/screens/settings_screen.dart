import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneta/services/notification_service.dart';
import 'package:moneta/widgets/compose_email_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/settings_utils.dart';
import '../widgets/section_title.dart';
import '../widgets/list_tile.dart';
import '../widgets/switch_list_tile.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../controllers/email_controller.dart';

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

  Future<void> _syncData() async {
    try {
      await ApiService().syncData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data synchronized successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to synchronize data')),
      );
    }
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final newProfilePicture = File(pickedImage.path);

      // Upload the new profile picture to your server
      final url = Uri.parse('https://moneta.icu/api/upload_profile_picture.php');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('profile_picture', newProfilePicture.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          final newProfilePictureUrl = responseData['url'];
          userProvider.setProfilePictureUrl(newProfilePictureUrl);
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
          title: Text(
            'Change Password',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(fontFamily: 'SpaceGrotesk'),
                ),
                onChanged: (value) {
                  oldPassword = value;
                },
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontFamily: 'SpaceGrotesk'),
                ),
                onChanged: (value) {
                  newPassword = value;
                },
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(fontFamily: 'SpaceGrotesk'),
                ),
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
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.teal,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (newPassword == confirmPassword) {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final url = Uri.parse('https://moneta.icu/api/change_password.php');
                  final response = await http.post(
                    url,
                    body: {
                      'user_id': userProvider.userId.toString(),
                      'old_password': oldPassword,
                      'new_password': newPassword,
                    },
                  );

                  if (response.statusCode == 200) {
                    final responseBody = json.decode(response.body);
                    if (responseBody['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password changed successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to change password: ${responseBody['message']}')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error changing password')),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Change',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

Future<void> _deleteAccount() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final int userId = userProvider.userId;

  try {
    print('Attempting to delete account for userId: $userId'); // Log userId
    final response = await ApiService().deleteUserAccount(userId);
    print('API response: $response'); // Log API response

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted successfully.')),
      );
      // Navigate to login screen after account deletion
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: ${response['message']}')),
      );
    }
  } catch (e) {
    print('Error deleting account: $e'); // Log error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete account. Please try again.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final emailController = Provider.of<EmailController>(context);

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
        actions: [
          IconButton(
            icon: Icon(Icons.person_off, color: Colors.black),
            onPressed: _showDeleteAccountConfirmationDialog,
          ),
        ],
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
                            : AssetImage('assets/images/moneta-logo-2.png') as ImageProvider,
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
                    ),                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            SectionTitle(title: 'Account'),
            CustomListTile(
              icon: Icons.person,
              title: 'Name',
              subtitle: '${userProvider.firstName} ${userProvider.lastName}',
            ),
            CustomListTile(
              icon: Icons.mail,
              title: 'Email Address',
              subtitle: userProvider.email,
            ),
            CustomListTile(
              icon: Icons.lock,
              title: 'Password',
              subtitle: '',
              trailing: Icon(Icons.chevron_right),
              onTap: _changePassword,
            ),
            SizedBox(height: 24.0),
            SectionTitle(title: 'Notifications'),
            CustomSwitchListTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              value: _pushNotifications,
              onChanged: (bool newValue) {
                setState(() {
                  _pushNotifications = newValue;
                  _saveSettings();
                  if (newValue) {
                    LocalNotificationsService.enableNotifications();
                  } else {
                    LocalNotificationsService.disableNotifications();
                  }
                });
              },
            ),
            CustomSwitchListTile(
              icon: Icons.cloud_off,
              title: 'Offline Access',
              value: _offlineAccess,
              onChanged: (bool newValue) {
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
                onPressed: _syncData, // Call the sync data function
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
            SectionTitle(title: 'Support'),
            CustomListTile(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: '',
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showFeedbackDialog(context, emailController),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await _deleteAccount(); // Proceed with account deletion
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

  void _showFeedbackDialog(BuildContext context, EmailController emailController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Send Feedback',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: Colors.black,
            ),
          ),
          content: ComposeEmailWidget(email: emailController.email),  // Use the ComposeEmailWidget
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}