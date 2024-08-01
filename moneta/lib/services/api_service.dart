import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  final String baseUrl = 'https://moneta.icu/api/';
  final Logger _logger = Logger();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ApiService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/get_categories.php');
    _logger.d('Fetching categories from $uri');
    final response = await http.get(uri);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categories = List<String>.from(data['categories']);
      return categories;
    } else {
      _logger.e('Failed to fetch categories. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch categories');
    }
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
      request.files.add(await http.MultipartFile.fromPath('profile_picture', profilePicture.path));
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

  Future<Map<String, dynamic>> logExpense(
    int userId,
    int categoryId,
    double amount,
    String date,
    String description,
    File? receiptImage,
  ) async {
    final uri = Uri.parse('$baseUrl/log_expense.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['amount'] = amount.toString();
    request.fields['date'] = date;
    request.fields['description'] = description;

    if (receiptImage != null) {
      request.files.add(await http.MultipartFile.fromPath('receipt_image', receiptImage.path));
    }

    _logger.d('Logging expense with fields: ${request.fields}');

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);
      await _handleExpenseNotifications(userId, categoryId, amount);
      return responseJson;
    } else {
      _logger.e('Failed to log expense. Status code: ${response.statusCode}');
      throw Exception('Failed to log expense');
    }
  }

  Future<void> _handleExpenseNotifications(int userId, int categoryId, double amount) async {
    final budgets = await getBudgets(userId);
    final budgetForCategory = budgets.firstWhere(
      (budget) => budget['category_id'] == categoryId,
      orElse: () => <String, dynamic>{},
    );

    if (budgetForCategory.isEmpty) {
      await _showNotification(
          'No Budget Found', 'You have logged an expense for a category that does not have a budget. Would you like to create one?');
    } else {
      double totalExpensesForCategory = 0.0;
      final expenses = await getExpenses(userId);

      for (var expense in expenses) {
        if (expense['category_id'] == categoryId) {
          totalExpensesForCategory += double.parse(expense['amount']);
        }
      }

      double newTotalExpenses = totalExpensesForCategory + amount;

      if (newTotalExpenses > double.parse(budgetForCategory['amount'])) {
        await _showNotification(
            'Budget Exceeded', 'You have exceeded your budget for this category. Would you like to edit the budget?');
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<List<dynamic>> getExpenses(int userId, {String? sort, String? search}) async {
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
      return expenses;
    } else {
      _logger.e('Failed to load expenses. Status code: ${response.statusCode}');
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<dynamic>> getBudgets(int userId) async {
    final uri = Uri.parse('$baseUrl/get_budgets.php?user_id=$userId');
    _logger.d('Fetching budgets for user_id: $userId from $uri');

    final response = await http.get(uri);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> budgets = json.decode(response.body);
      return budgets;
    } else {
      _logger.e('Failed to load budgets. Status code: ${response.statusCode}');
      throw Exception('Failed to load budgets');
    }
  }

  Future<Map<String, dynamic>> saveBudget(
    int userId,
    int categoryId,
    double amount,
    String startDate,
    String endDate,
  ) async {
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
      return json.decode(response.body);
    } else {
      _logger.e('Failed to save budget. Status code: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to save budget');
    }
  }

  Future<List<dynamic>> getUserCategories(int userId) async {
    final uri = Uri.parse('$baseUrl/get_user_categories.php?user_id=$userId');
    _logger.d('Fetching categories for user_id: $userId from $uri');

    final response = await http.get(uri);

        _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> categories = json.decode(response.body);
      return categories;
    } else {
      _logger.e('Failed to load categories. Status code: ${response.statusCode}');
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> getMonthlyExpense(int userId) async {
    final uri = Uri.parse('$baseUrl/get_monthly_expense.php?user_id=$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load monthly expense');
    }
  }

  Future<List<dynamic>> getRecentTransactions(int userId) async {
    final url = Uri.parse('$baseUrl/get_recent_transactions.php?user_id=$userId');
    _logger.d('Fetching recent transactions for user_id: $userId from $url');

    final response = await http.get(url);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        return jsonResponse;
      } else {
        _logger.e('Unexpected response format: $jsonResponse');
        throw Exception('Failed to load recent transactions');
      }
    } else {
      _logger.e('Failed to load recent transactions. Status code: ${response.statusCode}');
      throw Exception('Failed to load recent transactions');
    }
  }

  Future<List<dynamic>> getBudgetSummaries(int userId) async {
    final url = Uri.parse('$baseUrl/get_budget_summaries.php?user_id=$userId');
    _logger.d('Fetching budget summaries for user_id: $userId from $url');

    final response = await http.get(url);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        return jsonResponse;
      } else if (jsonResponse is Map && jsonResponse.containsKey('error')) {
        _logger.w('No budget summaries found for user_id: $userId');
        return [];
      } else {
        _logger.e('Unexpected response format: $jsonResponse');
        throw Exception('Failed to load budget summaries');
      }
    } else {
      _logger.e('Failed to load budget summaries. Status code: ${response.statusCode}');
      throw Exception('Failed to load budget summaries');
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
    final url = Uri.parse('$baseUrl/edit_expense.php');

    var request = http.MultipartRequest('POST', url);
    request.fields['expense_id'] = expenseId;
    request.fields['user_id'] = userId;
    request.fields['category_id'] = categoryId;
    request.fields['amount'] = amount.toString();
    request.fields['date'] = date;
    request.fields['description'] = description;

    if (receiptImage != null) {
      request.files.add(await http.MultipartFile.fromPath('receipt_image', receiptImage.path));
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

  Future<Map<String, dynamic>> deleteExpense(String id, String userId) async {
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

  Future<Map<String, dynamic>> updateBudget(
    String id,
    int userId,
    int categoryId,
    double amount,
    String startDate,
    String endDate,
  ) async {
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

  Future<Map<String, dynamic>> deleteBudget(String id) async {
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

  Future<Map<String, dynamic>> getExpenseDetails(String expenseId, String userId) async {
    final uri = Uri.parse('$baseUrl/get_expense_details.php?expense_id=$expenseId&user_id=$userId');
    _logger.d('Fetching expense details from $uri');

    final response = await http.get(uri);

    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      _logger.d('Fetched expense details: $responseJson');
      return responseJson;
    } else {
      _logger.e('Failed to fetch expense details. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch expense details');
    }
  }

    Future<void> syncData() async {
   
    }
}