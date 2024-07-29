import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
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
            _buildSectionTitle('Account'),
            _buildListTile(Icons.person, 'Username', 'leslieras'),
            _buildListTile(Icons.phone, 'Mobile Number', '(405) 439 - 3985'),
            _buildListTile(Icons.lock, 'Password', '', trailing: Icon(Icons.chevron_right)),
            SizedBox(height: 24.0),
            _buildSectionTitle('Notifications'),
            _buildSwitchListTile(Icons.notifications, 'Push Notifications', true),
            _buildSwitchListTile(Icons.cloud_off, 'Offline Access', false),
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
            _buildSectionTitle('Support'),
            _buildListTile(Icons.help, 'Help Center', '', trailing: Icon(Icons.chevron_right)),
            _buildListTile(Icons.feedback, 'Send Feedback', '', trailing: Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: trailing,
    );
  }

  Widget _buildSwitchListTile(IconData icon, String title, bool value) {
    return SwitchListTile(
      activeColor: Colors.teal,
      secondary: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      value: value,
      onChanged: (bool newValue) {
        // Implement your logic here
      },
    );
  }
}