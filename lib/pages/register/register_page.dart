import "package:flutter/material.dart";
import "package:j_tour/pages/login/login_page.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;

  static const Color primaryColor = Color.fromRGBO(0, 111, 185, 1);

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: primaryColor),
      prefixIcon: Icon(prefixIcon, color: primaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: _buildBorder(primaryColor),
      enabledBorder: _buildBorder(primaryColor),
      focusedBorder: _buildBorder(primaryColor),
    );
  }

  OutlineInputBorder _buildBorder(borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: borderColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Papuma.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(color: Colors.black.withOpacity(0.2)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Buat Akun!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_circle_left_outlined,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Buat akun Anda dan buat liburan Anda lebih mudah dan nyaman",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input field for email
                  TextFormField(
                    decoration: _buildInputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Input field for username
                  TextFormField(
                    decoration: _buildInputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Input field for password
                  TextFormField(
                    obscureText: !_passwordVisible,
                    decoration: _buildInputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.remove_red_eye_outlined
                              : Icons.visibility_off_outlined,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Input field for confirm password
                  TextFormField(
                    obscureText: !_passwordConfirmVisible,
                    decoration: _buildInputDecoration(
                      hintText: 'Konfirmasi Password',
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordConfirmVisible
                              ? Icons.remove_red_eye_outlined
                              : Icons.visibility_off_outlined,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordConfirmVisible = !_passwordConfirmVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "atau daftar dengan",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // register with google button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black54),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/google.png', height: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Daftar dengan Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Register Link
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "sudah mempunyai akun? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
