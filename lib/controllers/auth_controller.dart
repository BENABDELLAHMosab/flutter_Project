import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userPrefKey, user.uid!);
    await prefs.setString(Constants.rolePrefKey, user.role);
    await prefs.setString(Constants.emailPrefKey, user.email);
    await prefs.setString(Constants.namePrefKey, user.fullName);
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'operation-not-allowed':
        return 'La connexion email/mot de passe n\'est pas activée dans Firebase.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Vérifiez votre connexion internet.';
      default:
        return 'Erreur Firebase : ${e.code}';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Erreur Reset: ${e.code}');
      throw _getFirebaseErrorMessage(e);
    } catch (e) {
      debugPrint('Erreur Reset: $e');
      throw 'Impossible d\'envoyer le lien de réinitialisation.';
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (userCredential.user != null) {
        final user = await _getUserFromFirestore(userCredential.user!.uid);
        if (user != null) {
          await _saveUserSession(user);
          return user;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Erreur Login: ${e.code}');
      throw _getFirebaseErrorMessage(e);
    } catch (e) {
      debugPrint('Erreur Login: $e');
      throw 'Erreur inattendue lors de la connexion.';
    }
  }

  Future<bool> register(UserModel userModel) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email.trim(),
        password: userModel.password!.trim(),
      );

      if (userCredential.user != null) {
        // Enforce client role, except for the explicit admin email matching our rules
        final String assignedRole = userModel.email.trim() == 'admin@booknest.com' ? 'admin' : 'client';
        
        final newUser = userModel.copyWith(
          uid: userCredential.user!.uid,
          role: assignedRole,
        );
        
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Erreur Register: ${e.code}');
      throw _getFirebaseErrorMessage(e);
    } catch (e) {
      debugPrint('Erreur Register: $e');
      throw 'Erreur inattendue lors de l\'inscription.';
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        UserModel? user = await _getUserFromFirestore(firebaseUser.uid);

        if (user == null) {
          // Create client user from Google info
          user = UserModel(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'Utilisateur Google',
            email: firebaseUser.email ?? '',
            role: 'client',
            photoUrl: firebaseUser.photoURL,
          );
          await _firestore.collection('users').doc(user.uid).set(user.toMap());
        } else {
          // Security enforcement: never allow an admin escalation here
          if (user.role != 'admin' || user.email != 'admin@booknest.com') {
            user = user.copyWith(role: 'client');
            await _firestore.collection('users').doc(user.uid).update({'role': 'client'});
          }
        }

        await _saveUserSession(user);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Erreur Google Sign-In: ${e.code}');
      throw _getFirebaseErrorMessage(e);
    } catch (e) {
      debugPrint('Erreur Google Sign-In: $e');
      throw 'Erreur inattendue lors de la connexion via Google.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.userPrefKey);
    await prefs.remove(Constants.rolePrefKey);
    await prefs.remove(Constants.emailPrefKey);
    await prefs.remove(Constants.namePrefKey);
  }

  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(Constants.userPrefKey);
  }

  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
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
