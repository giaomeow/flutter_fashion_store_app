import 'dart:convert';

import 'package:mac_store_app_new/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app_new/models/product.dart';

class ProductController {
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$uri/api/products'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> data;
      if (decodedData is List) {
        data = decodedData;
      } else if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is Map && decodedData.containsKey('data')) {
        data = decodedData['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  // Get new products
  // Route: GET /api/products?type=new
  Future<List<Product>> getNewProducts() async {
    final response = await http.get(
      Uri.parse('$uri/api/products?type=new'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> data;
      if (decodedData is List) {
        data = decodedData;
      } else if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is Map && decodedData.containsKey('data')) {
        data = decodedData['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception('Failed to load new products: ${response.statusCode}');
    }
  }

  // Get popular products
  // Route: GET /api/products?type=popular
  Future<List<Product>> getPopularProducts() async {
    final response = await http.get(
      Uri.parse('$uri/api/products?type=popular'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> data;
      if (decodedData is List) {
        data = decodedData;
      } else if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is Map && decodedData.containsKey('data')) {
        data = decodedData['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception(
        'Failed to load popular products: ${response.statusCode}',
      );
    }
  }

  // Search products
  // Route: GET /api/products?search=keyword&type=new (hoặc popular/recommend)
  Future<List<Product>> searchProducts(
    String searchQuery, {
    String? type,
  }) async {
    final encodedQuery = Uri.encodeComponent(searchQuery);
    String url = '$uri/api/products?search=$encodedQuery';
    if (type != null && type.isNotEmpty) {
      url += '&type=$type';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> data;
      if (decodedData is List) {
        data = decodedData;
      } else if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is Map && decodedData.containsKey('data')) {
        data = decodedData['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception('Failed to search products: ${response.statusCode}');
    }
  }

  // Get recommended products
  // Route: GET /api/products?type=recommend
  Future<List<Product>> getRecommendedProducts() async {
    final response = await http.get(
      Uri.parse('$uri/api/products?type=recommend'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> data;
      if (decodedData is List) {
        data = decodedData;
      } else if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is Map && decodedData.containsKey('data')) {
        data = decodedData['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception(
        'Failed to load recommended products: ${response.statusCode}',
      );
    }
  }

  Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse('$uri/api/product/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      print('Product response: $decodedData');

      // Backend trả về object trực tiếp, không có wrapper
      Map<String, dynamic> productData;
      if (decodedData is Map<String, dynamic>) {
        productData = decodedData;
      } else if (decodedData is Map) {
        productData = Map<String, dynamic>.from(decodedData);
      } else {
        throw Exception('Unexpected response format');
      }

      final product = Product.fromMap(productData);
      print(
        'Parsed product - categoryId: ${product.categoryId}, subcategoryId: ${product.subcategoryId}',
      );
      return product;
    } else {
      print('Error response: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  // Get product by categoryid
  // Route: GET /api/:categoryId/products
  Future<List<Product>> getProductsByCategoryId(String categoryId) async {
    final url = '$uri/api/$categoryId/products';
    print('Fetching: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      // Backend trả về { products: [...] }
      List<dynamic> data;
      if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is List) {
        data = decodedData;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      print('Parsed ${data.length} products');
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception(
        'Failed to load products: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Get product by categoryid and subcategoryid
  // Route: GET /api/:categoryId/:subCategoryId/products
  Future<List<Product>> getProductsByCategoryAndSubcategoryId(
    String categoryId,
    String subcategoryId,
  ) async {
    final url = '$uri/api/$categoryId/$subcategoryId/products';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      // Backend trả về { products: [...] }
      List<dynamic> data;
      if (decodedData is Map && decodedData.containsKey('products')) {
        data = decodedData['products'] as List<dynamic>;
      } else if (decodedData is List) {
        data = decodedData;
      } else {
        throw Exception('Unexpected response format: $decodedData');
      }
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception(
        'Failed to load products: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Get product by subcategoryid (legacy - giữ lại để tương thích)
  // Sử dụng route mới với cả categoryId và subcategoryId
  Future<List<Product>> getProductsBySubcategoryId(
    String subcategoryId, {
    String? categoryId,
  }) async {
    // Nếu có categoryId, dùng route mới
    if (categoryId != null && categoryId.isNotEmpty) {
      return getProductsByCategoryAndSubcategoryId(categoryId, subcategoryId);
    }
    // Nếu không có categoryId, chỉ dùng subcategoryId (fallback - có thể không work)
    // Tạm thời throw error hoặc return empty list
    throw Exception(
      'categoryId is required for subcategory products. Please provide categoryId.',
    );
  }
}
