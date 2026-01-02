import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controllers for all your fields
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? selectedGender;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Changed to black so it's visible
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/images/logo.png', width: 70, height: 70),
            const SizedBox(height: 40),
            
            // Username Field
            _buildLabel("Username or Email"),
            TextField(
              controller: _userController,
              decoration: _inputDecoration("Enter username or email"),
            ),
            const SizedBox(height: 20),

            // Password Field
            _buildLabel("Password"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("Enter password"),
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            _buildLabel("Confirm Password"),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Re-enter password"),
            ),
            const SizedBox(height: 20),

            // Gender Dropdown
            _buildLabel("Gender"),
            DropdownButtonFormField<String>(
              value: selectedGender,
              hint: const Text("Select gender"),
              items: const ["Male", "Female", "Others"]
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => selectedGender = value),
              decoration: _inputDecoration(""),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
                    _showSnippet("Please fill all fields");
                    return;
                  }
                  if (_passwordController.text != _confirmPasswordController.text) {
                    _showSnippet("Passwords do not match!");
                    return;
                  }
                  if (selectedGender == null) {
                    _showSnippet("Please select your gender");
                    return;
                  }
                  final box = Hive.box(HiveTableConstant.authBoxName);
                  
                  await box.put(_userController.text, {
                    'password': _passwordController.text,
                    'gender': selectedGender,
                  });

                  _showSnippet("Account Created! Please Login");
                  
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CA8E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showSnippet(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}