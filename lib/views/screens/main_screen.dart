import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app_new/provider/navigation_provider.dart';
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/account_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/cart_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/category_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/home_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/store_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final int? initialIndex;

  const MainScreen({super.key, this.initialIndex});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _indexPage;
  String? _storeSearchQuery;

  @override
  void initState() {
    super.initState();
    _indexPage = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Watch để trigger rebuild khi navigation state thay đổi
    final navigationState = ref.watch(navigationProvider);

    // Nếu có request navigate to store và chưa ở tab stores
    if (navigationState.shouldNavigateToStore && _indexPage != 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _indexPage = 2;
            _storeSearchQuery = navigationState.searchQuery;
          });
          // Reset sau khi đã switch
          Future.microtask(() {
            if (mounted) {
              ref.read(navigationProvider.notifier).resetNavigation();
            }
          });
        }
      });
    }

    // Watch userProvider để force rebuild AccountScreen khi user thay đổi
    final user = ref.watch(userProvider);

    // Rebuild StoreScreen khi search query thay đổi bằng key
    // Rebuild AccountScreen khi user thay đổi bằng key
    final List<Widget> _page = [
      HomeScreen(), // index 0: Home
      CategoryScreen(), // index 1: Category
      StoreScreen(
        key: ValueKey(_storeSearchQuery ?? 'no_search'),
        initialSearchQuery: _storeSearchQuery,
      ), // index 2: Stores
      CartScreen(), // index 3: Cart
      AccountScreen(
        key: ValueKey(
          user?.id ?? 'no_user',
        ), // Force rebuild khi user.id thay đổi
      ), // index 4: User
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indexPage,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(75, 0, 0, 0),
        onTap: (value) => {
          setState(() {
            _indexPage = value;
            // Reset search query khi switch tab khác
            if (value != 2) {
              _storeSearchQuery = null;
            }
          }),
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
      body: _page[_indexPage],
    );
  }
}
