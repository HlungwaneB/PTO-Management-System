import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'personal_info_screen.dart';

class ReliableInfoScreen extends StatefulWidget {
  const ReliableInfoScreen({super.key});

  @override
  State<ReliableInfoScreen> createState() => _ReliableInfoScreenState();
}

class _ReliableInfoScreenState extends State<ReliableInfoScreen> {
  final _incomeController = TextEditingController();
  bool _showErrors = false;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _handleContinue(ApplyViewModel viewModel) {
    setState(() => _showErrors = true);

    if (_incomeController.text.trim().isEmpty ||
        viewModel.isSouthAfrican == null ||
        viewModel.isFirstTimeHomeOwner == null ||
        viewModel.isOver21 == null ||
        viewModel.isFirstTimeGovSubsidy == null ||
        viewModel.isOver21 == 'No') {
      return;
    }

    viewModel.updateIncome(_incomeController.text);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();
    final isIncomeError = _showErrors && _incomeController.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('PTO Application - Reliable', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    const Text('Reliable information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    
                    const Text('Monthly income (less than R3 500)', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}), 
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFE0E0E0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6), 
                          borderSide: isIncomeError ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    if (isIncomeError) 
                      const Padding(padding: EdgeInsets.only(top: 4, left: 4), child: Text('Monthly income is required', style: TextStyle(color: Colors.red, fontSize: 12))),
                    
                    const SizedBox(height: 20),
                    _buildRadioRow('South African / Naturalised', viewModel.isSouthAfrican, _showErrors, (val) => viewModel.toggleRadio('southAfrican', val)),
                    _buildRadioRow('First-time home owner', viewModel.isFirstTimeHomeOwner, _showErrors, (val) => viewModel.toggleRadio('firstTimeHome', val)),
                    _buildRadioRow('Over 21', viewModel.isOver21, _showErrors, (val) => viewModel.toggleRadio('over21', val), errorText: viewModel.isOver21 == 'No' && _showErrors ? 'You must be over 21 to apply' : null),
                    _buildRadioRow('First-time government subsidy recipient', viewModel.isFirstTimeGovSubsidy, _showErrors, (val) => viewModel.toggleRadio('govSubsidy', val)),
                    _buildRadioRow('Military veteran (optional)', viewModel.isMilitaryVeteran, false, (val) => viewModel.toggleRadio('military', val)),
                    _buildRadioRow('Elderly person', viewModel.isElderly, false, (val) => viewModel.toggleRadio('elderly', val)),
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

  Widget _buildRadioRow(String label, String? groupValue, bool showErrors, ValueChanged<String> onChanged, {String? errorText}) {
    bool isRequired = !label.contains('optional') && !label.contains('Elderly');
    bool hasError = showErrors && isRequired && groupValue == null;
    String? displayError = hasError ? 'Please select an option' : errorText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: () => onChanged('Yes'),
                child: Row(children: [
                  Icon(groupValue == 'Yes' ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: groupValue == 'Yes' ? const Color(0xFFE87A2D) : Colors.grey),
                  const SizedBox(width: 4),
                  const Text('YES', style: TextStyle(fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => onChanged('No'),
                child: Row(children: [
                  Icon(groupValue == 'No' ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: groupValue == 'No' ? const Color(0xFFE87A2D) : Colors.grey),
                  const SizedBox(width: 4),
                  const Text('NO', style: TextStyle(fontSize: 12)),
                ]),
              ),
            ],
          ),
          if (displayError != null)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(displayError, style: const TextStyle(color: Colors.red, fontSize: 12))),
        ],
      ),
    );
  }
}