import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:j_tour/models/review_model.dart';
import 'package:j_tour/providers/review_provider.dart';

class ReviewCard extends ConsumerWidget {
  final Review review;
  final bool showActions;
  final String? currentUserId;

  const ReviewCard({
    super.key,
    required this.review,
    this.showActions = true,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(reviewSubmittingProvider);
    final isUserReview =
        currentUserId != null && review.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_outline,
                    color: Colors.orange,
                    size: 16,
                  );
                }),
              ),

              // Action menu
              if (showActions && isUserReview) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context, ref);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, ref);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Review text
          Text(
            review.comment ?? '',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),

          // Review images - FIXED
          if (review.images != null && review.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images!.length,
                itemBuilder: (context, index) {
                  // Fixed: Remove the problematic hasUrl check
                  final imageUrl = _getImageUrl(review.images![index]);
                  print('Image URL at index $index: $imageUrl'); // Debug line

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          print('Image tapped at index: $index'); // Debug line
                          _viewImage(context, review.images!, index);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                      'Error loading image: $error'); // Debug line
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Overlay dengan ikon tap
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.7],
                                  ),
                                ),
                                child: const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Loading overlay
          if (isSubmitting)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Memproses...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // FIXED: Helper method untuk mendapatkan URL gambar
  String _getImageUrl(dynamic image) {
    if (image is String) {
      return image;
    } else if (image is Map) {
      return image['url'] ?? '';
    } else {
      // Fixed: Remove hasUrl check and use try-catch instead
      try {
        return image.url ?? '';
      } catch (e) {
        // Try alternative property names
        try {
          return image.imageUrl ?? '';
        } catch (e) {
          try {
            return image.path ?? '';
          } catch (e) {
            print('Unable to extract URL from image: $e');
            return '';
          }
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  void _viewImage(BuildContext context, List images, int initialIndex) {
    print('_viewImage called with initialIndex: $initialIndex'); // Debug line

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

// GANTI method _showEditDialog di ReviewCard dengan kode ini:

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss saat loading
      builder: (context) => EditReviewDialog(review: review),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ulasan'),
        content: const Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await ref.read(reviewProvider.notifier).deleteReview(
                        review.id,
                        review.userId,
                      );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Ulasan berhasil dihapus'
                        : 'Gagal menghapus ulasan'),
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

// FIXED: ImageViewer dengan perbaikan
class ImageViewer extends StatefulWidget {
  final List images;
  final int initialIndex;

  const ImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    print(
        'ImageViewer initialized with ${widget.images.length} images'); // Debug
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // FIXED: Helper method untuk mendapatkan URL gambar
  String _getImageUrl(dynamic image) {
    if (image is String) {
      return image;
    } else if (image is Map) {
      return image['url'] ?? '';
    } else {
      // Fixed: Remove hasUrl check and use try-catch instead
      try {
        return image.url ?? '';
      } catch (e) {
        // Try alternative property names
        try {
          return image.imageUrl ?? '';
        } catch (e) {
          try {
            return image.path ?? '';
          } catch (e) {
            print('Unable to extract URL from image: $e');
            return '';
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imageUrl = _getImageUrl(widget.images[index]);
              print('Displaying image at index $index: $imageUrl'); // Debug

              return Center(
                child: InteractiveViewer(
                  maxScale: 3.0,
                  minScale: 0.8,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error in ImageViewer: $error'); // Debug
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Navigation arrows
          if (widget.images.length > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // Page indicator
          if (widget.images.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// FIXED: EditReviewDialog dengan perbaikan
// GANTI bagian EditReviewDialog di review_card.dart dengan kode ini:

// GANTI bagian EditReviewDialog di review_card.dart dengan kode ini:
// GANTI bagian EditReviewDialog di review_card.dart dengan kode ini:

class EditReviewDialog extends ConsumerStatefulWidget {
  final Review review;

  const EditReviewDialog({super.key, required this.review});

  @override
  ConsumerState<EditReviewDialog> createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends ConsumerState<EditReviewDialog> {
  late TextEditingController _commentController;
  late int _rating;
  late List<dynamic> _currentImages; // Gambar existing yang akan dipertahankan
  List<File> _newImages = []; // Gambar baru yang dipilih
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.review.comment);
    _rating = widget.review.rating;
    // Copy existing images to editable list
    _currentImages = List.from(widget.review.images ?? []);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Helper method untuk mendapatkan URL gambar
  String _getImageUrl(dynamic image) {
    if (image is String) {
      return image;
    } else if (image is Map) {
      return image['url'] ?? '';
    } else {
      try {
        return image.url ?? '';
      } catch (e) {
        try {
          return image.imageUrl ?? '';
        } catch (e) {
          try {
            return image.path ?? '';
          } catch (e) {
            return '';
          }
        }
      }
    }
  }

  // Method untuk menghapus gambar existing
  void _removeExistingImage(int index) {
    setState(() {
      _currentImages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gambar dihapus'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Method untuk menghapus gambar baru
  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gambar baru dihapus'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Method untuk menambah gambar baru
  Future<void> _addNewImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (selectedImages.isNotEmpty) {
        // Convert XFile to File
        final List<File> newFiles =
            selectedImages.map((xfile) => File(xfile.path)).toList();

        // Batasi total gambar (existing + new) maksimal 5
        final totalImages =
            _currentImages.length + _newImages.length + newFiles.length;
        if (totalImages > 5) {
          final maxCanAdd = 5 - (_currentImages.length + _newImages.length);
          if (maxCanAdd > 0) {
            setState(() {
              _newImages.addAll(newFiles.take(maxCanAdd));
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Maksimal 5 gambar. Hanya $maxCanAdd gambar yang ditambahkan.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Maksimal 5 gambar. Hapus gambar lama untuk menambah yang baru.')),
            );
          }
        } else {
          setState(() {
            _newImages.addAll(newFiles);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar: $e')),
      );
    }
  }

  // Method untuk mengganti gambar existing
  Future<void> _replaceExistingImage(int index) async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (selectedImage != null) {
        setState(() {
          // Hapus gambar lama dan tambah gambar baru
          _currentImages.removeAt(index);
          _newImages.add(File(selectedImage.path)); // Convert XFile to File
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil diganti')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengganti gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(reviewSubmittingProvider);
    final totalImages = _currentImages.length + _newImages.length;

    return AlertDialog(
      title: const Text('Edit Ulasan'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Section
              const Text('Rating:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_outline,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Comment Section
              const Text('Komentar:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                enabled: !isSubmitting,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tulis ulasan Anda...',
                  isDense: true,
                ),
              ),

              // Images Section Header
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Gambar:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '$totalImages/5 foto',
                    style: TextStyle(
                        color: totalImages >= 5 ? Colors.red : Colors.grey[600],
                        fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Existing Images
              if (_currentImages.isNotEmpty) ...[
                const Text('Gambar Existing:',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _getImageUrl(_currentImages[index]);

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: Stack(
                          children: [
                            // Image
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _viewExistingImage(context, index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Action buttons
                            if (!isSubmitting) ...[
                              // Delete button
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                              // Replace button
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _replaceExistingImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // New Images
              if (_newImages.isNotEmpty) ...[
                const Text('Gambar Baru:',
                    style: TextStyle(fontSize: 12, color: Colors.green)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Stack(
                          children: [
                            // Image
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _viewNewImage(context, index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_newImages[index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Delete button
                            if (!isSubmitting)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            // New indicator
                            Positioned(
                              bottom: 2,
                              left: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BARU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Add Images Button
              if (totalImages < 5 && !isSubmitting)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addNewImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text('Tambah Gambar (${5 - totalImages} tersisa)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _updateReview,
          child: isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  void _viewExistingImage(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          images: _currentImages,
          initialIndex: index,
        ),
      ),
    );
  }

  void _viewNewImage(BuildContext context, int index) {
    // Create a temporary list of File paths as strings for ImageViewer
    List<String> newImagePaths = _newImages.map((file) => file.path).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocalImageViewer(
          imagePaths: newImagePaths,
          initialIndex: index,
        ),
      ),
    );
  }

  Future<void> _updateReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi komentar')),
      );
      return;
    }

    final success = await ref.read(reviewProvider.notifier).updateReview(
          reviewId: widget.review.id,
          userId: widget.review.userId,
          rating: _rating,
          comment: _commentController.text.trim(),
          existingImages: _currentImages
              .cast<ReviewImage>(), // Gambar existing yang dipertahankan
          newImages: _newImages, // Gambar baru yang ditambahkan (List<File>)
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui ulasan')),
      );
    }
  }
}

// Widget tambahan untuk melihat gambar lokal (gambar baru)
class LocalImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const LocalImageViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<LocalImageViewer> createState() => _LocalImageViewerState();
}

class _LocalImageViewerState extends State<LocalImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length} (Baru)',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              maxScale: 3.0,
              minScale: 0.8,
              child: Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Gagal memuat gambar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
