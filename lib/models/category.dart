import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String image;
  final String banner;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.banner,
  });

  // Phương thức chuyển đổi thành Map để gửi lên server
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'image': image, 'banner': banner};
  }

  // Phương thức chuyển đổi từ Map thành đối tượng Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['_id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      banner: map['banner'] as String,
    );
  }

  // Phương thức chuyển đổi thành JSON string để gửi lên server
  String toJsonString() => json.encode(toMap());

  // Phương thức chuyển đổi từ JSON string thành đối tượng Category
  factory Category.fromJsonString(String source) {
    return Category.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  // Phương thức chuyển đổi thành JSON string để hiển thị trong console
  @override
  String toString() {
    return 'Category(id: $id, name: $name, image: $image, banner: $banner)';
  }
}
