import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/account/account_page.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/saved/saved_page.dart';
import 'package:j_tour/pages/search/search_page.dart';
import 'package:j_tour/pages_admin/homepage/homepage.dart';
import 'package:j_tour/providers/auth_provider.dart';
import 'package:j_tour/providers/bottom_navbar_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final _pages = [
      HomePage(),
      SearchPage(),
      SavedPage(),
      AccountPage(),
    ];

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // This shouldn't happen because AuthCheck will redirect to login
          return const Center(child: Text('User not found'));
        }

        // Redirect based on role
        if (user.role == 'admin') {
          return const AdminHomePage();
        } else {
          return const HomePage();
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
