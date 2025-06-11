import 'package:flutter/material.dart';
import 'package:j_tour/pages/account/ganti_password.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final String initialName = 'Fairuz Zaki';
  final String initialEmail = 'fairuzzaki972@gmail.com';

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  String currentName = '';
  String currentEmail = '';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
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
            content: Text('Foto profil berhasil diubah'),
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

  void _submitForm() {
    final name = currentName.trim();
    final email = currentEmail.trim();

    if (name.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal isi salah satu: nama atau email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (name == initialName && email == initialEmail && _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perubahan yang dilakukan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Lakukan update (misalnya ke backend atau state app)
      // Di sini Anda bisa mengirim _profileImage ke server juga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
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
                          : null,
                    ),
                    child: _profileImage == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 40)
                        : null,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton('Ganti Foto', Icons.camera_alt_outlined,
                          () {
                        _showImagePickerOptions();
                      }),
                      const SizedBox(width: 16),
                      _actionButton('Ganti Password', Icons.lock_outline, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage()),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Nama
                  TextFormField(
                    controller: _nameController,
                    onChanged: (value) {
                      setState(() {
                        currentName = value;
                      });
                    },
                    decoration: _inputDecoration('Nama'),
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    onChanged: (value) {
                      setState(() {
                        currentEmail = value;
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          !_isValidEmail(value.trim())) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
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
    );
  }

  Widget _actionButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.blue, size: 16),
          ],
        ),
      ),
    );
  }
}
