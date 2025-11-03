import 'package:flutter/material.dart';
import 'package:mac_store_app_new/controllers/product_controller.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/views/detail/screens/product_detail_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/product_item_widget.dart';

class SimilarProductsWidget extends StatefulWidget {
  final String subcategoryId;
  final String categoryId;
  final String excludeProductId;

  const SimilarProductsWidget({
    super.key,
    required this.subcategoryId,
    required this.categoryId,
    required this.excludeProductId,
  });

  @override
  State<SimilarProductsWidget> createState() => _SimilarProductsWidgetState();
}

class _SimilarProductsWidgetState extends State<SimilarProductsWidget> {
  late Future<List<Product>> futureProducts;
  final ProductController _productController = ProductController();

  @override
  void initState() {
    super.initState();
    futureProducts = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    List<Product> allProducts = [];
    const int minProducts = 6;

    // 1. Load products từ subcategory trước
    if (widget.subcategoryId.isNotEmpty && widget.categoryId.isNotEmpty) {
      try {
        final subcategoryProducts = await _productController
            .getProductsBySubcategoryId(
              widget.subcategoryId,
              categoryId: widget.categoryId,
            );
        // Lọc bỏ sản phẩm hiện tại
        final filteredSubcategoryProducts = subcategoryProducts
            .where((p) => p.id != widget.excludeProductId)
            .toList();
        allProducts.addAll(filteredSubcategoryProducts);
      } catch (e) {
        // Ignore error and continue
      }
    }

    // 2. Nếu chưa đủ 6 sản phẩm, load thêm từ category
    if (allProducts.length < minProducts && widget.categoryId.isNotEmpty) {
      try {
        final categoryProducts = await _productController
            .getProductsByCategoryId(widget.categoryId);
        // Lọc bỏ sản phẩm hiện tại và các sản phẩm đã có từ subcategory
        final existingIds = allProducts.map((p) => p.id).toSet();
        final filteredCategoryProducts = categoryProducts
            .where(
              (p) =>
                  p.id != widget.excludeProductId &&
                  !existingIds.contains(p.id),
            )
            .toList();

        // Chỉ lấy đủ số lượng cần thiết để có tổng >= 6
        final neededCount = minProducts - allProducts.length;
        allProducts.addAll(filteredCategoryProducts.take(neededCount));
      } catch (e) {
        // Ignore error and continue
      }
    }

    // 3. Giới hạn tối đa 6 sản phẩm
    return allProducts.take(minProducts).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No similar products found'));
        }

        final products = snapshot.data!;

        if (products.isEmpty) {
          return const Center(child: Text('No similar products found'));
        }

        // Dùng GridView giống NewProductsWidget
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
    );
  }
}
