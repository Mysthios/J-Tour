import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:j_tour/core/constan.dart';

class ImagePickerWidgets extends StatelessWidget {
  final File? selectedImage;
  final String? existingImageUrl; // Tambahkan parameter untuk URL gambar dari API
  final List<String> additionalImages;
  final Function(File?) onMainImageChanged;
  final Function(List<String>) onAdditionalImagesChanged;

  const ImagePickerWidgets({
    Key? key,
    required this.selectedImage,
    this.existingImageUrl, // Parameter opsional untuk URL gambar dari API
    required this.additionalImages,
    required this.onMainImageChanged,
    required this.onAdditionalImagesChanged,
  }) : super(key: key);

  void _showMainImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: kBlackColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pilih Foto Utama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih sumber foto untuk gambar utama',
                style: TextStyle(
                  fontSize: 14,
                  color: kBlackColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _modernImagePickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      subtitle: 'Ambil foto baru',
                      onTap: () => _pickMainImage(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _modernImagePickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      subtitle: 'Pilih dari galeri',
                      onTap: () => _pickMainImage(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAdditionalImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: kBlackColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tambah Foto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih sumber foto tambahan',
                style: TextStyle(
                  fontSize: 14,
                  color: kBlackColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _modernImagePickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      subtitle: 'Ambil foto baru',
                      onTap: () => _pickAdditionalImage(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _modernImagePickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      subtitle: 'Pilih dari galeri',
                      onTap: () => _pickAdditionalImage(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _modernImagePickerOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBlackColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: kBlackColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kBlackColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: kBlackColor.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMainImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final mimeType = lookupMimeType(pickedFile.path);
        print('Picked main image: ${pickedFile.path} (MIME: $mimeType)');
        if (mimeType != null && mimeType.startsWith('image/')) {
          onMainImageChanged(File(pickedFile.path));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Foto utama berhasil diubah'),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          throw Exception('Hanya file gambar (JPEG, PNG, WebP) yang diizinkan');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Gagal memilih gambar: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _pickAdditionalImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = source == ImageSource.gallery
          ? await picker.pickMultiImage(
              maxWidth: 1200,
              maxHeight: 800,
              imageQuality: 80,
            )
          : [
              await picker.pickImage(
                source: source,
                maxWidth: 1200,
                maxHeight: 800,
                imageQuality: 80,
              ),
            ].whereType<XFile>().toList();

      if (pickedFiles.isNotEmpty) {
        final updatedImages = List<String>.from(additionalImages);
        final invalidFiles = <String>[];
        for (var file in pickedFiles) {
          final mimeType = lookupMimeType(file.path);
          print('Picked additional image: ${file.path} (MIME: $mimeType)');
          if (mimeType != null && mimeType.startsWith('image/')) {
            updatedImages.add(file.path);
          } else {
            invalidFiles.add(file.path);
          }
        }

        if (invalidFiles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Beberapa file bukan gambar (JPEG, PNG, WebP)')),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        if (updatedImages.length > 10) {
          updatedImages.removeRange(10, updatedImages.length);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Maksimum 10 foto tambahan'),
                ],
              ),
              backgroundColor: Colors.orange[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        if (updatedImages.length > additionalImages.length) {
          onAdditionalImagesChanged(updatedImages);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${updatedImages.length - additionalImages.length} foto tambahan ditambahkan'),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Gagal memilih gambar: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _removeAdditionalImage(int index) {
    final updatedImages = List<String>.from(additionalImages);
    updatedImages.removeAt(index);
    onAdditionalImagesChanged(updatedImages);
  }

  // Helper method untuk menentukan apakah string adalah URL
  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // Widget untuk menampilkan gambar berdasarkan jenis (File atau URL)
  Widget _buildImageWidget({
    required String? imagePath,
    File? imageFile,
    required double width,
    required double height,
    required BorderRadius borderRadius,
    BoxFit fit = BoxFit.cover,
  }) {
    // Prioritas: File lokal > URL dari API
    if (imageFile != null) {
      return Image.file(
        imageFile,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: kBlackColor.withOpacity(0.1),
          ),
          child: Icon(
            Icons.error_rounded,
            size: 48,
            color: kBlackColor.withOpacity(0.4),
          ),
        ),
      );
    } else if (imagePath != null && imagePath.isNotEmpty) {
      if (_isUrl(imagePath)) {
        // Gambar dari URL API
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: kBlackColor.withOpacity(0.1),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: kBlackColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.error_rounded,
              size: 48,
              color: kBlackColor.withOpacity(0.4),
            ),
          ),
        );
      } else {
        // Gambar dari path lokal
        return Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: kBlackColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.error_rounded,
              size: 48,
              color: kBlackColor.withOpacity(0.4),
            ),
          ),
        );
      }
    }

    // Placeholder jika tidak ada gambar
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBlackColor.withOpacity(0.1),
            kBlackColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_rounded,
            size: 48,
            color: kBlackColor.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Foto Utama',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kBlackColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kBlackColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  width: 240,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kWhiteColor,
                    border: Border.all(
                      color: kBlackColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImageWidget(
                      imagePath: existingImageUrl,
                      imageFile: selectedImage,
                      width: 240,
                      height: 180,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showMainImagePickerOptions(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kBlueColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kBlackColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: kBlueColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Foto Tambahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kBlackColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kBlackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${additionalImages.length}/10',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kBlackColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: additionalImages.length + 1,
            itemBuilder: (context, index) {
              if (index == additionalImages.length) {
                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showAdditionalImagePickerOptions(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kBlackColor.withOpacity(0.1),
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kBlackColor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: kBlackColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: kBlackColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah\nFoto',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: kBlackColor.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              final imagePath = additionalImages[index];
              return Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kBlackColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildImageWidget(
                          imagePath: imagePath,
                          imageFile: null,
                          width: 120,
                          height: 120,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _removeAdditionalImage(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
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
      ],
    );
  }
}