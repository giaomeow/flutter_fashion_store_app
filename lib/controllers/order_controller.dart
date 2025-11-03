import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mac_store_app_new/global_variables.dart';
import 'package:mac_store_app_new/models/order.dart';
import 'package:mac_store_app_new/services/manage_http_response.dart';
import 'package:http/http.dart' as http;

class OrderController {
  /// Tạo đơn hàng từ cart
  /// POST /api/orders
  /// Body: { userId, shippingAddress, paymentMethod, saveInfo }
  /// Returns Order object nếu thành công, null nếu có lỗi
  Future<Order?> createOrder({
    required BuildContext context,
    required String userId,
    required ShippingAddress shippingAddress,
    required String paymentMethod,
    bool saveInfo = false,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final body = jsonEncode({
        'userId': userId,
        'shippingAddress': shippingAddress.toMap(),
        'paymentMethod': paymentMethod,
        'saveInfo': saveInfo,
      });

      print('Create order request: $body');

      final response = await http.post(
        Uri.parse('$uri/api/orders'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      print('Create order response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          final order = Order.fromMap(responseData);
          print('Order created: ${order.orderNumber}');
          onSuccess?.call();
          return order;
        } catch (e) {
          print('Error parsing order response: $e');
          onSuccess?.call(); // Vẫn gọi onSuccess vì API đã trả về 201
          return null;
        }
      } else {
        manageHTTPResponse(
          response: response,
          context: context,
          onSuccess: () {}, // Không cần làm gì vì đã handle ở trên
        );
        return null;
      }
    } catch (e) {
      print('Error creating order: $e');
      onError?.call('Error creating order: $e');
      showSnackBar(context, 'Error creating order');
      return null;
    }
  }

  /// Lấy danh sách đơn hàng của user
  /// GET /api/orders/:userId
  Future<List<Order>> getOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri/api/orders/$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('Get orders response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List) {
          return responseData
              .map((item) => Order.fromMap(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Unexpected response format');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  /// Lấy chi tiết 1 đơn hàng
  /// GET /api/orders/detail/:orderId
  Future<Order?> getOrderDetail(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$uri/api/orders/detail/$orderId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print(
        'Get order detail response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Order.fromMap(responseData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load order detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading order detail: $e');
      return null;
    }
  }

  /// Cập nhật trạng thái đơn hàng
  /// PUT /api/orders/:orderId/status
  Future<void> updateOrderStatus({
    required BuildContext context,
    required String orderId,
    required String status,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final body = jsonEncode({'status': status});

      print('Update order status request: $body');

      final response = await http.put(
        Uri.parse('$uri/api/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      print(
        'Update order status response: ${response.statusCode} - ${response.body}',
      );

      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () {
          onSuccess?.call();
        },
      );
    } catch (e) {
      print('Error updating order status: $e');
      onError?.call('Error updating order status: $e');
      showSnackBar(context, 'Error updating order status');
    }
  }
}
