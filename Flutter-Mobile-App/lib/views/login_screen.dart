import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'main_shell.dart'; // 🟢 To navigate to Dashboard after login
import 'reliable_info_screen.dart'; // 🟢 To navigate to Apply
import 'home_screen.dart';
import 'forgot_password_screen.dart';  

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.login(_idController.text, _passwordController.text);

    if (success && mounted) {
      // 🟢 Navigate to Dashboard (MainShell)
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false
      );
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟢 BACK BUTTON
                                // 🟢 BACK BUTTON
                TextButton.icon(
                  onPressed: () {
                    // Explicitly go to HomeScreen and clear the stack
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false
                    );
                  },
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFE87A2D), size: 20),
                  label: const Text(
                    'Back',
                    style: TextStyle(color: Color(0xFFE87A2D), fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                
                const SizedBox(height: 40),

                // 🟢 LOGIN CARD
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo
                        Image.asset('assets/logo.png', height: 70, errorBuilder: (c, e, s) => const Icon(Icons.business, size: 70, color: Color(0xFFE87A2D))),
                        const SizedBox(height: 20),
                        
                        // Title
                        const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ID Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ID Number',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            TextField(
                              controller: _idController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFE87A2D), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Password Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFE87A2D), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),

                        // Forgot Password
                          Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // 🟢 Navigate to Forgot Password Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // LOG IN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: viewModel.isLoading ? null : _handleLogin,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: viewModel.isLoading
                                ? const CircularProgressIndicator(color: Color(0xFF1A1A1A))
                                : const Text(
                                    'LOG IN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Haven't you applied yet? ",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 🟢 Navigate to the Apply Wizard
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReliableInfoScreen()),
                          );
                        },
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            color: Color(0xFF1A1A1A), // Make sure it's visible
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}