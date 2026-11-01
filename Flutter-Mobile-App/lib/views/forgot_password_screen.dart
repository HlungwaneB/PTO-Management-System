import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _idController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    final idNumber = _idController.text.trim();

    if (idNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your ID Number')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get the real email from the applications table
      final appResponse = await Supabase.instance.client
          .from('applications')
          .select('email')
          .eq('id_number', idNumber)
          .maybeSingle();

      if (appResponse == null || appResponse['email'] == null) {
        throw Exception("No application found with this ID Number.");
      }
      final realEmail = appResponse['email'].toString();

      // 2. Generate the secure reset link via Edge Function
      final linkResponse = await Supabase.instance.client.functions.invoke(
        'get-reset-link',
        body: {'idNumber': idNumber}, // 🟢 Send ID instead of email
      );

      if (linkResponse.status != 200) {
        throw Exception("Could not generate reset link. Check the logs.");
      }

      final actionLink = linkResponse.data['actionLink'];
      if (actionLink == null) throw Exception("Invalid link generated.");

      // 3. Send the custom email via Brevo Edge Function to their REAL email
      final emailResponse = await Supabase.instance.client.functions.invoke(
        'send-brevo-email',
        body: {
          'to': realEmail,
          'name': 'PTO User',
          'subject': 'Reset Your PTO Password',
          'message': 'Click the link below to reset your password.',
          'html': '''
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
              <h2 style="color: #E87A2D;">PTO Management System</h2>
              <p>Hi there,</p>
              <p>You requested to reset your password. Click the button below to set a new password.</p>
              <a href="${actionLink}" style="display: inline-block; padding: 12px 24px; background-color: #E87A2D; color: white; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0;">Reset Password</a>
              <p style="color: #888; font-size: 12px;">If you didn't request this, you can safely ignore this email.</p>
            </div>
          ''',
        },
      );

      if (emailResponse.status != 200) {
        throw Exception("Failed to send email via Brevo.");
      }

      // 4. Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Sent'),
            content: Text('A password reset link has been sent to $realEmail. Please check your inbox.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE87A2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your ID Number. We will send a password reset link to the email address you used during your application.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // ID Input
            const Text('ID Number', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              maxLength: 13,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE87A2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}