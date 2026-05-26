import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warteg_app/config/supabase_config.dart';
import 'package:warteg_app/screen/home.dart';
import 'package:warteg_app/screen/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // AMBIL SESSION LOGIN
    final session =
        Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warteg App',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 36, 40, 39),
        fontFamily: 'Poppins',
      ),

      // JIKA SUDAH LOGIN
      home: session != null
          ? Home()

          // JIKA BELUM LOGIN
          : WelcomePage(),
    );
  }
}