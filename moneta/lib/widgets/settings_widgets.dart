// settings_widgets.dart
import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
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

Widget buildListTile(IconData icon, String title, String subtitle,
    {Widget? trailing, VoidCallback? onTap}) {
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
    onTap: onTap,
  );
}

Widget buildSwitchListTile(
    IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
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
    onChanged: onChanged,
  );
}