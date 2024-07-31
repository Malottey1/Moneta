import 'package:flutter/material.dart';
import 'package:moneta/screens/budget_setting.dart';
import 'package:moneta/widgets/budget_item.dart';
import 'package:moneta/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:moneta/providers/user_provider.dart';

class BudgetsScreen extends StatefulWidget {
  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<dynamic> budgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    try {
      final fetchedBudgets = await ApiService().getBudgets(userId);
      setState(() {
        budgets = fetchedBudgets;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budgets. Please try again.')),
      );
    }
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
          'Budgets',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your budgets',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        final allocated = double.tryParse(budget['amount']?.toString() ?? '0') ?? 0.0;
                        final spent = double.tryParse(budget['spent']?.toString() ?? '0') ?? 0.0;
                        final progress = allocated != 0 ? (spent / allocated * 100).toInt() : 0;

                        return BudgetItem(
                          category: budget['category_name'],
                          allocated: 'GHS $allocated',
                          spent: 'GHS $spent',
                          progress: progress,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBudgetScreen()),
          ).then((_) {
            fetchBudgets(); // Refresh the list after setting a new budget
          });
        },
        icon: Icon(
          Icons.add,
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        label: Text(
          'Set New Budget',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}