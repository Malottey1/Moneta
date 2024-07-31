import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  static Database? _database;

  LocalDatabaseService._internal();

  factory LocalDatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'moneta.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        password TEXT,
        date_of_birth TEXT,
        gender TEXT,
        profile_picture TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE User_Settings (
        user_settings_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        push_notifications INTEGER,
        offline_access INTEGER,
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Categories (
        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE User_Categories (
        user_category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        category_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Budgets (
        budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        category_id INTEGER,
        amount REAL,
        start_date TEXT,
        end_date TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Expenses (
        expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        category_id INTEGER,
        amount REAL,
        date TEXT,
        description TEXT,
        receipt_image TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id)
      )
    ''');
  }

  Future<void> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.insert('Expenses', expense, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getExpenses(int userId) async {
    final db = await database;
    return await db.query('Expenses', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedExpenses() async {
    final db = await database;
    return await db.query('Expenses', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markExpenseAsSynced(int id) async {
    final db = await database;
    await db.update('Expenses', {'synced': 1}, where: 'expense_id = ?', whereArgs: [id]);
  }

  Future<void> clearAndInsertExpenses(List<Map<String, dynamic>> expenses) async {
    final db = await database;
    await db.delete('Expenses');
    for (var expense in expenses) {
      await db.insert('Expenses', expense);
    }
  }

  Future<void> insertSetting(Map<String, dynamic> setting) async {
    final db = await database;
    await db.insert('User_Settings', setting, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getSetting(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> settings = await db.query('User_Settings', where: 'user_id = ?', whereArgs: [userId]);
    return settings.isNotEmpty ? settings.first : null;
  }

  Future<void> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    await db.insert('Budgets', budget, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getBudgets(int userId) async {
    final db = await database;
    return await db.query('Budgets', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedBudgets() async {
    final db = await database;
    return await db.query('Budgets', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markBudgetAsSynced(int id) async {
    final db = await database;
    await db.update('Budgets', {'synced': 1}, where: 'budget_id = ?', whereArgs: [id]);
  }

  Future<void> clearAndInsertBudgets(List<Map<String, dynamic>> budgets) async {
    final db = await database;
    await db.delete('Budgets');
    for (var budget in budgets) {
      await db.insert('Budgets', budget);
    }
  }

  Future<void> insertUserCategory(Map<String, dynamic> userCategory) async {
    final db = await database;
    await db.insert('User_Categories', userCategory, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserCategories(int userId) async {
    final db = await database;
    return await db.query('User_Categories', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('Categories');
  }

  Future<void> deleteExpense(int expenseId) async {
    final db = await database;
    await db.delete('Expenses', where: 'expense_id = ?', whereArgs: [expenseId]);
  }

  Future<void> deleteBudget(int budgetId) async {
    final db = await database;
    await db.delete('Budgets', where: 'budget_id = ?', whereArgs: [budgetId]);
  }
}