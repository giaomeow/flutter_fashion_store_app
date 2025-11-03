import 'dart:convert';
import 'package:mac_store_app_new/models/cart_item.dart';

/// Model cho giỏ hàng (Cart)
class Cart {
  final String id; // ID của cart
  final String userId; // ID của user sở hữu cart
  final List<CartItem> products; // Danh sách sản phẩm trong cart
  final double? totalPrice; // Tổng giá trị giỏ hàng (từ BE trả về)
  final int? totalQuantity; // Tổng số lượng sản phẩm (từ BE trả về)
  final DateTime? createdAt; // Ngày tạo
  final DateTime? updatedAt; // Ngày cập nhật

  Cart({
    required this.id,
    required this.userId,
    required this.products,
    this.totalPrice,
    this.totalQuantity,
    this.createdAt,
    this.updatedAt,
  });

  /// Chuyển đổi Cart thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'products': products.map((item) => item.toMap()).toList(),
      if (totalPrice != null) 'totalPrice': totalPrice,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Tạo Cart từ Map (từ API response)
  factory Cart.fromMap(Map<String, dynamic> map) {
    // Parse products list
    List<CartItem> productsList = [];
    if (map['products'] != null && map['products'] is List) {
      productsList = (map['products'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Parse timestamps
    DateTime? createdAt;
    DateTime? updatedAt;
    if (map['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(map['createdAt'].toString());
      } catch (e) {
        // Ignore parse error
      }
    }
    if (map['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(map['updatedAt'].toString());
      } catch (e) {
        // Ignore parse error
      }
    }

    return Cart(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      products: productsList,
      totalPrice: map['totalPrice'] != null
          ? (map['totalPrice'] is double
                ? map['totalPrice'] as double
                : (map['totalPrice'] is int
                      ? (map['totalPrice'] as int).toDouble()
                      : double.tryParse(map['totalPrice'].toString())))
          : null,
      totalQuantity: map['totalQuantity'] != null
          ? (map['totalQuantity'] is int
                ? map['totalQuantity'] as int
                : int.tryParse(map['totalQuantity'].toString()))
          : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Chuyển đổi Cart thành JSON String
  String toJson() => json.encode(toMap());

  /// Tạo Cart từ JSON String
  factory Cart.fromJson(String source) {
    return Cart.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Cart(id: $id, userId: $userId, products: ${products.length}, totalPrice: $totalPrice)';
  }
}
