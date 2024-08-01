import 'package:flutter/material.dart';
import 'package:moneta/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:moneta/providers/user_provider.dart';
import '../widgets/category_item.dart';
import 'category_details.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  List<dynamic> filteredCategories = [];
  bool isLoading = true;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    try {
      final fetchedCategories = await ApiService().getUserCategories(userId);
      setState(() {
        categories = fetchedCategories;
        filteredCategories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories. Please try again.')),
      );
    }
  }

  void _filterCategories(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'all') {
        filteredCategories = categories;
      } else if (filter == 'active') {
        filteredCategories = categories.where((category) => category['expense_count'] > 0).toList();
      } else if (filter == 'inactive') {
        filteredCategories = categories.where((category) => category['expense_count'] == 0).toList();
      }
    });
  }

  void _searchCategories(String query) {
    setState(() {
      filteredCategories = categories.where((category) {
        final categoryName = category['category_name'].toLowerCase();
        final searchLower = query.toLowerCase();
        return categoryName.contains(searchLower);
      }).toList();
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
          'Categories',
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
            icon: Icon(Icons.more_vert, color: Colors.grey[200]),
            onPressed: () {
              // Implement your logic here
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchCategories,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search categories',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  onChanged: _searchCategories,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterChip('All', 'all'),
                  _buildFilterChip('Active', 'active'),
                  _buildFilterChip('Inactive', 'inactive'),
                ],
              ),
              SizedBox(height: 16.0),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final totalAmount = num.tryParse(category['total_amount']?.toString() ?? '0') ?? 0;
                          final expenseCount = num.tryParse(category['expense_count']?.toString() ?? '0') ?? 0;
                          final spentPercentage = totalAmount != 0 ? (expenseCount / totalAmount) * 100 : 0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailsScreen(
                                    category: category['category_name'],
                                    budget: 'GHS $totalAmount',
                                    spent: 'GHS $expenseCount',
                                    spentPercentage: 1,
                                    transactions: [], // Fetch and pass transactions related to the category
                                  ),
                                ),
                              );
                            },
                            child: CategoryItem(
                              category: category['category_name'],
                              amount: 'GHS $totalAmount from $expenseCount expenses',
                              total: 'GHS $totalAmount',
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        _filterCategories(filter);
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.teal,
      checkmarkColor: Colors.white,
      selected: selectedFilter == filter, // Check if the current filter is selected
      labelStyle: TextStyle(
        fontFamily: 'SpaceGrotesk',
        color: selectedFilter == filter ? Colors.white : Colors.black,
      ),
    );
  }
}