import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'renew_screen.dart'; 
import 'tracking_screen.dart';
import '../services/pdf_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
    });
  }

  // De-register Logic
  void _showDeregisterDialog() {
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('De-register Application', style: TextStyle(color: Color(0xFFD62828), fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Are you sure you want to delete your application? This action cannot be undone. Please enter your password to confirm.', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    try {
                      // 1. Verify Password
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null || user.email == null) throw Exception("Not logged in");
                      
                      final authResponse = await Supabase.instance.client.auth.signInWithPassword(
                        email: user.email!,
                        password: passwordController.text,
                      );

                      if (authResponse.user == null) throw Exception("Incorrect password");

                      // Delete Application from Database
                      await Supabase.instance.client
                          .from('applications')
                          .delete()
                          .eq('id_number', user.email!.split('@').first);

                      //Log out
                      await Supabase.instance.client.auth.signOut();
                      
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => const LoginScreen()), 
                          (route) => false
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application deleted successfully.')));
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62828), foregroundColor: Colors.white),
                  child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirm Delete'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final app = viewModel.application;
    final site = viewModel.site;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ─── CUSTOM APP BAR ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('my', style: TextStyle(color: Color(0xFFE87A2D), fontStyle: FontStyle.italic, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('PTO', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
                            Container(margin: const EdgeInsets.symmetric(horizontal: 8), height: 24, width: 1, color: Colors.grey.shade400),
                            const Text('Mangaung', style: TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                        Image.asset('assets/logo.png', height: 30, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.green)),
                      ],
                    ),
                  ),
                  
                  // MAIN
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, ${viewModel.fullName}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 24),

                          const Text('My Application', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 4),
                          const Text('View & Track your Application', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 20),

                         
                          Row(
                            children: [
                              Expanded(child: _buildActionButton('Track Application', () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackingScreen()));
                              })),
                              const SizedBox(width: 16),
                              Expanded(child: _buildActionButton('Renew PTO', () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RenewScreen()));
                              })),
                            ],
                          ),
                          const SizedBox(height: 24),

                     
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Current Site', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 8),
                                Text(
                                  app != null && app['current_status'] == 'Approved' ? (site?['site_name'] ?? 'N/A') : 'Pending Approval', 
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 4),
                                Text(app != null && app['current_status'] == 'Approved' ? (site?['location'] ?? '') : '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lease Period Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lease period', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 8),
                                Text(
                                  app != null && app['current_status'] == 'Approved' 
                                      ? '${viewModel.formatDate(app['start_date'])} - ${viewModel.formatDate(app['end_date'])}' 
                                      : 'Pending Approval', 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 12),
                                
                
                                Row(
                                  children: [
                                    if (app != null && app['current_status'] == 'Approved')
                                      GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RenewScreen())),
                                        child: const Text('renewal', style: TextStyle(color: Color(0xFFE87A2D), fontSize: 14, fontWeight: FontWeight.bold)), // Underline removed here
                                      ),
                                    
                                    const SizedBox(width: 20),
                                    
                                    // De-register Link 
                                    GestureDetector(
                                      onTap: _showDeregisterDialog,
                                      child: const Text('De-register', style: TextStyle(color: Color(0xFFD62828), fontSize: 14, fontWeight: FontWeight.bold)), // Underline removed here
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Download Link (Only if Approved) 
                          if (app != null && app['current_status'] == 'Approved')
                            GestureDetector(
                              onTap: () {
                                PdfService.generateAndPrintLease(
                                  fullName: app['full_name'] ?? '',
                                  idNumber: app['id_number'] ?? '',
                                  phone: app['phone_number'] ?? '',
                                  email: app['email'] ?? '',
                                  siteName: site?['site_name'] ?? 'N/A',
                                  location: site?['location'] ?? 'N/A',
                                  sizeDetails: site?['size_details'] ?? 'N/A',
                                  startDate: DateTime.parse(app['start_date']),
                                  endDate: DateTime.parse(app['end_date']),
                                );
                              },
                              child: const Text('Download lease agreement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), // Underline removed here
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}