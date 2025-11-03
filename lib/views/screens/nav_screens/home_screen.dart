import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app_new/provider/navigation_provider.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/category_item_widget.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/new_products_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Trigger navigation to Store tab với search query
      ref
          .read(navigationProvider.notifier)
          .navigateToStoreWithSearch(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(
              searchController: _searchController,
              onSearchSubmitted: _handleSearchSubmitted,
            ),
            BannerWidget(),
            CategoryItemWidget(),
            NewProductsWidget(),
          ],
        ),
      ),
    );
  }
}
