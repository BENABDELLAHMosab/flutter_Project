import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}
