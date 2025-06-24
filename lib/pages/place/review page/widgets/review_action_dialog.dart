// pages/place/review page/widgets/review_action_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/models/review_model.dart';
import 'package:j_tour/pages/place/review%20page/review_card.dart';
import 'package:j_tour/providers/review_provider.dart';

class ReviewActionsDialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required Review review,
    required Place place,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ReviewActionsContent(
        review: review,
        place: place,
        ref: ref,
      ),
    );
  }
}

class _ReviewActionsContent extends StatelessWidget {
  final Review review;
  final Place place;
  final WidgetRef ref;

  const _ReviewActionsContent({
    required this.review,
    required this.place,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Kelola Ulasan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Edit Action
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: const Text(
              'Edit Ulasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text('Ubah penilaian atau komentar Anda'),
            onTap: () {
              Navigator.of(context).pop(); // Tutup bottom sheet
              showDialog(
                context: context,
                builder: (context) => EditReviewDialog(
                  review: review,
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Delete Action
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 20,
              ),
            ),
            title: const Text(
              'Hapus Ulasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text('Hapus ulasan ini secara permanen'),
            onTap: () {
              Navigator.of(context).pop(); // Tutup bottom sheet
              _showDeleteConfirmation(context, ref, review);
            },
          ),
          
          const SizedBox(height: 20),
          
          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Ulasan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus ulasan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup dialog konfirmasi
              
              final success = await ref.read(reviewProvider.notifier).deleteReview(
                review.id,
                review.userId,
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ulasan berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                final error = ref.read(reviewProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus ulasan: ${error ?? 'Terjadi kesalahan'}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}