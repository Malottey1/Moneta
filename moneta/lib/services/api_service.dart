import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';


class ApiService {
  final String baseUrl = 'http://192.168.102.97/api/moneta';
  final Logger _logger = Logger();

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
      return json.decode(responseBody);
    } else {
      _logger.e('Failed to log expense. Status code: ${response.statusCode}');
      throw Exception('Failed to log expense');
    }
  }

  Future<List<dynamic>> getExpenses(int userId) async {
    final uri = Uri.parse('$baseUrl/get_expenses.php?user_id=$userId');
    _logger.d('Fetching expenses for user_id: $userId from $uri');

    final response = await http.get(uri);

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
      _logger.d('Budget saved successfully: ${response.body}');
      return json.decode(response.body);
    } else {
      _logger.e('Failed to save budget. Status code: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to save budget');
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
      _logger.d('Fetched budgets: $budgets');
      return budgets;
    } else {
      _logger.e('Failed to load budgets. Status code: ${response.statusCode}');
      throw Exception('Failed to load budgets');
    }
  }

  Future<List<dynamic>> getUserCategories(int userId) async {
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

  Future<Map<String, dynamic>> getMonthlyExpense(int userId) async {
    final url = Uri.parse('$baseUrl/get_monthly_expense.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load monthly expense');
    }
  }

  Future<List<dynamic>> getRecentTransactions(int userId) async {
    final url = Uri.parse('$baseUrl/get_recent_transactions.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recent transactions');
    }
  }

  Future<List<dynamic>> getBudgetSummaries(int userId) async {
    final url = Uri.parse('$baseUrl/get_budget_summaries.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
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
    request.files.add(
      await http.MultipartFile.fromPath('receipt_image', receiptImage.path),
    );
    print('🐛 Including receipt image with path: ${receiptImage.path}');
  }

  print('🐛 Sending update request with fields: ${request.fields}');

  final response = await request.send();
  final responseBody = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    print('🐛 Received response with status code: ${response.statusCode}');
    return json.decode(responseBody.body);
  } else {
    print('⛔ Failed to update expense. Status code: ${response.statusCode}, Body: ${responseBody.body}');
    throw Exception('Failed to update expense');
  }
}

  Future<Map<String, dynamic>> getUserExpenses(int userId) async {
    final uri = Uri.parse('$baseUrl/get_user_expenses.php?user_id=$userId');
    _logger.d('Fetching user expenses from $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _logger.e('Failed to fetch user expenses. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch user expenses');
    }
  }



  
}