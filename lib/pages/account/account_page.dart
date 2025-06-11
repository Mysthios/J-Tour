import 'package:flutter/material.dart';
import 'package:j_tour/pages/account/edit_profile.dart';
import 'package:j_tour/pages/account/about_jtour.dart';
import 'package:j_tour/pages/account/privacy_policy.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _currentIndex = 3; // Set the initial index to 3 for the Account page
  void _onNavBarTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Akun Anda',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 🔳 Background hitam dengan konten profil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Avatar dengan background putih
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fairuz Zaki',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'fairuzzaki972@gmail.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔘 Lingkaran kiri atas
                Positioned(
                  top: -30,
                  left: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // 🔘 Lingkaran kanan bawah
                Positioned(
                  bottom: -40,
                  right: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Label
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Akun',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Menu Items - Edit Profil
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Colors.black,
              ),
              title: const Text(
                'Edit Profil',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Section Label
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Lainnya',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Menu Items - Lainnya
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.black,
                  ),
                  title: const Text(
                    'Tentang J-Tour',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutJTourPage()),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.black,
                  ),
                  title: const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement logout functionality
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
                      actions: [
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Implement actual logout logic here
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D4D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      //       bottomNavigationBar: CustomBottomNavBar(
      //   currentIndex: _currentIndex,
      //   onTap: _onNavBarTap,
      // ),
    );
  }
}