import 'dart:convert';

import 'package:mac_store_app_new/global_variables.dart';
import 'package:mac_store_app_new/models/subcategory.dart';
import 'package:http/http.dart' as http;

class SubcategoryController {
  Future<List<SubCategory>> getSubcategoriesByCategoryId(
    String categoryId,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/category/$categoryId/subcategories'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.map((e) => SubCategory.fromMap(e)).toList();
        } else {
          print('No subcategories found');
          return [];
        }
      } else {
        throw Exception('Failed to load subcategories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
