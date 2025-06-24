// 1. HALAMAN RESET PASSWORD BARU
// File: pages/auth/reset_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/providers/auth_provider.dart';
import 'package:j_tour/pages/login/login_page.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? oobCode; // Code dari email reset
  final String? email; // Email user

  const ResetPasswordPage({
    super.key,
    this.oobCode,
    this.email,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isCodeVerified = false;
  String? _verifiedEmail;

  static const Color primaryColor = Color.fromRGBO(0, 111, 185, 1);

  @override
  void initState() {
    super.initState();
    _verifyResetCode();
  }

  Future<void> _verifyResetCode() async {
    if (widget.oobCode == null) {
      _showError("Kode reset tidak valid");
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.verifyPasswordResetCode(widget.oobCode!);

    if (result != null && result['success'] == true) {
      setState(() {
        _isCodeVerified = true;
        _verifiedEmail = result['email'];
      });
    } else {
      _showError(result?['message'] ??
          "Kode reset tidak valid atau sudah kedaluwarsa");
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isCodeVerified) return;

    final authNotifier = ref.read(authProvider.notifier);
    bool success = await authNotifier.confirmPasswordReset(
      oobCode: widget.oobCode!,
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      final errorMessage = ref.read(authProvider).errorMessage ??
          "Gagal mereset password. Silakan coba lagi.";
      _showError(errorMessage);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Password Berhasil Direset",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "Password Anda telah berhasil direset. Silakan login dengan password baru Anda.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Login Sekarang"),
          ),
        ],
      ),
    );
  }

  // Validasi kekuatan password
  Widget _buildPasswordStrengthIndicator(String password) {
    final authNotifier = ref.read(authProvider.notifier);
    final validation = authNotifier.validatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Kekuatan Password: ", style: TextStyle(fontSize: 12)),
            Text(
              validation['strengthText'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: validation['strengthColor'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: validation['strength'] / 5.0,
          backgroundColor: Colors.grey[300],
          valueColor:
              AlwaysStoppedAnimation<Color>(validation['strengthColor']),
        ),
        if (validation['messages'].isNotEmpty) ...[
          const SizedBox(height: 8),
          ...validation['messages']
              .map<Widget>((msg) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(msg,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.orange)),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: primaryColor),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: !_isCodeVerified
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Memverifikasi kode reset..."),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Buat Password Baru",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_verifiedEmail != null)
                        Text(
                          "Untuk akun: $_verifiedEmail",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 32),

                      // Password Baru
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_newPasswordVisible,
                        enabled: !authState.isLoading,
                        onChanged: (value) =>
                            setState(() {}), // Untuk update strength indicator
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }

                          final validation = ref
                              .read(authProvider.notifier)
                              .validatePasswordStrength(value);

                          if (!validation['isValid']) {
                            return 'Password tidak memenuhi kriteria keamanan';
                          }
                          return null;
                        },
                        decoration: _inputDecoration(
                          hintText: "Password Baru",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _newPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _newPasswordVisible = !_newPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      // Password Strength Indicator
                      if (_newPasswordController.text.isNotEmpty)
                        _buildPasswordStrengthIndicator(
                            _newPasswordController.text),

                      const SizedBox(height: 16),

                      // Konfirmasi Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        enabled: !authState.isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Konfirmasi password tidak sesuai';
                          }
                          return null;
                        },
                        decoration: _inputDecoration(
                          hintText: "Konfirmasi Password Baru",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible =
                                    !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tombol Reset
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Tombol Kembali ke Login
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false,
                                );
                              },
                        child: const Text(
                          "Kembali ke Login",
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
