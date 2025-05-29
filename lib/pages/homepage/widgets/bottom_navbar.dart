import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String role; // tambahkan role untuk bedakan user & admin

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan item navbar berdasarkan role
    final List<BottomNavigationBarItem> items =
        role == 'admin' ? _adminItems : _userItems;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BottomNavigationBar(
              backgroundColor: Colors.black,
              elevation: 0,
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey[700],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  static const List<BottomNavigationBarItem> _userItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded, size: 24),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_rounded, size: 24),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border_rounded, size: 24),
      label: 'Bookmark',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded, size: 24),
      label: 'Profile',
    ),
  ];

  static const List<BottomNavigationBarItem> _adminItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded, size: 24),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_rounded, size: 24),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded, size: 24),
      label: 'Profile',
    ),
  ];
}
