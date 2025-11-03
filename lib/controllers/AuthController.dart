import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app_new/global_variables.dart';
import 'package:mac_store_app_new/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:mac_store_app_new/services/manage_http_response.dart';
import 'package:mac_store_app_new/views/screens/authetication_screens/login_screen.dart';
import 'package:mac_store_app_new/views/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class AuthController {
  Future<void> signUp({
    required BuildContext context,
    required String fullname,
    required String email,
    required String password,
    VoidCallback? onSuccess,
  }) async {
    try {
      User user = User(
        id: '',
        fullname: fullname,
        email: email,
        password: password,
        city: '',
        state: '',
        locality: '',
        token: '',
      );
      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          showSnackBar(context, 'Created account successful');
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> signIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHTTPResponse(
        response: response,
        context: context,
        onSuccess: () async {
          // Clear old user data first before setting new data
          SharedPreferences preferences = await SharedPreferences.getInstance();

          // Clear old data
          await preferences.remove('auth_token');
          await preferences.remove('user');
          providerContainer.read(userProvider.notifier).signOut();

          // Small delay to ensure old data is cleared
          await Future.delayed(const Duration(milliseconds: 50));

          // Save new user data to shared preferences
          String token = json.decode(response.body)['token'];
          await preferences.setString('auth_token', token);

          // Endcode user data received from BE as json string
          final responseData = json.decode(response.body);
          final userData = responseData['user'];

          if (userData != null) {
            final userJson = jsonEncode(userData);
            print('Debug - User data from API: $userData');
            print('Debug - User JSON: $userJson');

            // Store the new data in shared preferences
            await preferences.setString('user', userJson);

            // Update the app state with the new user data using riverpod
            // Sử dụng providerContainer riêng vì không có access đến WidgetRef trong controller
            providerContainer.read(userProvider.notifier).setUser(userJson);

            final testUser = providerContainer.read(userProvider);
            print(
              'Debug - User after set in providerContainer: ${testUser?.id}, ${testUser?.email}',
            );
          }

          // Đợi một chút để đảm bảo provider đã được update
          await Future.delayed(const Duration(milliseconds: 150));

          // Navigate to MainScreen
          // MainScreen's FutureBuilder will reload user from SharedPreferences
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(
                initialIndex: 4,
              ), // Switch to User tab (index 4)
            ),
            (route) => false,
          );

          showSnackBar(context, 'Sign in successful');
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> signOut({required BuildContext context}) async {
    try {
      // Clear all user data from SharedPreferences
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // Remove auth_token and user data
      await preferences.remove('auth_token');
      await preferences.remove('user');

      // Clear provider state
      providerContainer.read(userProvider.notifier).signOut();

      // Verify data is cleared
      final token = preferences.getString('auth_token');
      final user = preferences.getString('user');
      print('Debug - After signOut: token=$token, user=$user');

      // Navigate to login screen and clear navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      showSnackBar(context, 'Sign out successful');
    } catch (e) {
      print('Error signing out: $e');
      showSnackBar(context, 'Sign out failed: $e');
    }
  }

  /// Cập nhật thông tin cá nhân
  /// PUT /api/user/profile (userId được lấy từ token)
  Future<void> updateProfile({
    required BuildContext context,
    required String fullname,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? locality,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final body = jsonEncode({
        'fullname': fullname,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (locality != null) 'locality': locality,
      });

      final token = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('auth_token') ?? '',
      );

      final response = await http.put(
        Uri.parse('$uri/api/user/profile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print(
        'Update profile response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        // Cập nhật lại user trong SharedPreferences và Riverpod
        final responseData = json.decode(response.body);
        final userData = responseData['user'] ?? responseData;
        final userJson = jsonEncode(userData);

        print('Debug - Update profile userData: $userData');
        print('Debug - Update profile userJson: $userJson');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', userJson);

        // Update provider
        providerContainer.read(userProvider.notifier).setUser(userJson);
        final updatedUser = providerContainer.read(userProvider);
        print(
          'Debug - Updated user in provider: ${updatedUser?.fullname}, ${updatedUser?.phone}',
        );

        // Đợi một chút để đảm bảo provider đã được update
        await Future.delayed(const Duration(milliseconds: 50));

        onSuccess?.call();
        showSnackBar(context, 'Profile updated successfully');
      } else {
        final error = response.body.isNotEmpty
            ? json.decode(response.body)['message'] ??
                  'Failed to update profile'
            : 'Failed to update profile';
        onError?.call(error);
        showSnackBar(context, error);
      }
    } catch (e) {
      print('Error updating profile: $e');
      onError?.call('Error: $e');
      showSnackBar(context, 'Error updating profile: $e');
    }
  }

  /// Đổi mật khẩu
  /// PUT /api/user/change-password (userId được lấy từ token)
  Future<void> changePassword({
    required BuildContext context,
    required String oldPassword,
    required String newPassword,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final body = jsonEncode({
        'currentPassword': oldPassword, // Backend expects 'currentPassword'
        'newPassword': newPassword,
      });

      final token = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('auth_token') ?? '',
      );

      final response = await http.put(
        Uri.parse('$uri/api/user/change-password'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print(
        'Change password response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        onSuccess?.call();
        showSnackBar(context, 'Password changed successfully');
      } else {
        final error = response.body.isNotEmpty
            ? json.decode(response.body)['message'] ??
                  'Failed to change password'
            : 'Failed to change password';
        onError?.call(error);
        showSnackBar(context, error);
      }
    } catch (e) {
      print('Error changing password: $e');
      onError?.call('Error: $e');
      showSnackBar(context, 'Error changing password: $e');
    }
  }
}
