import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:j_tour/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({
          'id': user.uid,
          ...doc.data() ?? {},
        });
      }

      return UserModel(
        id: user.uid,
        username: user.displayName ?? '',
        email: user.email ?? '',
        role: 'user', // Default role
      );
    });
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('No user found');
      }

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({
          'id': user.uid,
          ...doc.data() ?? {},
        });
      }

      return UserModel(
        id: user.uid,
        username: user.displayName ?? '',
        email: user.email ?? '',
        role: 'user',
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Register user with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Registration failed');
      }

      // Update display name
      await user.updateDisplayName(username);

      // Create user document in Firestore
      final userData = {
        'username': username,
        'email': email,
        'role': 'user', // Default role for regular users
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return UserModel(
        id: user.uid,
        username: username,
        email: email,
        role: 'user',
      );
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({
          'id': user.uid,
          ...doc.data() ?? {},
        });
      }

      return UserModel(
        id: user.uid,
        username: user.displayName ?? '',
        email: user.email ?? '',
        role: 'user',
      );
    } catch (e) {
      return null;
    }
  }
}
