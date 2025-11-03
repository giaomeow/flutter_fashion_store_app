import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app_new/controllers/subcategory_controller.dart';
import 'package:mac_store_app_new/controllers/product_controller.dart';
import 'package:mac_store_app_new/models/category.dart';
import 'package:mac_store_app_new/models/subcategory.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/provider/navigation_provider.dart';
import 'package:mac_store_app_new/views/detail/screens/widgets/inner_banner_widget.dart';
import 'package:mac_store_app_new/views/detail/screens/widgets/inner_header_widget.dart';
import 'package:mac_store_app_new/views/detail/screens/product_detail_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/product_item_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app_new/views/detail/screens/widgets/subcategory_title_widget.dart';

class InnerCategoryContentWidget extends ConsumerStatefulWidget {
  final Category category;
  final String? initialSubcategoryId;
  const InnerCategoryContentWidget({
    super.key,
    required this.category,
    this.initialSubcategoryId,
  });
  @override
  ConsumerState<InnerCategoryContentWidget> createState() =>
      _InnerCategoryContentState();
}

class _InnerCategoryContentState
    extends ConsumerState<InnerCategoryContentWidget> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<SubCategory>> futureSubCategories;
  late Future<List<Product>> futureProducts;
  final SubcategoryController _subcategoryController = SubcategoryController();
  final ProductController _productController = ProductController();

  // Track subcategory đang được chọn (null = hiển thị tất cả products theo category)
  String? _selectedSubcategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Trigger navigation provider trước
      ref
          .read(navigationProvider.notifier)
          .navigateToStoreWithSearch(query.trim());
      // Sau đó pop về MainScreen - MainScreen sẽ tự động detect và switch tab
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();
    futureSubCategories = _subcategoryController.getSubcategoriesByCategoryId(
      widget.category.id, // Sử dụng category.id thay vì category.name
    );
    // Nếu có initialSubcategoryId, load products theo subcategoryId
    if (widget.initialSubcategoryId != null &&
        widget.initialSubcategoryId!.isNotEmpty) {
      _selectedSubcategoryId = widget.initialSubcategoryId;
      futureProducts = _productController.getProductsBySubcategoryId(
        widget.initialSubcategoryId!,
        categoryId: widget.category.id,
      );
    } else {
      // Load products theo categoryId ban đầu
      futureProducts = _productController.getProductsByCategoryId(
        widget.category.id,
      );
    }
  }

  // Load products theo categoryId hoặc subcategoryId
  void _loadProducts({String? subcategoryId}) {
    setState(() {
      _selectedSubcategoryId = subcategoryId;
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        // Load products theo subcategoryId
        futureProducts = _productController.getProductsBySubcategoryId(
          subcategoryId,
          categoryId: widget.category.id,
        );
      } else {
        // Load products theo categoryId
        futureProducts = _productController.getProductsByCategoryId(
          widget.category.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.18,
        ),
        child: InnerHeaderWidget(
          searchController: _searchController,
          onSearchSubmitted: _handleSearchSubmitted,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InnerBannerWidget(image: widget.category.banner),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Shop by Category',
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FutureBuilder<List<SubCategory>>(
              future: futureSubCategories,
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
                  return const Center(child: Text(''));
                }

                // 4. Có data - hiển thị grid
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<SubCategory> subCategories = snapshot.data!;

                  // Đảm bảo selectedSubcategoryId được set sau khi subcategories load xong
                  if (widget.initialSubcategoryId != null &&
                      widget.initialSubcategoryId!.isNotEmpty &&
                      _selectedSubcategoryId != widget.initialSubcategoryId) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedSubcategoryId = widget.initialSubcategoryId;
                        });
                      }
                    });
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio:
                          1.0, // Tỷ lệ width/height = 1 để item vuông, không bị dài
                    ),
                    itemCount: subCategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = subCategories[index];
                      return SubcategoryTitleWidget(
                        title: subCategory.subCategoryName,
                        image: subCategory.image,
                        isActive: _selectedSubcategoryId == subCategory.id,
                        onTap: () {
                          // Reload products theo subcategoryId khi click
                          _loadProducts(subcategoryId: subCategory.id);
                        },
                      );
                    },
                  );
                }

                // Fallback return
                return const Center(child: Text('No data'));
              },
            ),
            // Danh sách sản phẩm
            FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('No products found')),
                  );
                }
                final products = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductItemWidget(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
