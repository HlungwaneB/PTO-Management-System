import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; // 🟢 Import HomeScreen
import 'main_shell.dart'; // Keep this for auto-login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // 1. Wait for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // 2. Check if the user is already logged in
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is already logged in -> Go straight to Dashboard
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainShell())
      );
    } else {
      // 🟢 No user -> Go to the Home Screen (Landing Page)
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const HomeScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7A56B), // PTO Orange background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/logo.png', 
                height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.home_work, 
                  size: 80, 
                  color: Color(0xFFE87A2D)
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Text
            const Text(
              'P.T.O',
              style: TextStyle(
                fontSize: 42, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'Permit To Occupy',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w500, 
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Loading Indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}