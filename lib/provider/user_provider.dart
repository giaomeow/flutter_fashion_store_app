import 'package:flutter_riverpod/legacy.dart';
import 'package:mac_store_app_new/models/user.dart';

class UserProvider extends StateNotifier<User?> {
  // Constructor initialize state with default User
  //purpose manage the state of the user object allowing  updates
  UserProvider()
    : super(
        User(
          id: '',
          fullname: '',
          email: '',
          password: '',
          city: '',
          state: '',
          locality: '',
          token: '',
        ),
      );

  // Get the method extract value form object
  User? get user => state;

  // method to  set user state from Json
  // purpose update the state of the user base on Json String representation of user Object
  void setUser(String userJson) {
    state = User.fromJson(userJson);
  }

  // Method to clear user data
  void signOut() {
    state = null;
  }
}

// make the data accessible to the UI
final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);

// Ví dụ sử dụng:
// // Đọc user
// final user = ref.watch(userProvider);

// // Cập nhật user
// ref.read(userProvider.notifier).setUser(userJsonString);
