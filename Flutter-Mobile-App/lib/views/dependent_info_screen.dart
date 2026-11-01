import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'documents_screen.dart';

class DependentInfoScreen extends StatefulWidget {
  const DependentInfoScreen({super.key});

  @override
  State<DependentInfoScreen> createState() => _DependentInfoScreenState();
}

class _DependentInfoScreenState extends State<DependentInfoScreen> {
  final _relationshipController = TextEditingController();
  final _surnameController = TextEditingController();
  final _initialsController = TextEditingController();
  final _firstNamesController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _cellphoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _showErrors = false;
  String? _idError;
  String? _phoneError;

  @override
  void dispose() {
    _relationshipController.dispose();
    _surnameController.dispose();
    _initialsController.dispose();
    _firstNamesController.dispose();
    _idNumberController.dispose();
    _cellphoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue(ApplyViewModel viewModel) {
    setState(() {
      _showErrors = true;
      _idError = null;
      _phoneError = null;
    });

    bool isValid = true;

    if (_relationshipController.text.isEmpty || _surnameController.text.isEmpty || _firstNamesController.text.isEmpty || _idNumberController.text.isEmpty || _cellphoneController.text.isEmpty) {
      isValid = false;
    }

    if (_idNumberController.text.length != 13 && _idNumberController.text.isNotEmpty) {
      setState(() => _idError = 'Must be exactly 13 digits');
      isValid = false;
    }

    if (!RegExp(r'^0\d{9}$').hasMatch(_cellphoneController.text) && _cellphoneController.text.isNotEmpty) {
      setState(() => _phoneError = 'Must be a valid 10-digit number');
      isValid = false;
    }

    if (!isValid) return;

    viewModel.kinRelationship = _relationshipController.text;
    viewModel.kinSurname = _surnameController.text;
    viewModel.kinInitials = _initialsController.text;
    viewModel.kinFirstNames = _firstNamesController.text;
    viewModel.kinIdNumber = _idNumberController.text;
    viewModel.kinCellphone = _cellphoneController.text;
    viewModel.kinEmail = _emailController.text;

    Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('PTO Application - Dependent', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: const Text('Dependent', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Relationship'),
                    _buildTextField(_relationshipController, isRequired: true, showErrors: _showErrors),
                    const SizedBox(height: 12),
                    _buildLabel('Surname'),
                    _buildTextField(_surnameController, isRequired: true, showErrors: _showErrors),
                    const SizedBox(height: 12),
                    _buildLabel('Initials'),
                    _buildTextField(_initialsController, maxLength: 10),
                    const SizedBox(height: 12),
                    _buildLabel('First name(s)'),
                    _buildTextField(_firstNamesController, isRequired: true, showErrors: _showErrors),
                    const SizedBox(height: 12),
                    _buildLabel('ID Number / Passport'),
                    _buildTextField(_idNumberController, isNumber: true, maxLength: 13, isRequired: true, showErrors: _showErrors, customError: _idError),
                    const SizedBox(height: 12),
                    _buildLabel('Contact number'),
                    _buildTextField(_cellphoneController, isNumber: true, maxLength: 10, isRequired: true, showErrors: _showErrors, customError: _phoneError),
                    const SizedBox(height: 12),
                    _buildLabel('Email-address'),
                    _buildTextField(_emailController, keyboardType: TextInputType.emailAddress),
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

  Widget _buildTextField(TextEditingController controller, {TextInputType? keyboardType, int maxLength = 100, bool isNumber = false, bool isRequired = false, bool showErrors = false, String? customError}) {
    bool hasError = (isRequired && showErrors && controller.text.isEmpty) || customError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE0E0E0),
            counterText: "", 
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