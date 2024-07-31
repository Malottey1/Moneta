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
  bool isLoading = true;

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
            icon: Icon(Icons.more_vert, color: Colors.black),
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
                  onChanged: (value) {
                    // Implement search logic
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Active'),
                  _buildFilterChip('Inactive'),
                ],
              ),
              SizedBox(height: 16.0),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final budget = category['budget'] ?? 1; // Avoid division by zero
                          final spent = category['total_spent'] ?? 0;
                          final spentPercentage = (spent / budget) * 100;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailsScreen(
                                    category: category['category_name'],
                                    budget: 'GHS ${category['budget']}',
                                    spent: 'GHS ${category['total_spent']}',
                                    spentPercentage: spentPercentage,
                                    transactions: [], // Fetch and pass transactions related to the category
                                  ),
                                ),
                              );
                            },
                            child: CategoryItem(
                              category: category['category_name'],
                              amount: 'GHS ${category['total_amount']} from ${category['expense_count']} expenses',
                              total: 'GHS ${category['total_amount']}',
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

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        // Implement filter logic
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.teal,
      checkmarkColor: Colors.white,
      selected: label == 'All', // Default selected filter chip
      labelStyle: TextStyle(
        fontFamily: 'SpaceGrotesk',
        color: label == 'All' ? Colors.white : Colors.black,
      ),
    );
  }
}