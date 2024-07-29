import 'package:flutter/material.dart';
import 'package:moneta/widgets/action_button.dart';
import 'package:moneta/widgets/budget_summary_item.dart';
import 'package:moneta/widgets/custom_rounded_rectangle_border.dart';
import 'package:moneta/widgets/expense_item.dart';
import 'package:moneta/widgets/sidebar_menu.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/moneta-logo-2.png',
              width: 24,
              height: 24,
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Implement your logic here
            },
          ),
        ],
      ),
      drawer: SidebarMenu(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Kwadwo',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: ShapeDecoration(
                color: Colors.teal,
                shape: CustomRoundedRectangleBorder(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'You spent',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(flex: 5),
                      Icon(
                        Icons.visibility,
                        color: Colors.white,
                      ),
                      Spacer(flex: 1),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'GHS 5009.52',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'this month',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ExpenseItem(date: '27-07-2024', category: 'Food', amount: 'GHS 150.50'),
                  Divider(),
                  ExpenseItem(date: '26-07-2024', category: 'Utilities', amount: 'GHS 110.50'),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Budget Summaries',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  BudgetSummaryItem(category: 'Food', budget: 'GHS 300', spent: 'GHS 110.50'),
                  Divider(),
                  BudgetSummaryItem(category: 'Travel', budget: 'GHS 300', spent: 'GHS 110.50'),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionButton(icon: Icons.add, label: 'Add Expense', onPressed: () {
                  // Implement your logic here
                }),
                ActionButton(icon: Icons.pie_chart, label: 'View Reports', onPressed: () {
                  // Implement your logic here
                }),
                ActionButton(icon: Icons.settings, label: 'Set Budgets', onPressed: () {
                  // Implement your logic here
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}