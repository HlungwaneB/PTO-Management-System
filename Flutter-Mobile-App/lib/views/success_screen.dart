import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'dashboard_screen.dart'; // To navigate back to dashboard/tracking
import 'home_screen.dart'; // To go back to home

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B), // Orange header
        title: const Text(
          'Application submitted',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back to the review screen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🟢 Green Checkmark
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E8B3E), // Green color
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Application submitted',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Reference number',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),

              // 🟢 Dynamic Reference Number
              Text(
                viewModel.idNumber.isNotEmpty ? viewModel.idNumber : '9812256548215',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE87A2D), // Orange text
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),

              // Info Text
              const Text(
                'You will be notified when the reviews your application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Track Application Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Tracking timeline (which is inside the Dashboard for now)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()), // Update to TrackingScreen later
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9C9C9),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Track my application', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Back Home Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Go back to Home and clear the whole wizard stack
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9C9C9),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Back home', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // 🟢 BOTTOM NAVIGATION BAR (Matching your screenshot)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A1A1A),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        // Highlighting the 'Application' icon since they just submitted
        currentIndex: 1, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 20), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description, size: 20), label: 'Application'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 20), label: 'Notifications'),
        ],
      ),
    );
  }
}