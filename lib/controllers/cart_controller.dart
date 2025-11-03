import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mac_store_app_new/global_variables.dart';
import 'package:mac_store_app_new/models/cart.dart';
import 'package:mac_store_app_new/services/manage_http_response.dart';
import 'package:http/http.dart' as http;

class CartController {
  /// Thêm sản phẩm vào giỏ hàng
  /// POST /api/cart
  /// Body: { userId, productId, quantity }
  Future<void> addToCart({
    required BuildContext context,
    required String userId,
    required String productId,
    int quantity = 1,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      // Chuẩn bị request body
      final body = jsonEncode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      });

      print('Add to cart request: $body');

      // Gọi API
      final response = await http.post(
        Uri.parse('$uri/api/cart'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      print('Add to cart response: ${response.statusCode} - ${response.body}');

      // Xử lý response
      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () {
          // Parse response để lấy cart data
          try {
            final responseData = json.decode(response.body);
            final cart = Cart.fromMap(responseData);
            print('Cart updated: ${cart.products.length} items');

            // Gọi callback onSuccess nếu có
            onSuccess?.call();
          } catch (e) {
            print('Error parsing cart response: $e');
            // Vẫn gọi onSuccess vì API đã trả về 200
            onSuccess?.call();
          }
        },
      );
    } catch (e) {
      print('Error adding to cart: $e');
      onError?.call('Error adding product to cart: $e');
      showSnackBar(context, 'Error adding product to cart');
    }
  }

  /// Lấy giỏ hàng của user hiện tại
  /// GET /api/cart/:userId
  Future<Cart?> getCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri/api/cart/$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get cart response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Cart.fromMap(responseData);
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading cart: $e');
      return null;
    }
  }

  /// Cập nhật số lượng sản phẩm trong giỏ hàng
  /// PUT /api/cart/:cartItemId
  /// Body: { userId, quantity }
  Future<void> updateCartItem({
    required BuildContext context,
    required String userId,
    required String cartItemId,
    required int quantity,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final body = jsonEncode({'userId': userId, 'quantity': quantity});

      print('Update cart item request: $body');
      print('Update cart item URL: $uri/api/cart/$cartItemId');

      final response = await http.put(
        Uri.parse('$uri/api/cart/$cartItemId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      print(
        'Update cart item response: ${response.statusCode} - ${response.body}',
      );

      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () {
          onSuccess?.call();
        },
      );
    } catch (e) {
      print('Error updating cart item: $e');
      onError?.call('Error updating quantity: $e');
      showSnackBar(context, 'Error updating quantity');
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  /// DELETE /api/cart/:cartItemId
  /// Body: { userId }
  Future<void> deleteCartItem({
    required BuildContext context,
    required String userId,
    required String cartItemId,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final body = jsonEncode({'userId': userId});

      print('Delete cart item: $cartItemId');
      print('Delete cart item URL: $uri/api/cart/$cartItemId');
      print('Delete cart item body: $body');

      final response = await http.delete(
        Uri.parse('$uri/api/cart/$cartItemId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      print(
        'Delete cart item response: ${response.statusCode} - ${response.body}',
      );

      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () {
          onSuccess?.call();
        },
      );
    } catch (e) {
      print('Error deleting cart item: $e');
      onError?.call('Error removing product: $e');
      showSnackBar(context, 'Error removing product');
    }
  }

  /// Xóa toàn bộ giỏ hàng
  /// DELETE /api/cart/:userId/clear
  Future<void> clearCart({
    required BuildContext context,
    required String userId,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      print('Clear cart for user: $userId');

      final response = await http.delete(
        Uri.parse('$uri/api/cart/$userId/clear'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Clear cart response: ${response.statusCode} - ${response.body}');

      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () {
          onSuccess?.call();
        },
      );
    } catch (e) {
      print('Error clearing cart: $e');
      onError?.call('Error clearing cart: $e');
      showSnackBar(context, 'Error clearing cart');
    }
  }
}
