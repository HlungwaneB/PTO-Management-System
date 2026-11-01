import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'success_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    // Helper to get the site name from the selected ID
    String getSelectedSiteName() {
      if (viewModel.selectedSiteId.isEmpty) return 'Not selected';
      try {
        final site = viewModel.availableSites.firstWhere(
          (s) => s['site_id'].toString() == viewModel.selectedSiteId,
        );
        return '${site['site_name']} - ${site['location']}';
      } catch (e) {
        return 'Unknown Site';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B), // Orange header
        title: const Text(
          'PTO Application - Review',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2), // Grey background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'PTO Application - Review',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewRow('ID number', viewModel.idNumber),
                    _buildReviewRow('Title', viewModel.title),
                    _buildReviewRow('Initials', viewModel.initials),
                    _buildReviewRow('Name', viewModel.firstNames),
                    _buildReviewRow('Surname', viewModel.surname),
                    _buildReviewRow('Cell phone', viewModel.cellphone),
                    _buildReviewRow('Email', viewModel.email),
                    _buildReviewRow('Site', getSelectedSiteName()),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'By submitting you confirm the information is true and agrees to T&Cs.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Footer Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade400)),
                ),
                child: Row(
                  children: [
                    _buildFooterButton('Submit application', () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      // Call Supabase submit function
                      final success = await viewModel.submitApplication();

                      // Close loading dialog
                      if (mounted) Navigator.pop(context);

                      // Check if it worked
                      if (success && mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SuccessScreen()),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Submission failed. Please check your connection or ID number.')),
                        );
                      }
                    }, isPrimary: true),
                    const SizedBox(width: 8),
                    _buildFooterButton('Back', () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    _buildFooterButton('Cancel', () => Navigator.popUntil(context, (route) => route.isFirst)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String text, VoidCallback onTap, {bool isPrimary = false}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFC9C9C9) : const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}