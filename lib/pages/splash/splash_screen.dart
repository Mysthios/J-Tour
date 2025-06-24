import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/core/constan.dart';
import 'package:j_tour/main_page.dart'; // Import MainPage yang berisi navbar
import 'package:j_tour/pages/onBoarding/onboarding_page.dart';
import 'package:j_tour/providers/auth_provider.dart';
import 'package:j_tour/providers/bottom_navbar_provider.dart'; // Import bottom navbar provider

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});
  
  @override
  ConsumerState<Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Tunggu minimal 3 detik untuk splash effect
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authState = ref.read(authProvider);
    
    // Tunggu sampai auth provider selesai initialize
    while (!authState.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    if (!mounted) return;
    
    if (authState.isAuthenticated) {
      // Reset bottom navigation index ke 0 (homepage)
      ref.read(bottomNavBarProvider.notifier).updateIndex(0);
      
      // SEMUA USER yang sudah login diarahkan ke MainPage (yang berisi navbar)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } else {
      // Jika belum login, ke onboarding page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/J-Tour_Logo.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 30),
            // Loading indicator untuk menunjukkan sedang mengecek auth
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);
                if (!authState.isInitialized) {
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}