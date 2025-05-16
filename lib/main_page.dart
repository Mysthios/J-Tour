import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/homepage/widgets/bottom_navbar.dart';
import 'package:j_tour/pages/search/search_page.dart';
import 'package:j_tour/pages/account/account_page.dart';
import 'package:j_tour/pages_admin/homepage/homepage.dart';
import 'package:j_tour/providers/bottom_navbar_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavBarProvider);

    final List<Widget> pages = [
      const HomePage(),
      
      // const SearchPage(), //ini panggil satu persatu per page nantinya
      // const BookmarkPage(),
      // const ProfilePage(),
    ];
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
        const AccountPage(),
      ];
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavBarProvider.notifier).updateIndex(index);
        },
      ),
    );
  }
}
