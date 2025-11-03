import 'dart:convert';

/// Model cho một item trong đơn hàng
class OrderItem {
  final String productId; // ID sản phẩm
  final int quantity; // Số lượng
  final double price; // Giá tại thời điểm đặt hàng
  final Map<String, dynamic>? product; // Thông tin product (nếu BE populate)

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  /// Chuyển đổi OrderItem thành Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      if (product != null) 'product': product,
    };
  }

  /// Tạo OrderItem từ Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    // productId có thể là string ID hoặc object Product (khi BE populate)
    String productIdStr = '';
    Map<String, dynamic>? productData;

    if (map['productId'] != null) {
      if (map['productId'] is String) {
        productIdStr = map['productId'] as String;
      } else if (map['productId'] is Map) {
        // BE populate productId thành object Product
        productData = map['productId'] as Map<String, dynamic>;
        productIdStr = productData['_id']?.toString() ?? '';
      }
    }

    // Nếu có product data từ productId object, dùng nó
    final finalProductData =
        productData ?? map['product'] as Map<String, dynamic>?;

    return OrderItem(
      productId: productIdStr,
      quantity: (map['quantity'] ?? 0) as int,
      price: map['price'] != null
          ? (map['price'] is double
                ? map['price'] as double
                : (map['price'] is int
                      ? (map['price'] as int).toDouble()
                      : double.tryParse(map['price'].toString()) ?? 0))
          : 0,
      product: finalProductData,
    );
  }

  /// Chuyển đổi OrderItem thành JSON String
  String toJson() => json.encode(toMap());

  /// Tạo OrderItem từ JSON String
  factory OrderItem.fromJson(String source) {
    return OrderItem.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'OrderItem(productId: $productId, quantity: $quantity, price: $price)';
  }
}
