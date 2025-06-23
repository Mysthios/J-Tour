import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Sembunyikan splash screen native sesegera mungkin
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Atur warna status bar untuk splash screen
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparan untuk edge-to-edge
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Set orientasi portrait (opsional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
        // Tambahan untuk konsistensi UI
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F6F6),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Helvetica',
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Splash(), // Splash screen dengan auth check
    );
  }
}