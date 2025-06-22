// widgets/user_place_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPlaceActionButtons extends StatelessWidget {
  final VoidCallback onDirections;

  const UserPlaceActionButtons({
    super.key,
    required this.onDirections,
  });

  void _openWhatsApp(BuildContext context) async {
    const phone = "6281234567890";
    final url = Uri.parse(
        "https://wa.me/$phone?text=Halo, saya ingin bertanya tentang tempat wisata ini");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Contact Button (Optional - commented out in original)
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton.icon(
          //     onPressed: () => _openWhatsApp(context),
          //     icon: const Icon(Icons.phone, color: Colors.white, size: 16),
          //     label: const Text(
          //       "Hubungi",
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.w600,
          //         fontSize: 14,
          //       ),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.blue,
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       elevation: 0,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 12),
          
          // Direction Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.navigation, color: Colors.white, size: 18),
              label: const Text(
                "Petunjuk Arah",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}