import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://express-j-tour.vercel.app/api/auth';

  // Private variables for tracking refresh state
  static bool _isRefreshing = false;
  static List<Future Function()> _pendingRequests = [];

  // Helper method to safely cast to Map<String, dynamic>
  Map<String, dynamic> _safeCastToStringMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      return <String, dynamic>{};
    }
  }

  // Generic method for authenticated requests with auto token refresh
  Future<http.Response> _authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool isRetry = false,
  }) async {
    String? token = await _getTokenFromStorage();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };

    final uri = Uri.parse(endpoint);
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('HTTP method tidak didukung: $method');
    }

    // Handle token expired
    if (response.statusCode == 401 && !isRetry) {
      try {
        final responseData = _safeCastToStringMap(jsonDecode(response.body));

        if (responseData['error'] == 'INVALID_REFRESH_TOKEN' ||
            responseData['error'] == 'USER_NOT_FOUND' ||
            responseData['error'] == 'USER_DISABLED' ||
            responseData['error'] == 'ADMIN_ACCESS_REQUIRED' ||
            responseData['error'] == 'INSUFFICIENT_PERMISSIONS') {
          await _clearTokenStorage();
          throw Exception('Sesi kadaluarsa. Silakan login kembali.');
        }

        final refreshResult = await _refreshToken();

        if (refreshResult['success'] == true) {
          return await _authenticatedRequest(
            method: method,
            endpoint: endpoint,
            body: body,
            additionalHeaders: additionalHeaders,
            isRetry: true,
          );
        } else {
          await _clearTokenStorage();
          throw Exception('Sesi kadaluarsa. Silakan login kembali.');
        }
      } catch (e) {
        throw Exception('Gagal memproses permintaan: $e');
      }
    }

    return response;
  }

  // Method to refresh token
  Future<Map<String, dynamic>> _refreshToken() async {
    if (_isRefreshing) {
      return await _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      String? refreshToken = await _getRefreshTokenFromStorage();

      if (refreshToken == null) {
        return {'success': false, 'message': 'Refresh token tidak tersedia'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final responseData = _safeCastToStringMap(data['data']);
        if (responseData.isNotEmpty && responseData['accessToken'] != null) {
          await _saveTokenToStorage(responseData['accessToken'].toString());

          if (responseData['refreshToken'] != null) {
            await _saveRefreshTokenToStorage(
                responseData['refreshToken'].toString());
          }

          return {
            'success': true,
            'message': 'Token berhasil diperbarui',
            'token': responseData['accessToken'].toString(),
          };
        }
      }

      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Gagal memperbarui token',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui token: ${e.toString()}',
      };
    } finally {
      _isRefreshing = false;
      _processPendingRequests();
    }
  }

  // Wait for ongoing refresh to complete
  Future<Map<String, dynamic>> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return {'success': true};
  }

  // Process requests that were waiting for token refresh
  void _processPendingRequests() {
    for (var request in _pendingRequests) {
      request();
    }
    _pendingRequests.clear();
  }

  // Handle authentication failure
  Future<void> _handleAuthenticationFailure() async {
    await _clearTokenStorage();
  }

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return {
        'success': false,
        'message': 'Konfirmasi password tidak cocok',
      };
    }

    try {
      final requestBody = {
        'email': email,
        'name': name,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 201) {
        final userData = _safeCastToStringMap(data['data']);

        if (userData['accessToken'] != null) {
          await _saveTokenToStorage(userData['accessToken'].toString());
        }

        if (userData['refreshToken'] != null) {
          await _saveRefreshTokenToStorage(userData['refreshToken'].toString());
        }

        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Registrasi berhasil',
          'data': userData,
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Registrasi gagal',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Registrasi gagal: ${e.toString()}',
      };
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final userData = _safeCastToStringMap(data['data']);

        if (userData['accessToken'] != null) {
          await _saveTokenToStorage(userData['accessToken'].toString());
        }

        if (userData['refreshToken'] != null) {
          await _saveRefreshTokenToStorage(userData['refreshToken'].toString());
        }

        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Login berhasil',
          'data': userData,
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Login gagal',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login gagal: ${e.toString()}',
      };
    }
  }

  // Forgot Password - Request reset link
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message']?.toString() ??
              'Email reset password telah dikirim',
          'data': _safeCastToStringMap(data['data']),
        };
      } else {
        String errorMessage = data['message']?.toString() ??
            'Gagal mengirim email reset password';

        // Handle specific error cases
        if (data['error'] == 'USER_NOT_FOUND') {
          errorMessage = 'Email tidak terdaftar';
        } else if (data['error'] == 'UNAUTHORIZED_CONTINUE_URI') {
          errorMessage = 'Konfigurasi server salah. Hubungi admin.';
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': data['errors'],
          'error': data['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim email reset password: ${e.toString()}',
      };
    }
  }

// Verify Password Reset Code - Optional untuk validasi kode sebelum reset
  Future<Map<String, dynamic>> verifyPasswordResetCode(String oobCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'oobCode': oobCode,
        }),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Kode reset valid',
          'data': _safeCastToStringMap(data['data']),
        };
      } else {
        String errorMessage =
            data['message']?.toString() ?? 'Kode reset tidak valid';

        // Handle specific error cases
        if (data['error'] == 'INVALID_OOB_CODE') {
          errorMessage = 'Kode reset tidak valid';
        } else if (data['error'] == 'EXPIRED_OOB_CODE') {
          errorMessage = 'Kode reset sudah kedaluwarsa';
        }

        return {
          'success': false,
          'message': errorMessage,
          'error': data['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memverifikasi kode reset: ${e.toString()}',
      };
    }
  }

// Confirm Password Reset - Reset password dengan kode OOB dan password baru
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/confirm-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'oobCode': oobCode,
          'newPassword': newPassword,
        }),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Password berhasil direset',
          'data': _safeCastToStringMap(data['data']),
        };
      } else {
        String errorMessage =
            data['message']?.toString() ?? 'Gagal mereset password';

        // Handle specific error cases
        if (data['error'] == 'INVALID_OOB_CODE') {
          errorMessage = 'Kode reset tidak valid atau sudah kedaluwarsa';
        } else if (data['error'] == 'EXPIRED_OOB_CODE') {
          errorMessage = 'Kode reset sudah kedaluwarsa';
        } else if (data['error'] == 'WEAK_PASSWORD') {
          errorMessage = 'Password terlalu lemah';
        }

        return {
          'success': false,
          'message': errorMessage,
          'error': data['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mereset password: ${e.toString()}',
      };
    }
  }

// Helper method untuk extract oobCode dari deep link atau URL
  String? extractOobCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['oobCode'];
    } catch (e) {
      return null;
    }
  }

// Method untuk handle deep link reset password (jika menggunakan deep linking)
  Future<Map<String, dynamic>> handlePasswordResetDeepLink(
      String deepLink) async {
    try {
      final oobCode = extractOobCodeFromUrl(deepLink);

      if (oobCode == null) {
        return {
          'success': false,
          'message': 'Link reset password tidak valid',
        };
      }

      // Verify kode terlebih dahulu
      final verifyResult = await verifyPasswordResetCode(oobCode);

      if (verifyResult['success'] == true) {
        return {
          'success': true,
          'message': 'Link reset password valid',
          'data': {
            'oobCode': oobCode,
            'email': verifyResult['data']?['email'],
          },
        };
      } else {
        return verifyResult;
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses link reset password: ${e.toString()}',
      };
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _authenticatedRequest(
        method: 'GET',
        endpoint: '$baseUrl/profile',
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': _safeCastToStringMap(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Gagal mengambil profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil profil: ${e.toString()}',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (photoURL != null) body['photoURL'] = photoURL;

      final response = await _authenticatedRequest(
        method: 'PUT',
        endpoint: '$baseUrl/profile',
        body: body,
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message']?.toString() ?? 'Profil berhasil diperbarui',
          'data': _safeCastToStringMap(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui profil: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> signOut() async {
    try {
      try {
        await _authenticatedRequest(
          method: 'POST',
          endpoint: '$baseUrl/logout',
        );
      } catch (e) {
        // Silent error handling
      }

      await _clearTokenStorage();

      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    } catch (e) {
      await _clearTokenStorage();
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _authenticatedRequest(
        method: 'DELETE',
        endpoint: '$baseUrl/account',
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        await _clearTokenStorage();
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Akun berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Gagal menghapus akun',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus akun: ${e.toString()}',
      };
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      String? token = await _getTokenFromStorage();
      if (token == null) return false;

      final result = await getUserProfile();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final result = await getUserProfile();
      if (result['success'] == true) {
        return _safeCastToStringMap(result['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Admin Login
  Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final userData = _safeCastToStringMap(data['data']);

        if (userData['accessToken'] != null) {
          await _saveTokenToStorage(userData['accessToken'].toString());
        }

        if (userData['refreshToken'] != null) {
          await _saveRefreshTokenToStorage(userData['refreshToken'].toString());
        }

        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Login admin berhasil',
          'data': userData,
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Login admin gagal',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login admin gagal: ${e.toString()}',
      };
    }
  }

// Check admin status
  Future<Map<String, dynamic>> checkAdminStatus() async {
    try {
      final response = await _authenticatedRequest(
        method: 'GET',
        endpoint: '$baseUrl/admin/status',
      );

      final data = _safeCastToStringMap(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': _safeCastToStringMap(data['data']),
        };
      } else {
        return {
          'success': false,
          'message':
              data['message']?.toString() ?? 'Gagal mengecek status admin',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengecek status admin: ${e.toString()}',
      };
    }
  }

  // Helper method to check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final result = await checkAdminStatus();
      if (result['success'] == true) {
        final data = _safeCastToStringMap(result['data']);
        return data['isAdmin'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final result = await checkAdminStatus();
      if (result['success'] == true) {
        final data = _safeCastToStringMap(result['data']);
        return data['role']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Storage methods
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveRefreshTokenToStorage(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> _getRefreshTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> _clearTokenStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }
}
