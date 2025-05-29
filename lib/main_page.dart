import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/homepage/widgets/bottom_navbar.dart';
import 'package:j_tour/pages/saved/saved_page.dart';
import 'package:j_tour/pages/search/search_page.dart';
import 'package:j_tour/pages/account/account_page.dart';
import 'package:j_tour/pages_admin/homepage/homepage.dart';
import 'package:j_tour/providers/bottom_navbar_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavBarProvider);

    String role = "admin"; // Ganti dengan logika untuk mendapatkan role user
    List<Widget> pages = [];
    if (role == "admin") {
      pages = [
        const AdminHomePage(),
        const SearchPage(),
        const AccountPage(),
      ];
    } else if (role == "user") {
      pages = [
        const HomePage(),
        const SearchPage(),
        const SavedPage(),
        const AccountPage(),
      ];
    }

    // Safety check jika index out of range saat role berubah
    final safeIndex = currentIndex >= pages.length ? 0 : currentIndex;
    if (safeIndex != currentIndex) {
      // Update state index ke 0 agar tidak error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bottomNavBarProvider.notifier).updateIndex(0);
      });
    }    

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: safeIndex,
        onTap: (index) {
          ref.read(bottomNavBarProvider.notifier).updateIndex(index);
        },
        role: role,
      ),
    );
  }
}
