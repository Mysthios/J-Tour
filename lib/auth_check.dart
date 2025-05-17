import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/login/login_page.dart';
import 'package:j_tour/pages/splash/splash_screen.dart';
import 'package:j_tour/providers/auth_provider.dart';
import 'package:j_tour/main_page.dart';

class AuthCheck extends ConsumerWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainPage();
        } else {
          return const Splash();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
