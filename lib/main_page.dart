// 2. PERBAIKAN MAIN PAGE - Gunakan authProvider untuk role
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/homepage/widgets/bottom_navbar.dart';
import 'package:j_tour/pages/saved/saved_page.dart';
import 'package:j_tour/pages/search/search_page.dart';
import 'package:j_tour/pages/account/account_page.dart';
import 'package:j_tour/pages_admin/homepage/homepage.dart';
import 'package:j_tour/providers/bottom_navbar_provider.dart';
import 'package:j_tour/providers/search_category_provider.dart';
import 'package:j_tour/providers/auth_provider.dart'; // TAMBAH INI

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavBarProvider);
    final authState = ref.watch(authProvider); // TAMBAH INI

    
    
    // Ambil role dari auth state, bukan hardcode
    final bool isAdmin = authState.isAdmin;
    
    List<Widget> pages = [];
    
    if (isAdmin) {
      // Pages untuk ADMIN
      pages = [
        const AdminHomePage(), // Tab 1: Admin Dashboard
        const ExplorePage(),   // Tab 2: Explore (bisa buat AdminExplore jika perlu)
        const AccountPage(),   // Tab 3: Account
      ];
    } else {
      // Pages untuk USER BIASA
      pages = [
        HomePage(
          onNavigateToSearch: (category) {
            ref.read(searchCategoryProvider.notifier).state = category;
            ref.read(bottomNavBarProvider.notifier).updateIndex(1);
          },
        ),                     // Tab 1: User Homepage
        const ExplorePage(),   // Tab 2: Search/Explore
        const SavedPage(),     // Tab 3: Saved Places
        const AccountPage(),   // Tab 4: Account
      ];
    }

    // Safety check jika index out of range
    final safeIndex = currentIndex >= pages.length ? 0 : currentIndex;
    if (safeIndex != currentIndex) {
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
        role: isAdmin ? "admin" : "user", // Pass role ke CustomBottomNavBar
      ),
    );
  }
}