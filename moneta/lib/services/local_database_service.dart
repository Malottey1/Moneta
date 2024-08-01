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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        date_of_birth TEXT,
        gender TEXT,
        profile_picture TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE User_Settings (
        user_settings_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        push_notifications INTEGER,
        offline_access INTEGER,
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Categories (
        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE User_Categories (
        user_category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Budgets (
        budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Expenses (
        expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        receipt_image TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Notifications (
        notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT DEFAULT CURRENT_TIMESTAMP,
        read_status INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Feedback (
        feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
      )
    ''');

    await db.execute('''
      INSERT INTO Categories (category_name) VALUES
      ('Groceries'),
      ('Utilities'),
      ('Rent'),
      ('Transportation'),
      ('Dining Out'),
      ('Entertainment'),
      ('Healthcare'),
      ('Insurance'),
      ('Savings'),
      ('Investments'),
      ('Education'),
      ('Clothing'),
      ('Personal Care'),
      ('Travel'),
      ('Gifts'),
      ('Charity'),
      ('Subscriptions'),
      ('Miscellaneous');
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE Transactions (
          transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          transaction_type TEXT NOT NULL,
          date TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES Users (user_id)
        )
      ''');
    }
  }

  // CRUD Operations

  // Expenses
  Future<void> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.insert('Expenses', expense, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getExpenses(int userId) async {
    final db = await database;
    return await db.query('Expenses', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getAllOfflineExpenses() async {
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

  // User Settings
  Future<void> insertSetting(Map<String, dynamic> setting) async {
    final db = await database;
    await db.insert('User_Settings', setting, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getSetting(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> settings = await db.query('User_Settings', where: 'user_id = ?', whereArgs: [userId]);
    return settings.isNotEmpty ? settings.first : null;
  }

  // Budgets
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

  // User Categories
  Future<void> insertUserCategory(Map<String, dynamic> userCategory) async {
    final db = await database;
    await db.insert('User_Categories', userCategory, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserCategories(int userId) async {
    final db = await database;
    return await db.query('User_Categories', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('Categories');
  }

  Future<void> insertCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var category in categories) {
        await txn.insert('Categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> clearCategories() async {
    final db = await database;
    await db.delete('Categories');
  }

  // Transactions
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    await db.insert('Transactions', transaction, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await database;
    return await db.query('Transactions', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> deleteTransaction(int transactionId) async {
    final db = await database;
    await db.delete('Transactions', where: 'transaction_id = ?', whereArgs:      [transactionId],
    );
  }

  // Delete Operations

  Future<void> deleteExpense(int expenseId) async {
    final db = await database;
    await db.delete('Expenses', where: 'expense_id = ?', whereArgs: [expenseId]);
  }

  Future<void> deleteBudget(int budgetId) async {
    final db = await database;
    await db.delete('Budgets', where: 'budget_id = ?', whereArgs: [budgetId]);
  }

  Future<void> deleteUserCategory(int userCategoryId) async {
    final db = await database;
    await db.delete('User_Categories', where: 'user_category_id = ?', whereArgs: [userCategoryId]);
  }

  // Sync Operations

  Future<List<Map<String, dynamic>>> getUnsyncedExpenses() async {
    final db = await database;
    return await db.query('Expenses', where: 'synced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, dynamic>>> getAllOfflineBudgets() async {
    final db = await database;
    return await db.query('Budgets', where: 'synced = ?', whereArgs: [0]);
  }

  // Additional Helper Methods

  Future<void> clearAndInsertCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('Categories');
      for (var category in categories) {
        await txn.insert('Categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('Categories');
  }
}