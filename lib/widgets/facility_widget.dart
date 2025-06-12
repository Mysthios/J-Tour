import 'package:flutter/material.dart';

class FacilityWidget {
  static void addFacility(BuildContext context, List<String> facilities) {
    final TextEditingController facilityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Fasilitas'),
        content: TextField(
          controller: facilityController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Nama fasilitas",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (facilityController.text.isNotEmpty) {
                facilities.add(facilityController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  static void removeFacility(List<String> facilities, int index) {
    facilities.removeAt(index);
  }
}