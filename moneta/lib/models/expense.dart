// models/expense.dart
class Expense {
  final int expenseId;
  final int userId;
  final int categoryId;
  final double amount;
  final String date;
  final String description;
  final String receiptImage;

  Expense({
    required this.expenseId,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.description,
    required this.receiptImage,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expense_id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: json['amount'],
      date: json['date'],
      description: json['description'],
      receiptImage: json['receipt_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'date': date,
      'description': description,
      'receipt_image': receiptImage,
    };
  }
}