import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:j_tour/auth_check.dart';
import 'package:j_tour/firebase_options.dart';
import 'package:j_tour/pages/account/account_page.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/saved/saved_page.dart';
import 'package:j_tour/pages/search/search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Fallback initialization for web if needed
    await Firebase.initializeApp();
  }

  // Atur warna status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF6F6F6),
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J-Tour',
      theme: ThemeData(
        fontFamily: 'Helvetica',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(),
      routes: {
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/saved': (context) => const SavedPage(),
        '/account': (context) => const AccountPage(),
      },
    );
  }
}
