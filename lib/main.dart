import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app_new/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_store_app_new/views/screens/main_screen.dart';

void main() {
  //Run the flutter app wrapped in a ProviderScope for managing the state of the app
  runApp(ProviderScope(child: const MyApp()));
}

// Root widget of the appm a cosummerWidger to comsime state change
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Method to check the token and set the user data of avaiable
  Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
    // obtain an instance of shared preferences for local storage
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //Retrive the authentication token and user data stored locally
    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');

    print('Debug - main.dart loading user: token=$token, userJson=$userJson');

    // if both token and user data are available, update the app state with the user data using riverpod
    if (token != null &&
        token.isNotEmpty &&
        userJson != null &&
        userJson.isNotEmpty) {
      // Clear old state first to prevent showing old user data
      ref.read(userProvider.notifier).signOut();
      await Future.delayed(const Duration(milliseconds: 50));

      // Update the app state with the user data using riverpod
      ref.read(userProvider.notifier).setUser(userJson);

      // Verify the update
      await Future.delayed(const Duration(milliseconds: 50));
      final user = ref.read(userProvider);
      print(
        'Debug - User loaded in main: ${user?.id}, ${user?.email}, ${user?.fullname}',
      );

      // Log to verify data is correct
      if (userJson.isNotEmpty) {
        try {
          final decoded = json.decode(userJson);
          print(
            'Debug - User JSON in main.dart: id=${decoded['_id'] ?? decoded['id']}, email=${decoded['email']}, fullname=${decoded['fullname']}',
          );
        } catch (e) {
          print('Debug - Error decoding userJson: $e');
        }
      }
    } else {
      // Clear user state if no valid token/user data
      ref.read(userProvider.notifier).signOut();
      print('Debug - No valid user data, clearing state');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Consumer(
        builder: (context, ref, child) {
          return FutureBuilder(
            future: _checkTokenAndSetUser(ref),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // Cho phép vào app mà không cần login - chỉ yêu cầu login khi cần thiết
              // MainScreen sẽ watch userProvider và rebuild AccountScreen khi user thay đổi
              return const MainScreen();
            },
          );
        },
      ),
    );
  }
}
