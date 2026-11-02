import 'package:flutter/material.dart';
import 'reliable_info_screen.dart'; // Ensure this is the correct path
import 'login_screen.dart'; 

import 'track_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── CUSTOM APP BAR ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'my ',
                          style: TextStyle(
                            color: Color(0xFFE87A2D),
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'PTO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 24,
                          width: 1,
                          color: Colors.grey.shade400,
                        ),
                        const Text(
                          'Mangaung',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/logo.png', 
                      height: 30,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.business, color: Colors.green),
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87A2D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // ─── HERO TEXT ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'P.T.O',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE87A2D),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Apply for, track and renew your Permission to Occupy — and see your property on the map — quickly, securely, from any device.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ─── ACTION BUTTONS ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    // Apply Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReliableInfoScreen()),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE87A2D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Track Application Button
                     Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // 🟢 Navigate to the Public Search Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TrackSearchScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Track application',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}