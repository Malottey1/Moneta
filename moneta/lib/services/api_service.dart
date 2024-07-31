import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneta/services/local_database_service.dart';

class ApiService {
  final String baseUrl = 'https://moneta.icu/api/';
  final Logger _logger = Logger();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ApiService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }



  Future<Map<String, dynamic>> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String gender,
    String dateOfBirth,
    File? profilePicture,
  ) async {
    final uri = Uri.parse('$baseUrl/register_user.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['gender'] = gender;
    request.fields['date_of_birth'] = dateOfBirth;

    if (profilePicture != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', profilePicture.path),
      );
    }

    _logger.d('Registering user with fields: ${request.fields}');

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      _logger.d('Registration successful: $responseBody');
      return json.decode(responseBody);
    } else {
      _logger.e('Failed to register user. Status code: ${response.statusCode}');
      throw Exception('Failed to register user');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login_user.php');
    _logger.d('Sending login request to $uri with email: $email and password: $password');

    final response = await http.post(
      uri,
      body: {
        'email': email,
        'password': password,
      },
    );

    _logger.d('Received response with status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _logger.e('Failed to login user. Status code: ${response.statusCode}');
      throw Exception('Failed to login user');
    }
  }

  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/get_categories.php');
    _logger.d('Fetching categories from $uri');

    final response = await http.get(uri);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _logger.d('Fetched categories: $data');
      return List<String>.from(data['categories']);
    } else {
      _logger.e('Failed to fetch categories. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch categories');
    }
  }

 Future<Map<String, dynamic>> logExpense(
  int userId,
  int categoryId,
  double amount,
  String date,
  String description,
  File? receiptImage,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

  if (offlineAccess) {
    // Log expense to local database
    final expense = {
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'date': date,
      'description': description,
      'receipt_image': receiptImage?.path ?? '',
    };
    await LocalDatabaseService().insertExpense(expense);
    await _handleExpenseNotifications(userId, categoryId, amount);
    return {'status': 'success', 'message': 'Expense logged locally'};
  } else {
    final uri = Uri.parse('$baseUrl/log_expense.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['amount'] = amount.toString();
    request.fields['date'] = date;
    request.fields['description'] = description;

    if (receiptImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('receipt_image', receiptImage.path),
      );
    }

    _logger.d('Logging expense with fields: ${request.fields}');

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      _logger.d('Expense logged successfully: $responseBody');
      final responseJson = json.decode(responseBody);

      // Handle notifications for budget checks
      await _handleExpenseNotifications(userId, categoryId, amount);

      return responseJson;
    } else {
      _logger.e('Failed to log expense. Status code: ${response.statusCode}');
      throw Exception('Failed to log expense');
    }
  }
}

Future<void> _handleExpenseNotifications(int userId, int categoryId, double amount) async {
  final budgets = await getBudgets(userId);
  final budgetForCategory = budgets.firstWhere(
      (budget) => budget['category_id'] == categoryId,
      orElse: () => null);

  if (budgetForCategory == null) {
    // Notify user to create a budget for this category
    await _showNotification(
        'No Budget Found',
        'You have logged an expense for a category that does not have a budget. Would you like to create one?');
  } else {
    double totalExpensesForCategory = 0.0;
    final expenses = await getExpenses(userId);

    _logger.d('Expenses fetched for user: $userId');

    for (var expense in expenses) {
      if (expense['category_id'] == categoryId) {
        totalExpensesForCategory += double.parse(expense['amount']);
      }
    }

    _logger.d('Total expenses for category $categoryId: $totalExpensesForCategory');
    _logger.d('Current expense amount: $amount');
    _logger.d('Budget amount for category $categoryId: ${budgetForCategory['amount']}');

    double newTotalExpenses = totalExpensesForCategory + amount;
    _logger.d('New total expenses for category $categoryId: $newTotalExpenses');

    if (newTotalExpenses > double.parse(budgetForCategory['amount'])) {
      _logger.d('Budget overflow detected for category $categoryId');
      // Notify user about budget overflow
      await _showNotification(
          'Budget Exceeded',
          'You have exceeded your budget for this category. Would you like to edit the budget?');
    } else {
      _logger.d('No budget overflow detected for category $categoryId');
    }
  }
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<List<dynamic>> getExpenses(int userId, {String? sort, String? search}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

  if (offlineAccess) {
    // Fetch expenses from local database
    return await LocalDatabaseService().getExpenses(userId);
  } else {
    String uri = '$baseUrl/get_expenses.php?user_id=$userId';
    if (sort != null) {
      uri += '&sort=$sort';
    }
    if (search != null && search.isNotEmpty) {
      uri += '&search=$search';
    }
    _logger.d('Fetching expenses for user_id: $userId from $uri');

    final response = await http.get(Uri.parse(uri));

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> expenses = json.decode(response.body);
      _logger.d('Fetched expenses: $expenses');
      return expenses;
    } else {
      _logger.e('Failed to load expenses. Status code: ${response.statusCode}');
      throw Exception('Failed to load expenses');
    }
  }
}

Future<List<dynamic>> getBudgets(int userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

  if (offlineAccess) {
    // Fetch budgets from local database
    return await LocalDatabaseService().getBudgets(userId);
  } else {
    final uri = Uri.parse('$baseUrl/get_budgets.php?user_id=$userId');
    _logger.d('Fetching budgets for user_id: $userId from $uri');

    final response = await http.get(uri);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> budgets = json.decode(response.body);
      _logger.d('Fetched budgets: $budgets');
      return budgets;
    } else {
      _logger.e('Failed to load budgets. Status code: ${response.statusCode}');
      throw Exception('Failed to load budgets');
    }
  }
}


  Future<Map<String, dynamic>> saveBudget(
    int userId,
    int categoryId,
    double amount,
    String startDate,
    String endDate,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Save budget to local database
      final budget = {
                'user_id': userId,
        'category_id': categoryId,
        'amount': amount,
        'start_date': startDate,
        'end_date': endDate,
      };
      await LocalDatabaseService().insertBudget(budget);
      return {'status': 'success', 'message': 'Budget saved locally'};
    } else {
      final uri = Uri.parse('$baseUrl/save_budget.php');
      _logger.d('Saving budget with user_id: $userId, category_id: $categoryId, amount: $amount, start_date: $startDate, end_date: $endDate');

      final response = await http.post(
        uri,
        body: {
          'user_id': userId.toString(),
          'category_id': categoryId.toString(),
          'amount': amount.toString(),
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _logger.d('Budget saved successfully: ${response.body}');
        return json.decode(response.body);
      } else {
        _logger.e('Failed to save budget. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to save budget');
      }
    }
  }



  Future<List<dynamic>> getUserCategories(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch user categories from local database
      return await LocalDatabaseService().getUserCategories(userId);
    } else {
      final uri = Uri.parse('$baseUrl/get_user_categories.php?user_id=$userId');
      _logger.d('Fetching categories for user_id: $userId from $uri');

      final response = await http.get(uri);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> categories = json.decode(response.body);
        _logger.d('Fetched categories: $categories');
        return categories;
      } else {
        _logger.e('Failed to load categories. Status code: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    }
  }

  Future<Map<String, dynamic>> getMonthlyExpense(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch monthly expenses from local database
      // This example assumes you have a method to calculate monthly expenses locally
      final expenses = await LocalDatabaseService().getExpenses(userId);
      // Calculate monthly expense
      double monthlyExpense = 0;
      for (var expense in expenses) {
        monthlyExpense += expense['amount'];
      }
      return {'monthly_expense': monthlyExpense};
    } else {
      final url = Uri.parse('$baseUrl/get_monthly_expense.php?user_id=$userId');
      _logger.d('Fetching monthly expenses for user_id: $userId from $url');

      final response = await http.get(url);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to load monthly expense. Status code: ${response.statusCode}');
        throw Exception('Failed to load monthly expense');
      }
    }
  }

  Future<List<dynamic>> getRecentTransactions(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch recent transactions from local database
      // This example assumes you have a method to get recent transactions locally
      final expenses = await LocalDatabaseService().getExpenses(userId);
      // Return the most recent transactions (last 5 for example)
      return expenses.take(5).toList();
    } else {
      final url = Uri.parse('$baseUrl/get_recent_transactions.php?user_id=$userId');
      _logger.d('Fetching recent transactions for user_id: $userId from $url');

      final response = await http.get(url);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to load recent transactions. Status code: ${response.statusCode}');
        throw Exception('Failed to load recent transactions');
      }
    }
  }

  Future<List<dynamic>> getBudgetSummaries(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch budget summaries from local database
      // This example assumes you have a method to get budget summaries locally
      final budgets = await LocalDatabaseService().getBudgets(userId);
      // Summarize budgets
      List<Map<String, dynamic>> summaries = [];
      for (var budget in budgets) {
        summaries.add({
          'category_id': budget['category_id'],
          'amount': budget['amount'],
          'start_date': budget['start_date'],
          'end_date': budget['end_date'],
        });
      }
      return summaries;
    } else {
      final url = Uri.parse('$baseUrl/get_budget_summaries.php?user_id=$userId');
      _logger.d('Fetching budget summaries for user_id: $userId from $url');

      final response = await http.get(url);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to load budget summaries. Status code: ${response.statusCode}');
        throw Exception('Failed to load budget summaries');
      }
    }
  }

  Future<Map<String, dynamic>> editExpense(
    String expenseId,
    String userId,
    String categoryId,
    double amount,
    String date,
    String description,
    File? receiptImage,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Edit expense in local database
      final expense = {
        'expense_id': int.parse(expenseId),
        'user_id': int.parse(userId),
        'category_id': int.parse(categoryId),
        'amount': amount,
        'date': date,
        'description': description,
        'receipt_image': receiptImage?.path ?? '',
      };
      await LocalDatabaseService().insertExpense(expense); // Using insertExpense to update
      return {'status': 'success', 'message': 'Expense updated locally'};
    } else {
      final url = Uri.parse('$baseUrl/edit_expense.php');

      var request = http.MultipartRequest('POST', url);
      request.fields['expense_id'] = expenseId;
      request.fields['user_id'] = userId;
      request.fields['category_id'] = categoryId;
      request.fields['amount'] = amount.toString();
      request.fields['date'] = date;
      request.fields['description'] = description;

      if (receiptImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('receipt_image', receiptImage.path),
        );
        _logger.d('Including receipt image with path: ${receiptImage.path}');
      }

      _logger.d('Sending update request with fields: ${request.fields}');

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      _logger.d('Received response with status code: ${response.statusCode}');
      _logger.d('Response body: ${responseBody.body}');

      if (response.statusCode == 200) {
        return json.decode(responseBody.body);
      } else {
        _logger.e('Failed to update expense. Status code: ${response.statusCode}, Body: ${responseBody.body}');
        throw Exception('Failed to update expense');
      }
    }
  }

  Future getUserExpenses(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch user expenses from local database
      return await LocalDatabaseService().getExpenses(userId);
    } else {
      final uri = Uri.parse('$baseUrl/get_user_expenses.php?user_id=$userId');
      _logger.d('Fetching user expenses from $uri');

      final response = await http.get(uri);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to fetch user expenses. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch user expenses');
      }
    }
  }

  Future<Map<String, dynamic>> deleteExpense(String id, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Delete expense from local database
      await LocalDatabaseService().deleteExpense(int.parse(id));
      return {'status': 'success', 'message': 'Expense deleted locally'};
    } else {
      final uri = Uri.parse('$baseUrl/delete_expense.php');
      _logger.d('Deleting expense with id: $id for user_id: $userId from $uri');

      final response = await http.post(
        uri,
        body: {
          'id': id,
          'user_id': userId,
        },
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          return json.decode(response.body);
        } else {
          _logger.e('Unexpected response format: ${response.body}');
          return {'status': 'error', 'message': 'Unexpected response format: ${response.body}'};
        }
      } else {
        _logger.e('Failed to delete expense. Status code: ${response.statusCode}');
        throw Exception('Failed to delete expense');
      }
    }
  }

  Future<Map<String, dynamic>> updateBudget(
    String id,
    int userId,
    int categoryId,
    double amount,
    String startDate,
    String endDate,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Update budget in local database
      final budget = {
        'budget_id': int.parse(id),
        'user_id': userId,
        'category_id': categoryId,
        'amount': amount,
        'start_date': startDate,
        'end_date': endDate,
      };
      await LocalDatabaseService().insertBudget(budget); // Using insertBudget to update
      return {'status': 'success', 'message': 'Budget updated locally'};
    } else {
      final uri = Uri.parse('$baseUrl/update_budget.php');
      _logger.d('Updating budget with id: $id, user_id: $userId, category_id: $categoryId, amount: $amount, start_date: $startDate, end_date: $endDate');

      final response = await http.post(
        uri,
        body: {
          'id': id,
          'user_id': userId.toString(),
          'category_id': categoryId.toString(),
          'amount': amount.toString(),
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to update budget. Status code: ${response.statusCode}');
        throw Exception('Failed to update budget');
      }
    }
  }

  Future<Map<String, dynamic>> deleteBudget(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Delete budget from local database
      await LocalDatabaseService().deleteBudget(int.parse(id));
      return {'status': 'success', 'message': 'Budget deleted locally'};
    } else {
      final uri = Uri.parse('$baseUrl/delete_budget.php');
      _logger.d('Deleting budget with id: $id');

      final response = await http.post(
        uri,
        body: {'id': id},
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to delete budget. Status code: ${response.statusCode}');
        throw Exception('Failed to delete budget');
      }
    }
  }

  Future<void> syncData() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineAccess = prefs.getBool('offlineAccess') ?? false;

    Future<void> _fetchAndStoreExpensesFromServer() async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final expenses = await fetchExpenses(userId);
        await LocalDatabaseService().clearAndInsertExpenses(expenses);
      }
    }

    Future<void> _fetchAndStoreBudgetsFromServer() async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final budgets = await fetchBudgets(userId);
        await LocalDatabaseService().clearAndInsertBudgets(budgets);
      }
    }

    if (!offlineAccess) {
      _logger.d('Offline access is disabled. Skipping sync.');
      return;
    }

    _logger.d('Starting data synchronization.');

    try {
      // Step 1: Sync local changes to the server
      await _syncLocalExpensesToServer();
      await _syncLocalBudgetsToServer();

      // Step 2: Fetch latest data from the server and update local database
      await _fetchAndStoreExpensesFromServer();
      await _fetchAndStoreBudgetsFromServer();

      _logger.d('Data synchronization completed successfully.');
    } catch (e) {
      _logger.e('Error during data synchronization: $e');
    }
  }

  Future<void> _syncLocalExpensesToServer() async {
    final localExpenses = await LocalDatabaseService().getUnsyncedExpenses();
    for (var expense in localExpenses) {
      final response = await logExpense(
        expense['user_id'],
        expense['category_id'],
        expense['amount'],
        expense['date'],
        expense['description'],
        File(expense['receipt_image']),
      );
      if (response['status'] == 'success') {
        await LocalDatabaseService().markExpenseAsSynced(expense['id']);
      }
    }
  }

  Future<void> _syncLocalBudgetsToServer() async {
    final localBudgets = await LocalDatabaseService().getUnsyncedBudgets();
    for (var budget in localBudgets) {
      final response = await saveBudget(
        budget['user_id'],
        budget['category_id'],
        budget['amount'],
        budget['start_date'],
        budget['end_date'],
      );
      if (response['status'] == 'success') {
        await LocalDatabaseService().markBudgetAsSynced(budget['id']);
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchExpenses(int userId, {String? sort, String? search}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch expenses from local database
      return await LocalDatabaseService().getExpenses(userId);
    } else {
      String uri = '$baseUrl/get_expenses.php?user_id=$userId';
      if (sort != null) {
        uri += '&sort=$sort';
      }
      if (search != null && search.isNotEmpty) {
        uri += '&search=$search';
      }
      _logger.d('Fetching expenses for user_id: $userId from $uri');

      final response = await http.get(Uri.parse(uri));

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> expenses = List<Map<String, dynamic>>.from(json.decode(response.body));
        _logger.d('Fetched expenses: $expenses');
        return expenses;
      } else {
        _logger.e('Failed to load expenses. Status code: ${response.statusCode}');
        throw Exception('Failed to load expenses');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchBudgets(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool offlineAccess = prefs.getBool('offlineAccess') ?? false;

    if (offlineAccess) {
      // Fetch budgets from local database
      return await LocalDatabaseService().getBudgets(userId);
    } else {
            final uri = Uri.parse('$baseUrl/get_budgets.php?user_id=$userId');
      _logger.d('Fetching budgets for user_id: $userId from $uri');

      final response = await http.get(uri);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> budgets = List<Map<String, dynamic>>.from(json.decode(response.body));
        _logger.d('Fetched budgets: $budgets');
        return budgets;
      } else {
        _logger.e('Failed to load budgets. Status code: ${response.statusCode}');
        throw Exception('Failed to load budgets');
      }
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount(int userId) async {
    final uri = Uri.parse('$baseUrl/delete_user_account.php');
    _logger.d('Sending request to delete user account with user_id: $userId to $uri');

    final response = await http.post(
      uri,
      body: {'user_id': userId.toString()},
    );

    _logger.d('Response status code: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      _logger.d('JSON response: $jsonResponse');
      return jsonResponse;
    } else {
      _logger.e('Failed to delete user account. Status code: ${response.statusCode}, Response body: ${response.body}');
      throw Exception('Failed to delete user account');
    }
  }
}