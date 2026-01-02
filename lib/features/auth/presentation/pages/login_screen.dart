import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/auth/presentation/pages/register_screen.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Call the Login method from your ViewModel
    ref.read(authViewModelProvider.notifier).login(
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Watch the state for loading indicators
    final authState = ref.watch(authViewModelProvider);

    // 4. Listen for changes (Success or Error)
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Login failed'), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 60),

                _buildLabel("User ID / Email"),
                const SizedBox(height: 8),
                TextField(
                  controller: _userController,
                  decoration: _inputDecoration("Enter your userID"),
                ),
                const SizedBox(height: 20),

                _buildLabel("Password"),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Enter your password"),
                ),
                const SizedBox(height: 40),

                // SIGN IN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading 
                        ? null 
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CA8E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Navigate to Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color.fromARGB(255, 11, 89, 153),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}