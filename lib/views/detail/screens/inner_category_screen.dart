import 'package:flutter/material.dart';
import 'package:mac_store_app_new/models/category.dart';
import 'package:mac_store_app_new/views/detail/screens/widgets/inner_category_content_widget.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/account_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/cart_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/category_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/store_screen.dart';

class InnerCategoryScreen extends StatefulWidget {
  final Category category;
  final String? initialSubcategoryId;
  const InnerCategoryScreen({
    super.key,
    required this.category,
    this.initialSubcategoryId,
  });
  @override
  State<InnerCategoryScreen> createState() => _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryScreen> {
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> page = [
      InnerCategoryContentWidget(
        category: widget.category,
        initialSubcategoryId: widget.initialSubcategoryId,
      ), // index 0: Home
      CategoryScreen(
        showBottomNavBar: false,
      ), // index 1: Category - Không hiển thị bottomNavBar vì đã có trong InnerCategoryScreen
      const StoreScreen(), // index 2: Stores
      const CartScreen(), // index 3: Cart
      AccountScreen(), // index 4: User
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: indexPage,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(75, 0, 0, 0),
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Stores'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
      body: page[indexPage],
    );
  }
}
