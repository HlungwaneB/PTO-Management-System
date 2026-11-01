import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'dependent_info_screen.dart';
import 'documents_screen.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  final _cellphoneController = TextEditingController();
  final _confirmCellphoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _homeCellphoneController = TextEditingController();
  
  bool _showErrors = false;
  String? _phoneError;
  String? _confirmPhoneError;
  String? _emailError;
  String? _siteError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplyViewModel>().fetchSites();
    });
  }

  @override
  void dispose() {
    _cellphoneController.dispose();
    _confirmCellphoneController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _homeCellphoneController.dispose();
    super.dispose();
  }

  void _handleContinue(ApplyViewModel viewModel) {
    setState(() {
      _showErrors = true;
      _phoneError = null;
      _confirmPhoneError = null;
      _emailError = null;
      _siteError = null;
    });

    bool isValid = true;

    if (!RegExp(r'^0\d{9}$').hasMatch(_cellphoneController.text)) {
      setState(() => _phoneError = 'Must be 10 digits starting with 0');
      isValid = false;
    }
    if (_cellphoneController.text != _confirmCellphoneController.text) {
      setState(() => _confirmPhoneError = 'Numbers do not match');
      isValid = false;
    }
    if (_emailController.text != _confirmEmailController.text || _emailController.text.isEmpty) {
      setState(() => _emailError = 'Emails do not match or are empty');
      isValid = false;
    }
    if (viewModel.selectedSiteId.isEmpty) {
      setState(() => _siteError = 'Please select a site');
      isValid = false;
    }

    if (!isValid) return;

    viewModel.cellphone = _cellphoneController.text;
    viewModel.email = _emailController.text;
    viewModel.homeCellphone = _homeCellphoneController.text;

    if (viewModel.isDependant == 'Yes') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DependentInfoScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('PTO Application - Contact', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: const Text('PTO Application', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Select Site *'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0), 
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _siteError != null ? Colors.red : Colors.transparent, width: 2)
                      ),
                      child: viewModel.isLoadingSites
                          ? const Padding(padding: EdgeInsets.all(12.0), child: LinearProgressIndicator())
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: viewModel.selectedSiteId.isEmpty ? null : viewModel.selectedSiteId,
                                hint: const Text('Choose a site...', style: TextStyle(fontSize: 13)),
                                items: viewModel.availableSites.map((site) => DropdownMenuItem<String>(value: site['site_id'].toString(), child: Text('${site['site_name']} - ${site['location']}', style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (value) {
                                  viewModel.selectedSiteId = value ?? '';
                                  viewModel.notifyListeners();
                                },
                              ),
                            ),
                    ),
                    if (_siteError != null) Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(_siteError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                    
                    const SizedBox(height: 16),
                    _buildLabel('Cellphone'),
                    _buildTextField(_cellphoneController, isNumber: true, maxLength: 10, isRequired: true, showErrors: _showErrors, customError: _phoneError),
                    const SizedBox(height: 12),
                    _buildLabel('Confirm cellphone'),
                    _buildTextField(_confirmCellphoneController, isNumber: true, maxLength: 10, isRequired: true, showErrors: _showErrors, customError: _confirmPhoneError),
                    const SizedBox(height: 12),
                    _buildLabel('E-mail address'),
                    _buildTextField(_emailController, isRequired: true, showErrors: _showErrors),
                    const SizedBox(height: 12),
                    _buildLabel('Confirm e-mail address'),
                    _buildTextField(_confirmEmailController, isRequired: true, showErrors: _showErrors, customError: _emailError),
                    const SizedBox(height: 12),
                    _buildLabel('Home cellphone'),
                    _buildTextField(_homeCellphoneController),
                    const SizedBox(height: 16),
                    _buildLabel('Are you dependant'),
                    Row(
                      children: [
                        _buildDependantOption('Yes'),
                        const SizedBox(width: 30),
                        _buildDependantOption('No'),
                      ],
                    ),
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

  Widget _buildDependantOption(String value) {
    return GestureDetector(
      onTap: () {
        final viewModel = context.read<ApplyViewModel>();
        viewModel.toggleRadio('dependant', value);
      },
      child: Row(
        children: [
          Icon(context.watch<ApplyViewModel>().isDependant == value ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: context.watch<ApplyViewModel>().isDependant == value ? const Color(0xFFE87A2D) : Colors.grey),
          const SizedBox(width: 4),
          Text(value.toUpperCase(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)));
  }

  Widget _buildTextField(TextEditingController controller, {bool isNumber = false, int maxLength = 100, bool isRequired = false, bool showErrors = false, String? customError}) {
    bool hasError = (isRequired && showErrors && controller.text.isEmpty) || customError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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