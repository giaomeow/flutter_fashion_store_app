import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/controllers/cart_controller.dart';
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:mac_store_app_new/views/detail/screens/widgets/similar_products_widget.dart';

class ProductDetailContentWidget extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailContentWidget({super.key, required this.product});

  @override
  ConsumerState<ProductDetailContentWidget> createState() =>
      _ProductDetailContentWidgetState();
}

class _ProductDetailContentWidgetState
    extends ConsumerState<ProductDetailContentWidget> {
  int _currentImageIndex = 0;
  final CartController _cartController = CartController();
  bool _isAddingToCart = false;

  // Format giá tiền Việt Nam
  String _formatPrice(String priceString) {
    try {
      final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.parse(cleanPrice);
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '₫',
        decimalDigits: 0,
      );
      return formatter.format(price);
    } catch (e) {
      return priceString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images.isNotEmpty
        ? product.images
        : ['https://via.placeholder.com/400'];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Product Image Carousel
          Stack(
            children: [
              CarouselSlider.builder(
                itemCount: images.length,
                itemBuilder: (context, index, realIndex) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 100),
                      );
                    },
                  );
                },
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  aspectRatio: 1706 / 2560,
                  autoPlay: images.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.easeInOut,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
              ),
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              // Dots indicator
              if (images.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.brown.shade700
                              : Colors.brown.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Product Details Section
          Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: GoogleFonts.quicksand(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatPrice(product.price),
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh,',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      color: Colors.grey.shade300,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isAddingToCart
                          ? null
                          : () async {
                              setState(() {
                                _isAddingToCart = true;
                              });

                              // Lấy userId từ userProvider
                              final user = ref.read(userProvider);
                              print('Debug - User from provider: ${user?.id}');
                              print('Debug - User object: $user');

                              // Nếu user không có trong provider, thử lấy từ SharedPreferences
                              String? userId = user?.id;
                              if (userId == null || userId.isEmpty) {
                                try {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final userJson = prefs.getString('user');
                                  if (userJson != null) {
                                    final userData = json.decode(userJson);
                                    userId =
                                        (userData['id'] ??
                                                userData['_id'] ??
                                                '')
                                            .toString();
                                    print(
                                      'Debug - User ID from SharedPreferences: $userId',
                                    );
                                    // Cập nhật lại provider từ SharedPreferences
                                    ref
                                        .read(userProvider.notifier)
                                        .setUser(userJson);
                                  }
                                } catch (e) {
                                  print(
                                    'Error reading user from SharedPreferences: $e',
                                  );
                                }
                              }

                              if (userId == null || userId.isEmpty) {
                                setState(() {
                                  _isAddingToCart = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please log in to add product to cart',
                                    ),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              _cartController.addToCart(
                                context: context,
                                userId: userId,
                                productId: product.id,
                                quantity: 1,
                                onSuccess: () {
                                  setState(() {
                                    _isAddingToCart = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to cart'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                onError: (error) {
                                  setState(() {
                                    _isAddingToCart = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isAddingToCart
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              'Add to cart',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Similar Products Section - Tách ra khỏi background đen
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                Text(
                  'Similar Products',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                SimilarProductsWidget(
                  subcategoryId: product.subcategoryId,
                  categoryId: product.categoryId,
                  excludeProductId: product.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
