import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/homepage/homepage.dart';
import 'package:j_tour/pages/homepage/widgets/bottom_navbar.dart';
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
