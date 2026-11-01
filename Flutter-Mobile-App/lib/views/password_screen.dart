import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'review_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _showErrors = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue(ApplyViewModel viewModel) {
    setState(() {
      _showErrors = true;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    if (!isValid) return;

    viewModel.password = _passwordController.text;
    viewModel.confirmPassword = _confirmPasswordController.text;

    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('PTO Application - Security', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                child: const Text('Create Password', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Password'),
                    _buildTextField(_passwordController, isObscure: true, isRequired: true, showErrors: _showErrors, customError: _passwordError),
                    const SizedBox(height: 16),
                    _buildLabel('Confirm Password'),
                    _buildTextField(_confirmPasswordController, isObscure: true, isRequired: true, showErrors: _showErrors, customError: _confirmPasswordError),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), border: Border(top: BorderSide(color: Colors.grey.shade400))),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleContinue(viewModel),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9C9C9), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Save and Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)));
  }

  Widget _buildTextField(TextEditingController controller, {bool isObscure = false, bool isRequired = false, bool showErrors = false, String? customError}) {
    bool hasError = (isRequired && showErrors && controller.text.isEmpty) || customError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE0E0E0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6), 
              borderSide: hasError ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        if (hasError && (controller.text.isEmpty || customError != null))
          Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(customError ?? 'This field is required', style: const TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }
}