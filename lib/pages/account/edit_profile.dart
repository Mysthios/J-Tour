import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/account/ganti_password.dart';
import 'package:image_picker/image_picker.dart';
import 'package:j_tour/providers/auth_provider.dart';
import 'dart:io';
import 'dart:convert';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  String currentName = '';
  String currentEmail = '';
  File? _profileImage;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final auth = ref.read(authProvider);
    final initialName = auth.displayName ?? '';
    final initialEmail = auth.email ?? '';
    
    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    currentName = initialName;
    currentEmail = initialEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Fungsi untuk menampilkan dialog pilihan kamera atau gallery
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _imagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk option picker
  Widget _imagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mengambil gambar
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // Tutup bottom sheet
        Navigator.of(context).pop();

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil dipilih, jangan lupa simpan perubahan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk mengkonversi gambar ke base64
  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // Fungsi untuk memeriksa apakah ada perubahan
  bool _hasChanges() {
    final auth = ref.read(authProvider);
    final initialName = auth.displayName ?? '';
    final initialEmail = auth.email ?? '';
    
    return currentName.trim() != initialName ||
           currentEmail.trim() != initialEmail ||
           _profileImage != null;
  }

  void _submitForm() async {
    final name = currentName.trim();
    final email = currentEmail.trim();

    // Validasi input dasar
    if (name.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal isi salah satu: nama atau email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cek apakah ada perubahan
    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perubahan yang dilakukan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      String? photoURL;
      
      // Konversi gambar ke base64 jika ada
      if (_profileImage != null) {
        photoURL = await _convertImageToBase64(_profileImage!);
        if (photoURL == null) {
          throw Exception('Gagal memproses gambar');
        }
      }

      // Update profile menggunakan AuthProvider
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.updateProfile(
        displayName: name.isNotEmpty ? name : null,
        photoURL: photoURL,
      );

      if (success) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Kembali ke halaman sebelumnya
        Navigator.of(context).pop(true);
      } else {
        // Tampilkan error dari AuthProvider
        final auth = ref.read(authProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    
    return WillPopScope(
      onWillPop: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(const Duration(milliseconds: 200));
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F6F6),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Edit Profil',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _isUpdating ? null : () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Profile Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : (auth.photoURL != null && auth.photoURL!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(auth.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_profileImage == null && 
                           (auth.photoURL == null || auth.photoURL!.isEmpty))
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 40)
                        : null,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(
                        'Ganti Foto', 
                        Icons.camera_alt_outlined,
                        _isUpdating ? null : () {
                          _showImagePickerOptions();
                        }
                      ),
                      const SizedBox(width: 16),
                      _actionButton(
                        'Ganti Password', 
                        Icons.lock_outline, 
                        _isUpdating ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChangePasswordPage()),
                          );
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Nama
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isUpdating,
                    onChanged: (value) {
                      setState(() {
                        currentName = value;
                      });
                    },
                    decoration: _inputDecoration('Nama'),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        if (value.trim().length > 50) {
                          return 'Nama maksimal 50 karakter';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email (readonly karena biasanya email tidak bisa diubah)
                  TextFormField(
                    controller: _emailController,
                    enabled: false, // Email biasanya tidak bisa diubah
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email').copyWith(
                      filled: true,
                      fillColor: Colors.grey[100],
                      suffixIcon: const Icon(Icons.lock_outline, 
                                           color: Colors.grey, size: 16),
                    ),
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          !_isValidEmail(value.trim())) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email tidak dapat diubah untuk keamanan akun',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (auth.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        auth.errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap != null ? Colors.blue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: onTap != null ? Colors.blue : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon, 
              color: onTap != null ? Colors.blue : Colors.grey, 
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}