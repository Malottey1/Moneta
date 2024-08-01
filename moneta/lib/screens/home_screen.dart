import 'package:flutter/material.dart';
import 'package:moneta/screens/budget_setting.dart';
import 'package:moneta/screens/expense_logging_screen.dart';
import 'package:moneta/screens/expense_screen.dart';
import 'package:moneta/screens/reports_screen.dart';
import 'package:provider/provider.dart';
import 'package:moneta/services/api_service.dart';
import 'package:moneta/providers/user_provider.dart';
import 'package:moneta/widgets/action_button.dart';
import 'package:moneta/widgets/budget_summary_item.dart';
import 'package:moneta/widgets/custom_rounded_rectangle_border.dart';
import 'package:moneta/widgets/expense_item.dart';
import 'package:moneta/widgets/sidebar_menu.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger _logger = Logger();

  String userName = '';
  double totalMonthlyExpense = 0.0;
  List<dynamic> recentTransactions = [];
  List<dynamic> budgetSummaries = [];
  bool isLoading = true;
  bool isExpenseVisible = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    // Fetch user name
    userName = userProvider.firstName ?? 'User';
    _logger.d('User name: $userName');

    // Fetch monthly expense
    final monthlyExpenseResponse = await ApiService().getMonthlyExpense(userId);
    _logger.d('Monthly expense response: $monthlyExpenseResponse');
    totalMonthlyExpense = double.tryParse(monthlyExpenseResponse['total_spent'] ?? '0') ?? 0.0;
    _logger.d('Total monthly expense: $totalMonthlyExpense');

    // Fetch recent transactions
    final transactionsResponse = await ApiService().getRecentTransactions(userId);
    _logger.d('Transactions response: $transactionsResponse');
    if (transactionsResponse is List && transactionsResponse.isNotEmpty) {
      recentTransactions = transactionsResponse;
    } else {
      _logger.w('No recent transactions found');
      recentTransactions = [];
    }
    _logger.d('Recent transactions: $recentTransactions');

    // Fetch budget summaries
    final budgetResponse = await ApiService().getBudgetSummaries(userId);
    _logger.d('Budget response: $budgetResponse');
    if (budgetResponse is List && budgetResponse.isNotEmpty) {
      budgetSummaries = budgetResponse;
    } else {
      _logger.w('No budget summaries found');
      budgetSummaries = [];
    }
    _logger.d('Budget summaries: $budgetSummaries');

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    _logger.e('Error fetching data: $e');
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching data. Please try again later.')),
    );
  }
}

  void toggleExpenseVisibility() {
    setState(() {
      isExpenseVisible = !isExpenseVisible;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('HomeScreen build method called');
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
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Implement your logic here
            },
          ),
        ],
      ),
      drawer: SidebarMenu(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $userName',
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
                                'You have spent',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(flex: 5),
                              IconButton(
                                icon: Icon(
                                  isExpenseVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: toggleExpenseVisibility,
                              ),
                              Spacer(flex: 1),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            isExpenseVisible
                                ? 'GHS ${totalMonthlyExpense.toStringAsFixed(2)}'
                                : 'GHS *****',
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
                              fontWeight: FontWeight.bold,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Amount',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          ...recentTransactions.map((transaction) => transaction != null
                              ? Column(
                                  children: [
                                    ExpenseItem(
                                      date: transaction['date'] ?? '',
                                      category: transaction['category'] ?? 'Unknown',
                                      amount: 'GHS ${double.tryParse(transaction['amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                                    ),
                                    Divider(),
                                  ],
                                )
                              : Container()),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Budget',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Spent',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          ...budgetSummaries.map((budget) => budget != null
                              ? Column(
                                  children: [
                                    BudgetSummaryItem(
                                      category: budget['category_name'] ?? 'Unknown',
                                      budget: 'GHS ${double.tryParse(budget['budget']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                                      spent: 'GHS ${double.tryParse(budget['spent']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                                    ),
                                    Divider(),
                                  ],
                                )
                              : Container()),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ActionButton(
                          icon: Icons.add,
                          label: 'Add Expense',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseLoggingScreen()));
                          },
                        ),
                        ActionButton(
                          icon: Icons.pie_chart,
                          label: 'View Reports',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseReportScreen()));
                          },
                        ),
                        ActionButton(
                          icon: Icons.settings,
                          label: 'Set Budgets',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateBudgetScreen()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}