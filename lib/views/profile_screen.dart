import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthController().logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: false, // In bottom nav
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Utilisateur BookNest',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primaryColor),
              title: const Text('Dashboard / Admin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primaryColor),
              title: const Text('Paramètres'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.primaryColor),
              title: const Text('Aide et support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
