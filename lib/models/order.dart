import 'dart:convert';
import 'package:mac_store_app_new/models/order_item.dart';

/// Model cho đơn hàng (Order)
class Order {
  final String id; // ID của order
  final String userId; // ID của user
  final String orderNumber; // Mã đơn hàng
  final List<OrderItem> products; // Danh sách sản phẩm
  final ShippingAddress shippingAddress; // Địa chỉ giao hàng
  final double totalPrice; // Tổng giá trị đơn hàng
  final String
  paymentMethod; // Phương thức thanh toán (cash, card, bank_transfer)
  final String status; // Trạng thái đơn hàng
  final DateTime? createdAt; // Ngày tạo
  final DateTime? updatedAt; // Ngày cập nhật

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.products,
    required this.shippingAddress,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Chuyển đổi Order thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'products': products.map((item) => item.toMap()).toList(),
      'shippingAddress': shippingAddress.toMap(),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Tạo Order từ Map (từ API response)
  factory Order.fromMap(Map<String, dynamic> map) {
    // Parse products list
    List<OrderItem> productsList = [];
    if (map['products'] != null && map['products'] is List) {
      productsList = (map['products'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Parse shippingAddress
    ShippingAddress shippingAddr = ShippingAddress(
      fullname: '',
      phone: '',
      address: '',
      state: '',
      city: '',
      locality: '',
    );
    if (map['shippingAddress'] != null && map['shippingAddress'] is Map) {
      shippingAddr = ShippingAddress.fromMap(
        map['shippingAddress'] as Map<String, dynamic>,
      );
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

    return Order(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      orderNumber: map['orderNumber']?.toString() ?? '',
      products: productsList,
      shippingAddress: shippingAddr,
      totalPrice: map['totalPrice'] != null
          ? (map['totalPrice'] is double
                ? map['totalPrice'] as double
                : (map['totalPrice'] is int
                      ? (map['totalPrice'] as int).toDouble()
                      : double.tryParse(map['totalPrice'].toString()) ?? 0))
          : 0,
      paymentMethod: map['paymentMethod']?.toString() ?? 'cash',
      status: map['status']?.toString() ?? 'pending',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Chuyển đổi Order thành JSON String
  String toJson() => json.encode(toMap());

  /// Tạo Order từ JSON String
  factory Order.fromJson(String source) {
    return Order.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, totalPrice: $totalPrice, status: $status)';
  }
}

/// Model cho địa chỉ giao hàng
class ShippingAddress {
  final String fullname; // Họ tên
  final String phone; // Số điện thoại
  final String address; // Địa chỉ chi tiết
  final String state; // Tỉnh/Thành phố
  final String city; // Quận/Huyện
  final String locality; // Phường/Xã

  ShippingAddress({
    required this.fullname,
    required this.phone,
    required this.address,
    required this.state,
    required this.city,
    required this.locality,
  });

  /// Chuyển đổi ShippingAddress thành Map
  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'phone': phone,
      'address': address,
      'state': state,
      'city': city,
      'locality': locality,
    };
  }

  /// Tạo ShippingAddress từ Map
  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      fullname: map['fullname']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      locality: map['locality']?.toString() ?? '',
    );
  }

  /// Chuyển đổi ShippingAddress thành JSON String
  String toJson() => json.encode(toMap());

  /// Tạo ShippingAddress từ JSON String
  factory ShippingAddress.fromJson(String source) {
    return ShippingAddress.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'ShippingAddress(fullname: $fullname, phone: $phone, address: $address)';
  }
}
