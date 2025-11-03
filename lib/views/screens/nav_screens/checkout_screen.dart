import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_store_app_new/controllers/order_controller.dart';
import 'package:mac_store_app_new/controllers/cart_controller.dart';
import 'package:mac_store_app_new/controllers/product_controller.dart';
import 'package:mac_store_app_new/models/cart.dart';
import 'package:mac_store_app_new/models/cart_item.dart';
import 'package:mac_store_app_new/models/product.dart';
import 'package:mac_store_app_new/models/order.dart';
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/order_confirmation_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Cart cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderController _orderController = OrderController();
  final CartController _cartController = CartController();
  final ProductController _productController = ProductController();

  // Form controllers
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();

  String _paymentMethod = 'cash';
  bool _isCreatingOrder = false;
  bool _saveInfo = false;
  String? userId;
  late Future<Cart?> futureCart;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCart();
  }

  void _loadCart() {
    // Load cart từ API khi init
    final user = ref.read(userProvider);
    if (user != null && user.id.isNotEmpty) {
      setState(() {
        userId = user.id;
        futureCart = _cartController.getCart(user.id);
      });
    } else {
      // Thử load từ SharedPreferences
      _loadUserIdFromPrefs();
    }
  }

  Future<void> _loadUserIdFromPrefs() async {
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

  // Load cart items with products (tương tự CartScreen)
  Future<List<CartItemWithProduct>> _loadCartItemsWithProducts(
    List<CartItem> cartItems,
  ) async {
    List<CartItemWithProduct> items = [];
    for (var cartItem in cartItems) {
      try {
        if (cartItem.product != null) {
          try {
            items.add(
              CartItemWithProduct(
                cartItem: cartItem,
                product: Product.fromMap(cartItem.product!),
              ),
            );
          } catch (e) {
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

  Future<void> _loadUserInfo() async {
    // Ưu tiên load từ SharedPreferences vì đây là source of truth
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        final id = (userData['id'] ?? userData['_id'] ?? '').toString();
        if (id.isNotEmpty) {
          setState(() {
            userId = id;
            // Prefill form với thông tin user từ SharedPreferences
            _fullnameController.text = userData['fullname'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _stateController.text = userData['state'] ?? '';
            _cityController.text = userData['city'] ?? '';
            _localityController.text = userData['locality'] ?? '';
          });
          return; // Đã load xong, return
        }
      }
    } catch (e) {
      print('Error loading user info from SharedPreferences: $e');
    }

    // Fallback: Load từ userProvider nếu SharedPreferences không có
    final user = ref.read(userProvider);
    if (user != null && user.id.isNotEmpty) {
      setState(() {
        userId = user.id;
        // Prefill form với thông tin user từ provider
        _fullnameController.text = user.fullname;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _stateController.text = user.state;
        _cityController.text = user.city;
        _localityController.text = user.locality;
      });
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _localityController.dispose();
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

  void _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    final shippingAddress = ShippingAddress(
      fullname: _fullnameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      state: _stateController.text.trim(),
      city: _cityController.text.trim(),
      locality: _localityController.text.trim(),
    );

    final order = await _orderController.createOrder(
      context: context,
      userId: userId!,
      shippingAddress: shippingAddress,
      paymentMethod: _paymentMethod,
      saveInfo: _saveInfo,
      onError: (error) {
        setState(() {
          _isCreatingOrder = false;
        });
      },
    );

    if (order != null) {
      setState(() {
        _isCreatingOrder = false;
      });

      // Nếu saveInfo = true, cập nhật thông tin user
      if (_saveInfo) {
        await _updateUserInfo(shippingAddress);
      }

      // Navigate đến OrderConfirmationScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
      );
    } else {
      setState(() {
        _isCreatingOrder = false;
      });
    }
  }

  Future<void> _updateUserInfo(ShippingAddress shippingAddress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = json.decode(userJson);

        // Cập nhật tất cả thông tin từ shippingAddress
        userData['phone'] = shippingAddress.phone;
        userData['address'] = shippingAddress.address;
        userData['state'] = shippingAddress.state; // Province
        userData['city'] = shippingAddress.city; // City
        userData['locality'] = shippingAddress.locality; // Ward

        // Cập nhật lại SharedPreferences
        final updatedUserJson = jsonEncode(userData);
        await prefs.setString('user', updatedUserJson);

        // Cập nhật Riverpod state
        ref.read(userProvider.notifier).setUser(updatedUserJson);

        print(
          'User info updated: phone=${shippingAddress.phone}, address=${shippingAddress.address}, state=${shippingAddress.state}, city=${shippingAddress.city}, locality=${shippingAddress.locality}',
        );
      }
    } catch (e) {
      print('Error updating user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Cart?>(
        future: futureCart,
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = cartSnapshot.data;
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
                    'Cart is empty',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order items section
                  Text(
                    'Order Items',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<CartItemWithProduct>>(
                    future: _loadCartItemsWithProducts(cart.products),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final items = snapshot.data ?? [];
                      return Column(
                        children: items.map((item) {
                          final product = item.product;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      product != null &&
                                          product.images.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            product.images[0],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  );
                                                },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product?.productName ?? 'Product',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${item.cartItem.quantity}',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (product != null)
                                        Text(
                                          _formatPrice(product.price),
                                          style: GoogleFonts.quicksand(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Shipping information
                  Text(
                    'Shipping Information',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Full name
                  TextFormField(
                    controller: _fullnameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.trim().length < 10) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.home),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // State
                  TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State/Province *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter state/province';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // City
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City/District *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter city/district';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Locality
                  TextFormField(
                    controller: _localityController,
                    decoration: InputDecoration(
                      labelText: 'Ward/Commune *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.pin_drop),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter ward/commune';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Save info checkbox
                  CheckboxListTile(
                    title: Text(
                      'Save information for next order',
                      style: GoogleFonts.quicksand(fontSize: 14),
                    ),
                    value: _saveInfo,
                    onChanged: (value) {
                      setState(() {
                        _saveInfo = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24),
                  // Payment method
                  Text(
                    'Payment Method',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Only Cash on delivery
                  RadioListTile<String>(
                    title: Text(
                      'Cash on delivery',
                      style: GoogleFonts.quicksand(fontSize: 14),
                    ),
                    value: 'cash',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Total price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _formatPrice((cart.totalPrice ?? 0).toString()),
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Place order button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCreatingOrder ? null : _handlePlaceOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isCreatingOrder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Place Order',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper class để kết hợp CartItem với Product
class CartItemWithProduct {
  final CartItem cartItem;
  final Product? product;

  CartItemWithProduct({required this.cartItem, this.product});
}
