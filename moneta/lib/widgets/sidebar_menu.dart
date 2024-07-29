import 'package:flutter/material.dart';
import 'package:moneta/screens/budget_screen.dart';
import 'package:moneta/screens/categories_screen.dart';
import 'package:moneta/screens/expense_screen.dart';
import 'package:moneta/screens/home_screen.dart';
import 'package:moneta/screens/reports_screen.dart';
import 'package:moneta/screens/settings_screen.dart';


class SidebarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 100.0, left: 16, bottom: 16.0, right: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/moneta-logo-2.png',
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'MONETA',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 25, color: Colors.teal),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            text: 'Home',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.attach_money,
            text: 'Expenses',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.category,
            text: 'Categories',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.pie_chart,
            text: 'Budgets',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => BudgetsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart,
            text: 'Reports',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            text: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}