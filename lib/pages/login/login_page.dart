import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/main_page.dart';
import 'package:j_tour/pages/register/register_page.dart';// Import AdminHomePage
import 'package:j_tour/pages_admin/homepage/homepage.dart';
import 'package:j_tour/providers/auth_provider.dart';
import 'package:j_tour/providers/bottom_navbar_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotPasswordController = TextEditingController();
  bool _passwordVisible = false;

  static const Color primaryColor = Color.fromRGBO(0, 111, 185, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  void _login() async {
  if (_formKey.currentState!.validate()) {
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success = await authNotifier.loginUser(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      final authState = ref.read(authProvider);
      
      // Reset bottom nav index sebelum navigate
      ref.read(bottomNavBarProvider.notifier).updateIndex(0);
      
      // SEMUA USER (admin dan user biasa) diarahkan ke MainPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
      
      // Pesan berbeda untuk admin dan user
      if (authState.isAdmin) {
        _showSnackBar(
          message: "Login admin berhasil!",
          backgroundColor: Colors.green,
          duration: 2,
        );
      } else {
        _showSnackBar(
          message: "Login berhasil!",
          backgroundColor: Colors.green,
          duration: 2,
        );
      }
    } else {
      final errorMessage = ref.read(authProvider).errorMessage ??
          "Gagal login. Periksa email dan password.";
      _showSnackBar(
        message: errorMessage,
        backgroundColor: Colors.red,
        duration: 3,
      );
    }
  }
}


  void _handleForgotPassword() {
    if (ref.read(authProvider).isLoading) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Lupa Password",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "Masukkan email Anda untuk menerima link reset password."),
              const SizedBox(height: 16),
              TextFormField(
                controller: _forgotPasswordController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  hintText: "Email",
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _forgotPasswordController.clear();
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_forgotPasswordController.text.trim().isEmpty ||
                    !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(_forgotPasswordController.text.trim())) {
                  _showSnackBar(
                    message: "Masukkan email yang valid",
                    backgroundColor: Colors.red,
                    duration: 2,
                  );
                  return;
                }

                final authNotifier = ref.read(authProvider.notifier);
                bool success = await authNotifier.forgotPassword(
                  _forgotPasswordController.text.trim(),
                );

                if (!mounted) return;

                Navigator.pop(context);
                _forgotPasswordController.clear();

                if (success) {
                  _showSnackBar(
                    message: "Email reset password telah dikirim!",
                    backgroundColor: Colors.green,
                    duration: 3,
                  );
                } else {
                  final errorMessage = ref.read(authProvider).errorMessage ??
                      "Gagal mengirim email reset password.";
                  _showSnackBar(
                    message: errorMessage,
                    backgroundColor: Colors.red,
                    duration: 3,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: ref.watch(authProvider).isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required int duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToRegister() {
    if (ref.read(authProvider).isLoading) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordController.dispose();
    super.dispose();
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
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
    );
  }

  Widget _buildLoadingButton(String text) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: Image.asset(
                'assets/images/TelukLove.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.72,
                minChildSize: 0.72,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: const [0.72, 0.85],
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const Text(
                              "Selamat Datang!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Masuk ke akun Anda dan buat liburan Anda lebih mudah dan nyaman",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !authState.isLoading,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                              decoration: _inputDecoration(
                                hintText: "Email",
                                icon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              enabled: !authState.isLoading,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                              decoration: _inputDecoration(
                                hintText: "Password",
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: primaryColor,
                                  ),
                                  onPressed: authState.isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                ),
                              ),
                            ),
                            if (authState.errorMessage != null)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red[700], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authState.errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: authState.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                disabledBackgroundColor: Colors.grey[400],
                                elevation: 0,
                              ),
                              child: authState.isLoading
                                  ? _buildLoadingButton('Masuk')
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Belum punya akun? ",
                                    style: TextStyle(color: Colors.black54)),
                                GestureDetector(
                                  onTap: _navigateToRegister,
                                  child: Text(
                                    "Daftar",
                                    style: TextStyle(
                                      color: authState.isLoading
                                          ? Colors.grey
                                          : Colors.lightBlueAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: GestureDetector(
                                onTap: _handleForgotPassword,
                                child: Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    color: authState.isLoading
                                        ? Colors.grey
                                        : Colors.lightBlueAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom > 0
                                      ? 100
                                      : 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}