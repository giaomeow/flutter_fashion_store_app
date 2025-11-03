import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app_new/controllers/category_controller.dart';
import 'package:mac_store_app_new/controllers/subcategory_controller.dart';
import 'package:mac_store_app_new/models/category.dart';
import 'package:mac_store_app_new/models/subcategory.dart';
import 'package:mac_store_app_new/provider/navigation_provider.dart';
import 'package:mac_store_app_new/views/detail/screens/inner_category_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/header_widget.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final bool showBottomNavBar;
  const CategoryScreen({super.key, this.showBottomNavBar = true});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  late Future<List<Category>> futureCategories;
  Category? _selectedCategory;
  List<SubCategory> _subCategories = [];
  final CategoryController _categoryController = CategoryController();
  final SubcategoryController _subcategoryController = SubcategoryController();
  final TextEditingController _searchController = TextEditingController();

  // Kiểm tra xem CategoryScreen có được push từ MainScreen không
  bool _isPushedFromMainScreen(BuildContext context) {
    try {
      final navigator = Navigator.of(context, rootNavigator: false);
      final canPop = navigator.canPop();
      return canPop == true; // Đảm bảo luôn trả về bool, không phải null
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Hàm load categories
  void _loadCategories() {
    futureCategories = _categoryController.loadCategories();
    futureCategories
        .then((categories) {
          if (categories.isNotEmpty && mounted) {
            setState(() {
              _selectedCategory = categories[0];
            });
          }
        })
        .catchError((error) {
          print('Error loading categories: $error');
        });
  }

  // Hàm load subcategories
  Future<void> _loadSubcategories(String categoryId) async {
    final subCategories = await _subcategoryController
        .getSubcategoriesByCategoryId(categoryId);
    setState(() {
      _subCategories = subCategories;
    });
  }

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.18,
        ),
        child: HeaderWidget(
          searchController: _searchController,
          onSearchSubmitted: _handleSearchSubmitted,
        ),
      ),
      bottomNavigationBar:
          (widget.showBottomNavBar == true) &&
              (_isPushedFromMainScreen(context) == true)
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex:
                  1, // Category tab index (Home=0, Category=1, Stores=2, Cart=3, User=4)
              selectedItemColor: Colors.black,
              unselectedItemColor: const Color.fromARGB(75, 0, 0, 0),
              onTap: (value) {
                // Nếu click vào tab khác, pop về MainScreen
                Navigator.of(context).pop();
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
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Display categories
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade200,
              child: FutureBuilder(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final categories = snapshot.data!;

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _loadSubcategories(category.id);
                        },
                        title: Text(
                          category.name,
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _selectedCategory == category
                                ? Colors.black
                                : Colors.black54,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Right side - display categories detail
          Expanded(
            flex: 5,
            child: _selectedCategory != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên danh mục
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _selectedCategory!.name,
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.7,
                            ),
                          ),
                        ),
                        // Banner danh mục - Clickable để xem products
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InnerCategoryScreen(
                                  category: _selectedCategory!,
                                ),
                              ),
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 2048 / 683,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    _selectedCategory!.banner,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Danh sách subcategories
                        _subCategories.isNotEmpty
                            ? GridView.builder(
                                shrinkWrap: true,
                                itemCount: _subCategories.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 8,
                                    ),
                                itemBuilder: (context, index) {
                                  final subCategory = _subCategories[index];
                                  return InkWell(
                                    onTap: () {
                                      // Navigate đến InnerCategoryScreen với subcategory được chọn
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InnerCategoryScreen(
                                                category: _selectedCategory!,
                                                initialSubcategoryId:
                                                    subCategory.id,
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Image.network(
                                              subCategory.image,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(height: 8),
                                            Center(
                                              child: Text(
                                                subCategory.subCategoryName,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No subcategories found'),
                              ),
                      ],
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
