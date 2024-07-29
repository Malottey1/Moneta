import 'package:flutter/material.dart';
import '../widgets/category_item.dart';  // Ensure the correct relative path

class CategoriesScreen extends StatelessWidget {
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
      body: Padding(
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
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Active'),
                _buildFilterChip('Hidden'),
                _buildFilterChip('Inactive'),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  CategoryItem(
                    category: 'Home',
                    amount: '\$2,000.00 from 8 expenses',
                    total: '\$6,000',
                  ),
                  CategoryItem(
                    category: 'Utilities',
                    amount: '\$1,500.00 from 3 expenses',
                    total: '\$4,500',
                  ),
                  CategoryItem(
                    category: 'Groceries',
                    amount: '\$1,500.00 from 5 expenses',
                    total: '\$4,500',
                  ),
                  CategoryItem(
                    category: 'Restaurants',
                    amount: '\$1,500.00 from 5 expenses',
                    total: '\$4,500',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () {
          // Implement add category logic
        },
        icon: Icon(Icons.add),
        label: Text(
          'Add a category',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
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