import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneta/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:moneta/providers/user_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final String id;
  final String category;
  final String description;
  final String amount;
  final String date;

  EditExpenseScreen({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  XFile? receiptImage;
  List<String> categories = ['Select a category'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.amount);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedDate = DateTime.parse(widget.date);
    _selectedCategory = widget.category;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final fetchedCategories = await ApiService().getCategories();
      setState(() {
        categories.addAll(fetchedCategories);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch categories. Please try again.')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        receiptImage = pickedImage;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateExpense() async {
  setState(() {
    _isLoading = true;
  });

  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId.toString(); // Ensure user ID is a string

  // Extract only numeric part from the amount string
  final amountString = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');

  try {
    print('Updating expense with the following details:');
    print('Expense ID: ${widget.id}');
    print('User ID: $userId');
    print('Category: ${categories.indexOf(_selectedCategory)}');
    print('Amount: $amountString');
    print('Date: ${_selectedDate.toIso8601String()}');
    print('Description: ${_descriptionController.text}');
    print('Receipt Image Path: ${receiptImage?.path}');

    final response = await ApiService().editExpense(
      widget.id,
      userId,
      categories.indexOf(_selectedCategory).toString(), // Convert index to string
      double.parse(amountString),
      _selectedDate.toIso8601String(),
      _descriptionController.text,
      receiptImage != null ? File(receiptImage!.path) : null,
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense updated successfully')),
      );
      Navigator.pop(context, true); // Pass true to indicate the expense was updated
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  } catch (e) {
    print('Exception occurred while updating expense: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update expense. Please try again.')),
    );
  }

  setState(() {
    _isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Expense',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Amount', _amountController),
            SizedBox(height: 16.0),
            _buildDropdownField('Select a category', _selectedCategory, categories),
            SizedBox(height: 16.0),
            _buildDateField(_selectedDate),
            SizedBox(height: 16.0),
            _buildTextField('Description', _descriptionController),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updateExpense,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.teal),
                    ),
                  ),
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  icon: Icon(Icons.camera_alt, color: Colors.teal),
                  label: Text(
                    'Attach Receipt',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
            if (receiptImage != null) ...[
              SizedBox(height: 16.0),
              Center(
                child: Image.file(
                  File(receiptImage!.path),
                  height: 200,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
        controller: controller,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
        ),
        maxLength: hint == 'Description' ? 23 : null,
      ),
    );
  }

  Widget _buildDropdownField(String hint, String selectedValue, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue.isEmpty || !items.contains(selectedValue) ? null : selectedValue,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildDateField(DateTime date) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${date.toLocal()}".split(' ')[0],
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }
}