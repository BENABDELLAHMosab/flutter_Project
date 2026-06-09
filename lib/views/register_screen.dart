import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authController = AuthController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newUser = UserModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final success = await _authController.register(newUser);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        // Auto login after register
        await _authController.login(newUser.email, newUser.password);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cet email est déjà utilisé'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Rejoignez BookNest',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veuillez remplir les informations ci-dessous',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Nom complet',
                  hint: 'John Doe',
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  validator: Validators.validateName,
                ),
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
                  validator: Validators.validatePassword,
                ),
                CustomTextField(
                  label: 'Confirmer le mot de passe',
                  hint: '******',
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmController,
                  isPassword: true,
                  validator: (val) => Validators.validateConfirmPassword(val, _passwordController.text),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'S\'inscrire',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
