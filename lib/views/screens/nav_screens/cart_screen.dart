import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_store_app_new/controllers/cart_controller.dart';
import 'package:mac_store_app_new/controllers/product_controller.dart';
import 'package:mac_store_app_new/models/cart.dart';
import 'package:mac_store_app_new/models/cart_item.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:mac_store_app_new/views/screens/authetication_screens/login_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final CartController _cartController = CartController();
  final ProductController _productController = ProductController();
  late Future<Cart?> futureCart;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    // Lấy userId từ userProvider hoặc SharedPreferences
    final user = ref.read(userProvider);
    if (user != null && user.id.isNotEmpty) {
      setState(() {
        userId = user.id;
        futureCart = _cartController.getCart(user.id);
      });
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString('user');
        if (userJson != null) {
          final userData = json.decode(userJson);
          final id = (userData['id'] ?? userData['_id'] ?? '').toString();
          if (id.isNotEmpty) {
            setState(() {
              userId = id;
              futureCart = _cartController.getCart(id);
            });
          }
        }
      } catch (e) {
        print('Error loading userId: $e');
      }
    }
  }

  Future<void> _refreshCart() async {
    if (userId != null && userId!.isNotEmpty) {
      setState(() {
        futureCart = _cartController.getCart(userId!);
      });
    }
  }

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

  // Tính tổng giá trị giỏ hàng (fallback nếu BE không trả về totalPrice)
  double _calculateTotal(List<CartItemWithProduct> items) {
    double total = 0;
    for (var item in items) {
      if (item.product != null) {
        try {
          final price = double.parse(
            item.product!.price.replaceAll(RegExp(r'[^\d.]'), ''),
          );
          total += price * item.cartItem.quantity;
        } catch (e) {
          // Ignore parse error
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Your Cart',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please log in to add items to your cart',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Your Cart',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Cart?>(
        future: futureCart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cart = snapshot.data;

          // Debug: In ra thông tin cart để kiểm tra
          if (cart != null) {
            print('Cart loaded - Total items: ${cart.products.length}');
            for (var item in cart.products) {
              print(
                'Cart item - id: ${item.id}, productId: ${item.productId}, quantity: ${item.quantity}',
              );
            }
          }

          if (cart == null || cart.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Load product details cho mỗi cart item
          return FutureBuilder<List<CartItemWithProduct>>(
            future: _loadCartItemsWithProducts(cart.products),
            builder: (context, productsSnapshot) {
              if (productsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = productsSnapshot.data ?? [];
              // Dùng totalPrice từ BE, nếu không có thì tự tính
              final total = cart.totalPrice ?? _calculateTotal(items);

              return Column(
                children: [
                  // Cart items list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshCart,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CartItemWidget(
                            item: item,
                            onQuantityChanged: (newQuantity) {
                              print(
                                'Update quantity - cartItemId: ${item.cartItem.id}, newQuantity: $newQuantity, userId: $userId',
                              );
                              if (item.cartItem.id != null &&
                                  item.cartItem.id!.isNotEmpty &&
                                  userId != null &&
                                  userId!.isNotEmpty) {
                                _cartController.updateCartItem(
                                  context: context,
                                  userId: userId!,
                                  cartItemId: item.cartItem.id!,
                                  quantity: newQuantity,
                                  onSuccess: () {
                                    _refreshCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Quantity updated'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  onError: (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $error'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                print(
                                  'Error: cartItemId or userId is null/empty - cartItemId: ${item.cartItem.id}, userId: $userId',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error: Required information not found',
                                    ),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            onDelete: () {
                              print(
                                'Delete item - cartItemId: ${item.cartItem.id}, userId: $userId',
                              );
                              if (item.cartItem.id != null &&
                                  item.cartItem.id!.isNotEmpty &&
                                  userId != null &&
                                  userId!.isNotEmpty) {
                                _cartController.deleteCartItem(
                                  context: context,
                                  userId: userId!,
                                  cartItemId: item.cartItem.id!,
                                  onSuccess: () {
                                    _refreshCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Product removed'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  onError: (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $error'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                print(
                                  'Error: cartItemId or userId is null/empty - cartItemId: ${item.cartItem.id}, userId: $userId',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error: Required information not found',
                                    ),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  // Summary section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Total price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _formatPrice(total.toString()),
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Payment button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: cart.products.isEmpty
                                ? null
                                : () {
                                    // Navigate to checkout screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CheckoutScreen(cart: cart),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Payment',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<List<CartItemWithProduct>> _loadCartItemsWithProducts(
    List<CartItem> cartItems,
  ) async {
    List<CartItemWithProduct> items = [];
    for (var cartItem in cartItems) {
      try {
        print(
          'Loading cart item - id: ${cartItem.id}, productId: ${cartItem.productId}, quantity: ${cartItem.quantity}',
        );
        // Nếu BE đã populate product (trong productId hoặc product field), dùng luôn
        if (cartItem.product != null) {
          try {
            items.add(
              CartItemWithProduct(
                cartItem: cartItem,
                product: Product.fromMap(cartItem.product!),
              ),
            );
          } catch (e) {
            print('Error parsing product from cartItem: $e');
            // Nếu parse lỗi, thử fetch từ API
            if (cartItem.productId.isNotEmpty) {
              final product = await _productController.getProductById(
                cartItem.productId,
              );
              items.add(
                CartItemWithProduct(cartItem: cartItem, product: product),
              );
            }
          }
        } else if (cartItem.productId.isNotEmpty) {
          // Nếu không có product data, fetch từ API
          final product = await _productController.getProductById(
            cartItem.productId,
          );
          items.add(CartItemWithProduct(cartItem: cartItem, product: product));
        }
      } catch (e) {
        print('Error loading product ${cartItem.productId}: $e');
      }
    }
    return items;
  }
}

// Helper class để kết hợp CartItem với Product
class CartItemWithProduct {
  final CartItem cartItem;
  final Product? product;

  CartItemWithProduct({required this.cartItem, this.product});
}

// Widget cho mỗi cart item
class _CartItemWidget extends StatefulWidget {
  final CartItemWithProduct item;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;

  const _CartItemWidget({
    required this.item,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  State<_CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<_CartItemWidget> {
  late TextEditingController _quantityController;
  late FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.cartItem.quantity.toString(),
    );
    _quantityFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật controller nếu quantity thay đổi từ bên ngoài
    if (oldWidget.item.cartItem.quantity != widget.item.cartItem.quantity &&
        mounted) {
      _quantityController.text = widget.item.cartItem.quantity.toString();
    }
  }

  @override
  void dispose() {
    // Không unfocus trong dispose vì có thể gây lỗi khi widget đã bị deactivate
    // Chỉ dispose các resources
    _quantityFocusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

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

  void _updateQuantity(String value) {
    // Kiểm tra widget còn mounted trước khi xử lý
    if (!mounted) return;

    // Loại bỏ khoảng trắng
    final trimmedValue = value.trim();

    // Nếu rỗng, khôi phục giá trị cũ
    if (trimmedValue.isEmpty) {
      _quantityController.text = widget.item.cartItem.quantity.toString();
      return;
    }

    // Parse thành số nguyên
    final newQuantity = int.tryParse(trimmedValue);

    // Chỉ chấp nhận số nguyên dương (> 0)
    if (newQuantity != null && newQuantity > 0) {
      widget.onQuantityChanged(newQuantity);
    } else {
      // Nếu nhập không hợp lệ (0, số âm, hoặc không phải số), khôi phục giá trị cũ
      if (mounted) {
        _quantityController.text = widget.item.cartItem.quantity.toString();
        // Hiển thị thông báo lỗi (chỉ khi widget còn mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a positive integer greater than 0'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.item.product;
    if (product == null) {
      return const SizedBox.shrink();
    }

    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';
    final totalPrice =
        (double.tryParse(product.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
            0) *
        widget.item.cartItem.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.productName,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Quantity selector
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (mounted && widget.item.cartItem.quantity > 1) {
                          widget.onQuantityChanged(
                            widget.item.cartItem.quantity - 1,
                          );
                          if (mounted) {
                            _quantityController.text =
                                (widget.item.cartItem.quantity - 1).toString();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: widget.item.cartItem.quantity > 1
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 50,
                        height: 26,
                        child: TextField(
                          controller: _quantityController,
                          focusNode: _quantityFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Chỉ cho phép số
                          ],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.grey.shade600,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onSubmitted: _updateQuantity,
                          onEditingComplete: () {
                            // Khi nhấn "Done" trên bàn phím, cập nhật và ẩn bàn phím
                            _quantityFocusNode.unfocus();
                            _updateQuantity(_quantityController.text);
                          },
                          onTapOutside: (event) {
                            // Khi tap ra ngoài, cập nhật số lượng
                            if (mounted) {
                              _updateQuantity(_quantityController.text);
                              _quantityFocusNode.unfocus();
                            }
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          widget.onQuantityChanged(
                            widget.item.cartItem.quantity + 1,
                          );
                          if (mounted) {
                            _quantityController.text =
                                (widget.item.cartItem.quantity + 1).toString();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and delete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 8),
              Text(
                _formatPrice(totalPrice.toString()),
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
