import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authProvider =
    ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());

enum UserRole { user, admin }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  UserRole? _userRole;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  Map<String, dynamic>? get user => _user;
  UserRole? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userRole == UserRole.admin;
  bool get isUser => _userRole == UserRole.user;
  bool get isInitialized => _isInitialized;
  bool get isEmailUser => _user?['provider']?.toString() == 'email';
  String? get displayName => _user?['displayName']?.toString();
  String? get email => _user?['email']?.toString();
  String? get photoURL => _user?['photoURL']?.toString();
  bool get emailVerified => _user?['emailVerified'] == true;
  String? get uid => _user?['uid']?.toString();
  String? get provider => _user?['provider']?.toString();

  // Additional getters for admin info
bool get isAdminVerified => _userRole == UserRole.admin && isAuthenticated;
String get userRoleString => _userRole?.toString().split('.').last ?? 'unknown';
  // // Admin credentials (for testing only, remove in production)
  // static const String adminEmail = "admin@jtour.com";
  // static const String adminPassword = "admin123456";

  AuthProvider() {
    _initializeAuth();
  }

  // Helper method to safely cast dynamic data
  Map<String, dynamic> _safeCastToStringMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      return <String, dynamic>{};
    }
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      bool isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _user = _safeCastToStringMap(userData);
          _determineUserRole(_user!);
        } else {
          await _authService.signOut();
        }
      }
    } catch (e) {
      print('Auth initialization error: $e');
      await _authService.signOut();
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  void _determineUserRole(Map<String, dynamic> user) {
    final customClaims = _safeCastToStringMap(user['customClaims'] ?? {});
    String? role = customClaims['role']?.toString();
    bool isAdminClaim = customClaims['isAdmin'] == true;
    String? provider = user['provider']?.toString();

    if (role == 'admin' || isAdminClaim || provider == 'admin') {
      _userRole = UserRole.admin;
    } else {
      _userRole = UserRole.user;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Register user
  Future<bool> registerUser({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.registerWithEmailPassword(
        email: email,
        name: name,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        final userData = _safeCastToStringMap(result['data']);
        if (userData.isNotEmpty) {
          _user = {
            'uid': userData['uid']?.toString() ?? '',
            'email': userData['email']?.toString() ?? email,
            'displayName': userData['displayName']?.toString() ?? name,
            'emailVerified': userData['emailVerified'] ?? false,
            'provider': userData['provider']?.toString() ?? 'email',
            'customClaims': userData['customClaims'] ?? {'role': 'user'},
          };
          _determineUserRole(_user!);
        }
        return true;
      } else {
        _setError(result['message']?.toString() ?? 'Registrasi gagal');
        return false;
      }
    } catch (e) {
      _setError('Registrasi gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final userData = _safeCastToStringMap(result['data']);
        if (userData.isNotEmpty) {
          _user = {
            'uid': userData['uid']?.toString() ?? '',
            'email': userData['email']?.toString() ?? email,
            'displayName': userData['displayName']?.toString() ?? '',
            'emailVerified': userData['emailVerified'] ?? false,
            'provider': userData['provider']?.toString() ?? 'email',
            'customClaims': userData['customClaims'] ?? {'role': 'user'},
          };
          await _loadUserProfile();
        }
        return true;
      } else {
        _setError(result['message']?.toString() ?? 'Login gagal');
        return false;
      }
    } catch (e) {
      _setError('Login gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.forgotPassword(email);

      if (result['success'] == true) {
        return true;
      } else {
        String errorMessage = result['message']?.toString() ??
            'Gagal mengirim email reset password';
        if (result['error'] == 'UNAUTHORIZED_CONTINUE_URI') {
          errorMessage = 'Konfigurasi server salah. Hubungi admin.';
        }
        _setError(errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Gagal mengirim email reset password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Admin login - gunakan endpoint admin yang baru
  Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Gunakan method adminLogin dari AuthService
      final result = await _authService.adminLogin(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final userData = _safeCastToStringMap(result['data']);
        if (userData.isNotEmpty) {
          _user = {
            'uid': userData['uid']?.toString() ?? '',
            'email': userData['email']?.toString() ?? email,
            'displayName': userData['displayName']?.toString() ?? 'Admin',
            'emailVerified': userData['emailVerified'] ?? true,
            'provider': userData['provider']?.toString() ?? 'admin',
            'customClaims': {'role': 'admin', 'isAdmin': true},
          };
          _userRole = UserRole.admin;
          notifyListeners();
        }
        return true;
      } else {
        _setError(result['message']?.toString() ?? 'Login admin gagal');
        return false;
      }
    } catch (e) {
      _setError('Login admin gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

// Check admin status dari server
  Future<bool> checkAdminStatus() async {
    try {
      final result = await _authService.checkAdminStatus();
      if (result['success'] == true) {
        final data = _safeCastToStringMap(result['data']);
        bool isAdminUser = data['isAdmin'] == true;

        if (isAdminUser && _userRole != UserRole.admin) {
          _userRole = UserRole.admin;
          notifyListeners();
        }

        return isAdminUser;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final result = await _authService.getUserProfile();
      if (result['success'] == true) {
        final userData = _safeCastToStringMap(result['data']);
        _user = {
          ..._user ?? {},
          ...userData,
        };
        _determineUserRole(_user!);

        await checkAdminStatus();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.signOut();

      if (result['success'] == true) {
        _user = null;
        _userRole = null;
        return true;
      } else {
        _setError(result['message']?.toString() ?? 'Logout gagal');
        return false;
      }
    } catch (e) {
      _setError('Logout gagal: ${e.toString()}');
      _user = null;
      _userRole = null;
      return true; // Consider logout successful if tokens are cleared
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (result['success'] == true) {
        final updatedData = _safeCastToStringMap(result['data']);
        if (updatedData.isNotEmpty) {
          _user = {
            ..._user!,
            ...updatedData,
          };
          _determineUserRole(_user!);
        }
        return true;
      } else {
        _setError(result['message']?.toString() ?? 'Gagal memperbarui profil');
        return false;
      }
    } catch (e) {
      _setError('Gagal memperbarui profil: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.deleteAccount();

      if (result['success'] == true) {
        _user = null;
        _userRole = null;
        return true;
      } else {
        _setError(result['message']?.toString() ?? 'Gagal menghapus akun');
        return false;
      }
    } catch (e) {
      _setError('Gagal menghapus akun: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _user = _safeCastToStringMap(userData);
        _determineUserRole(_user!);
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Force logout
  Future<void> forceLogout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error during force logout: $e');
    } finally {
      _user = null;
      _userRole = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Get current user role dari server
  Future<String?> getCurrentUserRole() async {
    try {
      final role = await _authService.getCurrentUserRole();
      return role;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Validate admin access
Future<bool> validateAdminAccess() async {
  if (!isAuthenticated) return false;
  
  try {
    bool isAdminUser = await _authService.isAdmin();
    if (isAdminUser && _userRole != UserRole.admin) {
      _userRole = UserRole.admin;
      notifyListeners();
    }
    return isAdminUser;
  } catch (e) {
    print('Error validating admin access: $e');
    return false;
  }
}

  // Check if user has specific role
  bool hasRole(UserRole role) {
    return _userRole == role;
  }
}
