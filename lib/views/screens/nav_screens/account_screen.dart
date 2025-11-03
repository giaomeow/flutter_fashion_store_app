import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app_new/controllers/AuthController.dart';
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:mac_store_app_new/views/screens/authetication_screens/login_screen.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/update_profile_dialog.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/widgets/change_password_dialog.dart';
import 'package:mac_store_app_new/views/screens/nav_screens/order_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final AuthController _authController = AuthController();

  String? _getUserId() {
    final user = ref.read(userProvider);
    if (user?.id != null && user!.id.isNotEmpty) {
      return user.id;
    }
    return null;
  }

  Future<String?> _getUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        return (userData['id'] ?? userData['_id'] ?? '').toString();
      }
    } catch (e) {
      print('Error getting userId from SharedPreferences: $e');
    }
    return null;
  }

  void _showUpdateProfileDialog() {
    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => UpdateProfileDialog(
        user: user,
        authController: _authController,
        onSuccess: () {
          // Không cần setState vì ref.watch sẽ tự động rebuild khi userProvider thay đổi
          // Chỉ cần đảm bảo dialog đóng sau khi provider update
        },
      ),
    ).then((_) {
      // Sau khi dialog đóng, AccountScreen sẽ tự rebuild vì đã watch userProvider
      // Thêm một chút delay để đảm bảo provider đã được update
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          ChangePasswordDialog(authController: _authController),
    );
  }

  void _showOrderHistory() async {
    final userId = _getUserId() ?? await _getUserIdFromPrefs();
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(userId: userId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Reload user từ SharedPreferences khi AccountScreen được khởi tạo
    // Đảm bảo data luôn sync với SharedPreferences (source of truth)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadUserFromPreferences();
    });
  }

  Future<void> _reloadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user');

      // Check current user in provider
      final currentUser = ref.read(userProvider);
      final currentUserId = currentUser?.id ?? '';

      // Parse userId from SharedPreferences
      String? prefsUserId;
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final decoded = json.decode(userJson);
          prefsUserId = (decoded['_id'] ?? decoded['id'] ?? '').toString();
        } catch (e) {
          print('Error parsing userJson in AccountScreen: $e');
        }
      }

      print(
        'Debug - AccountScreen: currentUserId=$currentUserId, prefsUserId=$prefsUserId',
      );

      // Chỉ update nếu user trong SharedPreferences khác với user hiện tại trong provider
      if (token != null &&
          token.isNotEmpty &&
          userJson != null &&
          userJson.isNotEmpty) {
        if (prefsUserId != null &&
            prefsUserId.isNotEmpty &&
            prefsUserId != currentUserId) {
          print(
            'Debug - AccountScreen: User mismatch, reloading from SharedPreferences',
          );

          // Clear old state first
          ref.read(userProvider.notifier).signOut();
          await Future.delayed(const Duration(milliseconds: 50));

          // Update ProviderScope with new user data
          ref.read(userProvider.notifier).setUser(userJson);

          final user = ref.read(userProvider);
          print(
            'Debug - AccountScreen reloaded user: ${user?.id}, ${user?.email}, ${user?.fullname}',
          );
        }
      } else {
        // Clear user state if no valid data
        if (currentUser != null) {
          ref.read(userProvider.notifier).signOut();
          print(
            'Debug - AccountScreen: No valid user data in SharedPreferences, clearing state',
          );
        }
      }
    } catch (e) {
      print('Error reloading user in AccountScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch userProvider để rebuild khi user thay đổi
    final user = ref.watch(userProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Account',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome!',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please log in to access your account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullname.isNotEmpty ? user.fullname : 'User',
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (user.phone.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.grey.shade300,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.phone,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (user.address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade300,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.address,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Menu Items
            _buildMenuTile(
              icon: Icons.edit,
              title: 'Update Profile',
              onTap: _showUpdateProfileDialog,
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: _showChangePasswordDialog,
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.history,
              title: 'Order History',
              onTap: _showOrderHistory,
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.logout,
              title: 'Sign Out',
              titleColor: Colors.red,
              onTap: () async {
                await _authController.signOut(context: context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? Colors.black, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
