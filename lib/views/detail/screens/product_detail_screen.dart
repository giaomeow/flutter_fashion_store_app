import 'package:flutter/material.dart';
import 'package:mac_store_app_new/controllers/product_controller.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/views/detail/screens/widgets/product_detail_content_widget.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/account_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/cart_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/category_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/store_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> futureProduct;
  final ProductController _productController = ProductController();
  int indexPage = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    futureProduct = _productController.getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: futureProduct,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Stores',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Stores',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            ),
          );
        }

        // Success state
        if (!snapshot.hasData) {
          return Scaffold(
            body: const SafeArea(
              child: Center(child: Text('Product not found')),
            ),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Stores',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
              ],
            ),
          );
        }

        final product = snapshot.data!;
        final List<Widget> page = [
          ProductDetailContentWidget(product: product), // index 0: Home
          const CategoryScreen(
            showBottomNavBar: false,
          ), // index 1: Category - Không hiển thị BottomNavigationBar vì đã có trong ProductDetailScreen
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
          body: SafeArea(child: page[indexPage]),
        );
      },
    );
  }
}
