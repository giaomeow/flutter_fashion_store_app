import 'dart:convert';

class SubCategory {
  final String id;
  final String subCategoryName;
  final String image;
  final String categoryId;
  final String categoryName;

  SubCategory({
    required this.id,
    required this.subCategoryName,
    required this.image,
    required this.categoryId,
    required this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subCategoryName': subCategoryName,
      'image': image,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['_id']?.toString() ?? '',
      subCategoryName: map['subCategoryName']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
    );
  }
  String toJsonString() => json.encode(toMap());

  factory SubCategory.fromJsonString(String source) {
    return SubCategory.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'SubCategory(id: $id, subCategoryName: $subCategoryName, image: $image, categoryId: $categoryId, categoryName: $categoryName)';
  }
}
