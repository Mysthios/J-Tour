import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_tour/core/constan.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/onBoarding/onboarding_page.dart';
// pastikan ini diimport atau sesuaikan nama file

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    });
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
          // child: Image.asset(
          //   'assets/images/J-Tour_Logo.png',
          //   width: 200,
          //   height: 200,
          // ),
          ),
    );
  }
}
