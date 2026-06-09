import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthController {
  final AppDatabase _db = AppDatabase.instance;

  Future<UserModel?> login(String email, String password) async {
    final user = await _db.loginUser(email, password);
    if (user != null && user.id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(Constants.userPrefKey, user.id!);
      return user;
    }
    return null;
  }

  Future<bool> register(UserModel user) async {
    final existingUser = await _db.getUserByEmail(user.email);
    if (existingUser != null) {
      return false; // Email already exists
    }
    await _db.registerUser(user);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.userPrefKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(Constants.userPrefKey);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.userPrefKey);
  }
}
