import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app_new/controllers/category_controller.dart';
import 'package:mac_store_app_new/models/category.dart';
import 'package:mac_store_app_new/views/detail/screens/inner_category_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/category_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/reusable_text_widget.dart';

class CategoryItemWidget extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;
  const CategoryItemWidget({super.key, this.onRefreshNeeded});

  @override
  State<CategoryItemWidget> createState() => CategoryItemWidgetState();
}

class CategoryItemWidgetState extends State<CategoryItemWidget> {
  late Future<List<Category>> futureCategories;
  final CategoryController _categoryController = CategoryController();
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Hàm load categories
  void _loadCategories() {
    futureCategories = _categoryController.loadCategories(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ReusableTextWidget(
            title: 'Categories',
            subtitle: 'See all',
            titleStyle: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            onSubtitlePressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => (CategoryScreen())),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Category>>(
          future: futureCategories,
          builder: (context, snapshot) {
            // 1. Đang loading - hiển thị spinner
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // 2. Có lỗi - hiển thị error
            if (snapshot.hasError) {
              return SizedBox(
                height: 60,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            // 3. Không có data - hiển thị empty
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 60,
                child: Center(child: Text('No categories to display')),
              );
            }

            // 4. Có data - hiển thị list
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Category> categories = snapshot.data!;
              return SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InnerCategoryScreen(category: category),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              category.image,
                              height: 45,
                              width: 45,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            // Fallback return
            return const Center(child: Text('No data'));
          },
        ),
      ],
    );
  }
}
