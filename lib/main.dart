import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warteg_app/admin/admin_dasboard_page.dart';
import 'package:warteg_app/config/supabase_config.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/screen/home.dart';
import 'package:warteg_app/screen/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool("isLogin") ?? false;
  final String username = prefs.getString("username") ?? "Guest";
  final String email = prefs.getString("email") ?? "";
  final String role = prefs.getString("role") ?? "user"; // ← tambah ini

  final container = ProviderContainer();

  container.read(currentUserProvider.notifier).state = {
    "username": username,
    "email": email,
    "role": role, // ← tambah ini
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(isLogin: isLogin, role: role), // ← tambah role
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  final String role;

  const MyApp({super.key, required this.isLogin, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 36, 40, 39),
        fontFamily: 'Poppins',
      ),

      home: isLogin
          ? (role == 'admin' ? AdminDashboardPage() : Home())
          : WelcomePage(),
    );
  }
}
