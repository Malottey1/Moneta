import 'package:flutter/material.dart';
import 'package:moneta/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:moneta/providers/user_provider.dart';

class EditBudgetScreen extends StatefulWidget {
  final String id;
  final String category;
  final String allocated;
  final String startDate;
  final String endDate;

  EditBudgetScreen({
    required this.id,
    required this.category,
    required this.allocated,
    required this.startDate,
    required this.endDate,
  });

  @override
  _EditBudgetScreenState createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late TextEditingController _allocatedController;
  late String _selectedCategory;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _allocatedController = TextEditingController(text: widget.allocated);
    _selectedCategory = widget.category;
    _selectedStartDate = DateTime.parse(widget.startDate);
    _selectedEndDate = DateTime.parse(widget.endDate);
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService().getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch categories. Please try again.')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != (isStartDate ? _selectedStartDate : _selectedEndDate)) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  void _updateBudget() async {
    setState(() {
      _isLoading = true;
    });

    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final categoryId = _categories.indexOf(_selectedCategory) + 1; // Assuming categories are 1-based indexed

    print('🐛 Updating budget with id: ${widget.id}, category: $_selectedCategory, allocated: ${_allocatedController.text}, start_date: ${_selectedStartDate.toIso8601String()}, end_date: ${_selectedEndDate.toIso8601String()}');

    try {
      final response = await ApiService().updateBudget(
        widget.id,
        userId,
        categoryId,
        double.parse(_allocatedController.text),
        _selectedStartDate.toIso8601String(),
        _selectedEndDate.toIso8601String(),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      print('⛔ Exception occurred while updating budget: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update budget. Please try again.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _deleteBudget() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().deleteBudget(widget.id);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget deleted successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate the budget was deleted
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      print('⛔ Exception occurred while deleting budget: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete budget. Please try again.')),
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Budget',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: _deleteBudget,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownField('Category', _selectedCategory),
                  SizedBox(height: 16.0),
                  _buildTextField('Allocated', _allocatedController),
                  SizedBox(height: 16.0),
                  _buildDateField('Start date', _selectedStartDate, true),
                  SizedBox(height: 16.0),
                  _buildDateField('End date', _selectedEndDate, false),
                  SizedBox(height: 32.0),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _updateBudget,
                      child: Text(
                        'Update Budget',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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
          hintStyle: TextStyle(color: Colors.grey),
        ),
        controller: controller,
      ),
    );
  }

  Widget _buildDropdownField(String hint, String currentValue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        items: _categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue!;          });
        },
      ),
    );
  }

  Widget _buildDateField(String hint, DateTime currentDate, bool isStartDate) {
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
            "${currentDate.toLocal()}".split(' ')[0],
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey),
            onPressed: () => _selectDate(context, isStartDate),
          ),
        ],
      ),
    );
  }
}