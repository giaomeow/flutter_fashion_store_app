import 'dart:convert';

class BannerModel {
  final String id;
  final String image;

  BannerModel({required this.id, required this.image});

  // Phương thức chuyển đổi thành Map để gửi lên server
  Map<String, dynamic> toMap() {
    return {'id': id, 'image': image};
  }

  // Phương thức chuyển đổi từ Map thành đối tượng Category
  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(id: map['_id'] as String, image: map['image'] as String);
  }

  // Phương thức chuyển đổi thành JSON string để gửi lên server
  String toJsonString() => json.encode(toMap());

  // Phương thức chuyển đổi từ JSON string thành đối tượng Category
  factory BannerModel.fromJsonString(String source) {
    return BannerModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  // Phương thức chuyển đổi thành JSON string để hiển thị trong console
  @override
  String toString() {
    return 'BannerModel(id: $id, image: $image)';
  }
}
