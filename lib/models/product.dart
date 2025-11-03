import 'dart:convert';

class Product {
  final String id;
  final String productName;
  final String quantity;
  final String categoryName;
  final String categoryId;
  final String subcategoryId;
  final List<String> images;
  final String description;
  final String price;
  final String discountPrice;
  Product({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.categoryName,
    this.categoryId = '',
    this.subcategoryId = '',
    required this.images,
    required this.description,
    required this.price,
    required this.discountPrice,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'quantity': quantity,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'images': images,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    // Backend trả về 'category' và 'subCategory' (không phải categoryId/subcategoryId)
    final categoryId = (map['categoryId'] ?? map['category'] ?? '').toString();
    final subcategoryId =
        (map['subcategoryId'] ?? map['subCategory'] ?? map['subcategory'] ?? '')
            .toString();

    return Product(
      id: map['_id']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      quantity: map['quantity']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: map['description']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      discountPrice: map['discountPrice']?.toString() ?? '',
    );
  }
  String toJsonString() => json.encode(toMap());

  factory Product.fromJsonString(String source) {
    return Product.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Product(id: $id, productName: $productName, quantity: $quantity, categoryName: $categoryName, categoryId: $categoryId, subcategoryId: $subcategoryId, images: $images, description: $description, price: $price, discountPrice: $discountPrice)';
  }
}
