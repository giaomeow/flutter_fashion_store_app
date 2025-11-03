import 'dart:convert';

import 'package:mac_store_app_new/global_variables.dart';
import 'package:mac_store_app_new/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CategoryController {
  // Get categories
  Future<List<Category>> loadCategories({BuildContext? context}) async {
    try {
      http.Response response = await http.get(
        Uri.parse('${uri}/api/categories'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Category.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
