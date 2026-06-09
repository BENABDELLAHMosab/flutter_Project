import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Constants.userPrefKey, user.id!);
    await prefs.setString(Constants.rolePrefKey, user.role);
    await prefs.setString(Constants.emailPrefKey, user.email);
    await prefs.setString(Constants.namePrefKey, user.fullName);
  }

  Future<UserModel?> login(String email, String password) async {
    final user = await _db.loginUser(email, password);
    if (user != null && user.id != null) {
      await _saveUserSession(user);
      return user;
    }
    return null;
  }

  Future<bool> register(UserModel user) async {
    final existingUser = await _db.getUserByEmail(user.email);
    if (existingUser != null) {
      return false; // Email already exists
    }
    // Ensures role is always client when registering naturally
    final clientUser = user.copyWith(role: 'client');
    await _db.registerUser(clientUser);
    return true;
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null && firebaseUser.email != null) {
        UserModel? user = await _db.getUserByEmail(firebaseUser.email!);

        if (user == null) {
          // Create client user from Google info
          user = UserModel(
            fullName: firebaseUser.displayName ?? 'Utilisateur Google',
            email: firebaseUser.email!,
            password: 'google_oauth_password', // Mock password since we rely on Google
            role: 'client',
          );
          final id = await _db.registerUser(user);
          user = user.copyWith(id: id);
        }

        // Always force role to client for google sign-in users (safety net)
        if (user.role != 'client' && user.email != 'admin@booknest.com') {
          user = user.copyWith(role: 'client');
        }

        await _saveUserSession(user);
        return user;
      }
      return null;
    } catch (e) {
      print('Erreur Google Sign-In: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.userPrefKey);
    await prefs.remove(Constants.rolePrefKey);
    await prefs.remove(Constants.emailPrefKey);
    await prefs.remove(Constants.namePrefKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(Constants.userPrefKey);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.userPrefKey);
  }

  Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.rolePrefKey);
  }
  
  Future<Map<String, String>> getCurrentUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(Constants.namePrefKey) ?? 'Inconnu',
      'email': prefs.getString(Constants.emailPrefKey) ?? 'Email',
      'role': prefs.getString(Constants.rolePrefKey) ?? 'client',
    };
  }
}
