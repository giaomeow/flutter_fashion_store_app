import 'dart:convert';

/// Model cho một item trong giỏ hàng
class CartItem {
  final String? id; // ID của cart item (để update/delete) - có thể là _id từ BE
  final String productId; // ID sản phẩm
  final int quantity; // Số lượng
  final Map<String, dynamic>? product; // Thông tin product (nếu BE populate)

  CartItem({
    this.id,
    required this.productId,
    required this.quantity,
    this.product,
  });

  /// Chuyển đổi CartItem thành Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'quantity': quantity,
      if (product != null) 'product': product,
    };
  }

  /// Tạo CartItem từ Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
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
    // Nếu không, thử lấy từ field 'product'
    final finalProductData =
        productData ?? map['product'] as Map<String, dynamic>?;

    return CartItem(
      id: map['_id']?.toString() ?? map['id']?.toString(),
      productId: productIdStr,
      quantity: (map['quantity'] ?? 0) as int,
      product: finalProductData,
    );
  }

  /// Chuyển đổi CartItem thành JSON String
  String toJson() => json.encode(toMap());

  /// Tạo CartItem từ JSON String
  factory CartItem.fromJson(String source) {
    return CartItem.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'CartItem(productId: $productId, quantity: $quantity)';
  }
}
