import 'dart:convert';

/// Class User - Định nghĩa cấu trúc dữ liệu người dùng
/// Chứa thông tin cá nhân và địa chỉ của user
class User {
  // Các thuộc tính của User
  final String id; // ID duy nhất của user
  final String fullname; // Họ và tên đầy đủ
  final String email; // Email đăng nhập
  final String password; // Mật khẩu (nên mã hóa trong thực tế)
  final String phone; // Số điện thoại
  final String address; // Địa chỉ
  final String city; // Thành phố
  final String state; // Tỉnh/Thành phố
  final String locality; // Quận/Huyện
  final String token; // Token xác thực

  /// Constructor - Hàm tạo User object
  /// Tất cả tham số đều bắt buộc (required)
  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.password,
    this.phone = '',
    this.address = '',
    required this.city,
    required this.state,
    required this.locality,
    required this.token,
  });

  /// Chuyển đổi User object thành Map
  /// Map là tập hợp các cặp key-value
  /// Bước trung gian để serialize object thành JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'fullname': fullname,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'locality': locality,
      'token': token,
    };
  }

  /// Chuyển đổi User object thành JSON String
  /// Sử dụng json.encode() để convert Map thành JSON
  /// Phù hợp để gửi dữ liệu lên server hoặc lưu trữ
  String toJson() => json.encode(toMap());

  /// Factory constructor - Tạo User từ Map
  /// Sử dụng khi nhận dữ liệu từ database hoặc API
  /// as String? ?? '' : Ép kiểu thành String, nếu null thì dùng chuỗi rỗng
  factory User.fromMap(Map<String, dynamic> map) => User(
    // Backend có thể trả về 'id' hoặc '_id'
    id: (map['id'] ?? map['_id'] ?? '').toString(),
    fullname: map['fullname'] as String? ?? '',
    email: map['email'] as String? ?? '',
    password: map['password'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    address: map['address'] as String? ?? '',
    city: map['city'] as String? ?? '',
    state: map['state'] as String? ?? '',
    locality: map['locality'] as String? ?? '',
    token: map['token'] as String? ?? '',
  );

  /// Factory constructor - Tạo User từ JSON String
  /// Sử dụng khi nhận dữ liệu từ API response
  /// Bước 1: json.decode() chuyển JSON String thành Map
  /// Bước 2: User.fromMap() chuyển Map thành User object
  factory User.fromJson(String source) {
    final decoded = json.decode(source);
    if (decoded == null || decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid user data: expected Map but got ${decoded.runtimeType}',
      );
    }
    return User.fromMap(decoded);
  }
}
