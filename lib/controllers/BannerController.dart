import 'dart:convert';

import 'package:mac_store_app_new/global_variables.dart';
import 'package:mac_store_app_new/models/banner_model.dart';
import 'package:http/http.dart' as http;

class BannerController {
  Future<List<BannerModel>> loadBanners() async {
    print('Loading banners...');
    final response = await http.get(Uri.parse('$uri/api/banners'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load banners: ${response.statusCode}');
    }
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    final List<BannerModel> banners = jsonList
        .map((item) => BannerModel.fromMap(item as Map<String, dynamic>))
        .toList();
    print('Banners loaded: ${banners.length}');
    return banners;
  }
}
