import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'contact_info_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _surnameController = TextEditingController();
  final _initialsController = TextEditingController();
  final _firstNamesController = TextEditingController();
  final _dobYearController = TextEditingController();
  final _dobMonthController = TextEditingController();
  final _dobDayController = TextEditingController();
  final _idNumberController = TextEditingController();
  
  String? _selectedTitle;
  String? _selectedGender;
  bool _showErrors = false;
  
  String? _dobError;
  String? _genderError;
  String? _idError;

  @override
  void dispose() {
    _surnameController.dispose();
    _initialsController.dispose();
    _firstNamesController.dispose();
    _dobYearController.dispose();
    _dobMonthController.dispose();
    _dobDayController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _handleContinue(ApplyViewModel viewModel) {
    setState(() {
      _showErrors = true;
      _dobError = null;
      _genderError = null;
      _idError = null;
    });

    if (_surnameController.text.isEmpty || _firstNamesController.text.isEmpty || _idNumberController.text.isEmpty || _selectedGender == null || _dobYearController.text.isEmpty || _dobMonthController.text.isEmpty || _dobDayController.text.isEmpty) {
      return; 
    }

    if (_idNumberController.text.length != 13) {
      setState(() => _idError = 'ID Number must be exactly 13 digits');
      return;
    }

    try {
      DateTime dobFromId = DateTime(int.parse(_dobYearController.text), int.parse(_dobMonthController.text), int.parse(_dobDayController.text));
      String yy = _idNumberController.text.substring(0, 2);
      String mm = _idNumberController.text.substring(2, 4);
      String dd = _idNumberController.text.substring(4, 6);
      int yearFull = int.parse(yy) <= 25 ? 2000 + int.parse(yy) : 1900 + int.parse(yy);
      DateTime dobFromIdNum = DateTime(yearFull, int.parse(mm), int.parse(dd));

      if (dobFromId.day != dobFromIdNum.day || dobFromId.month != dobFromIdNum.month || dobFromId.year != dobFromIdNum.year) {
        setState(() => _dobError = 'Date does not match ID Number');
        return;
      }

      int genderNum = int.parse(_idNumberController.text.substring(6, 10));
      String genderFromId = genderNum >= 5000 ? 'Male' : 'Female';
      if (_selectedGender != genderFromId) {
        setState(() => _genderError = 'ID indicates $genderFromId');
        return;
      }

      DateTime today = DateTime.now();
      int age = today.year - dobFromId.year;
      if (dobFromId.month > today.month || (dobFromId.month == today.month && dobFromId.day > today.day)) age--;
      if (age < 21) {
        setState(() => _dobError = 'You must be 21 or older (You are $age)');
        return;
      }

      viewModel.surname = _surnameController.text;
      viewModel.initials = _initialsController.text;
      viewModel.title = _selectedTitle ?? '';
      viewModel.firstNames = _firstNamesController.text;
      viewModel.idNumber = _idNumberController.text;
      viewModel.gender = _selectedGender!;
      viewModel.dateOfBirth = dobFromId;

      Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactInfoScreen()));
    } catch (e) {
      setState(() => _dobError = 'Invalid date format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('PTO Application - Personal', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    _buildLabel('Surname'),
                    _buildTextField(_surnameController, isRequired: true, showErrors: _showErrors),
                    const SizedBox(height: 12),
                    _buildLabel('Initials'),
                    _buildTextField(_initialsController, maxLength: 10),
                    const SizedBox(height: 12),
                    _buildLabel('Title'),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(filled: true, fillColor: const Color(0xFFE0E0E0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      value: ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'].contains(_selectedTitle) ? _selectedTitle : null,
                      hint: const Text('Select Title...'),
                      items: ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedTitle = val),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('First name(s)'),
                    _buildTextField(_firstNamesController, isRequired: true, showErrors: _showErrors),
                    const SizedBox(height: 12),
                    _buildLabel('Date of Birth (yyyy/mm/dd)'),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_dobYearController, hint: 'YYYY', isNumber: true, maxLength: 4, isRequired: true, showErrors: _showErrors)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('/', style: TextStyle(fontSize: 18))),
                        Expanded(child: _buildTextField(_dobMonthController, hint: 'MM', isNumber: true, maxLength: 2, isRequired: true, showErrors: _showErrors)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('/', style: TextStyle(fontSize: 18))),
                        Expanded(child: _buildTextField(_dobDayController, hint: 'DD', isNumber: true, maxLength: 2, isRequired: true, showErrors: _showErrors)),
                      ],
                    ),
                    if (_showErrors && (_dobError != null || _dobYearController.text.isEmpty || _dobMonthController.text.isEmpty || _dobDayController.text.isEmpty))
                      const Padding(padding: EdgeInsets.only(top: 4, left: 4), child: Text('Date of Birth is required', style: TextStyle(color: Colors.red, fontSize: 12))),
                    if (_dobError != null)
                      Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(_dobError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                    
                    const SizedBox(height: 12),
                    _buildLabel('ID number / Passport'),
                    _buildTextField(_idNumberController, isNumber: true, maxLength: 13, isRequired: true, showErrors: _showErrors, customError: _idError),
                    const SizedBox(height: 16),
                    _buildLabel('Gender'),
                    Row(
                      children: [
                        _buildGenderOption('Male'),
                        const SizedBox(width: 30),
                        _buildGenderOption('Female'),
                      ],
                    ),
                    if (_showErrors && _selectedGender == null)
                      const Padding(padding: EdgeInsets.only(top: 4, left: 4), child: Text('Gender is required', style: TextStyle(color: Colors.red, fontSize: 12))),
                    if (_genderError != null)
                      Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(_genderError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
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

  Widget _buildGenderOption(String value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Row(
        children: [
          Icon(_selectedGender == value ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: _selectedGender == value ? const Color(0xFFE87A2D) : Colors.grey),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)));
  }

  Widget _buildTextField(TextEditingController controller, {String? hint, bool isNumber = false, int maxLength = 100, bool isRequired = false, bool showErrors = false, String? customError}) {
    bool hasError = (isRequired && showErrors && controller.text.isEmpty) || customError != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          onChanged: (_) {},
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
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