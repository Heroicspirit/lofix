import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';

// 1. Change to ConsumerStatefulWidget
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 2. Extracted Signup Logic
  void _handleSignup() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || selectedGender == null) {
      _showSnippet("Please fill all fields");
      return;
    }
    if (password != confirmPassword) {
      _showSnippet("Passwords do not match!");
      return;
    }

    final username = email.split('@')[0];
    // Call view model register method
    ref.read(authViewModelProvider.notifier).register(
          email: email,
          username: username,
          password: password,
          // If your entity supports gender, pass it here
        );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Watch the state for loading indicators
    final authState = ref.watch(authViewModelProvider);

    // 4. Listen for Success or Error
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        _showSnippet("Account Created! Please Login");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (next.status == AuthStatus.error) {
        _showSnippet(next.errorMessage ?? "Registration failed");
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/images/logo.png', width: 70, height: 70),
            const SizedBox(height: 40),
            
            _buildLabel("Username or Email"),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration("Enter username or email"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Password"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("Enter password"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Confirm Password"),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Re-enter password"),
            ),
            const SizedBox(height: 20),

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
                // 5. Disable button or call handler based on loading state
                onPressed: authState.status == AuthStatus.loading 
                    ? null 
                    : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CA8E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: authState.status == AuthStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
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