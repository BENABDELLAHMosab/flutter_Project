import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';
import '../utils/app_colors.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = await _authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou mot de passe incorrect'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.hotel, size: 80, color: AppColors.primaryColor),
                  const SizedBox(height: 32),
                  const Text(
                    'Bienvenue',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous pour continuer',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Email',
                    hint: 'votre@email.com',
                    prefixIcon: Icons.email,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    label: 'Mot de passe',
                    hint: '******',
                    prefixIcon: Icons.lock,
                    controller: _passwordController,
                    isPassword: true,
                    validator: Validators.validateRequired,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Se connecter',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Créer un compte'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
