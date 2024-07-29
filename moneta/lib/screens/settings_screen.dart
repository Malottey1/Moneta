import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/settings_utils.dart';
import '../widgets/settings_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://www.example.com/profile_image.png'), // Replace with actual image URL or asset
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Leslie Rasmund',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@leslieras',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'San Francisco, CA',
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
            buildListTile(Icons.person, 'Username', 'leslieras'),
            buildListTile(Icons.phone, 'Mobile Number', '(405) 439 - 3985'),
            buildListTile(Icons.lock, 'Password', '', trailing: Icon(Icons.chevron_right)),
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