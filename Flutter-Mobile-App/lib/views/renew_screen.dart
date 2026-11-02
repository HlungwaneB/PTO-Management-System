import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/renew_viewmodel.dart';

class RenewScreen extends StatefulWidget {
  const RenewScreen({super.key});

  @override
  State<RenewScreen> createState() => _RenewScreenState();
}

class _RenewScreenState extends State<RenewScreen> {
  final _notesController = TextEditingController();
  final _incomeController = TextEditingController();
  
  bool _showErrors = false;
  bool _isLoadingSites = false;
  List<Map<String, dynamic>> _availableSites = [];
  String? _selectedNewSiteId;

  @override
  void initState() {
    super.initState();
    print("🟢 RENEW SCREEN LOADED"); // Debug check
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardVm = context.read<DashboardViewModel>();
      final app = dashboardVm.application;
      
      if (app != null && app['end_date'] != null) {
        context.read<RenewViewModel>().setExpiryDate(app['end_date']);
      }
    });
    
    _fetchSites(); // Call fetch immediately
  }

  Future<void> _fetchSites() async {
    print("🟢 STARTING TO FETCH SITES...");
    setState(() => _isLoadingSites = true);
    
    try {
      final response = await Supabase.instance.client
          .from('sites')
          .select()
          .eq('is_available', true); // Ensure this matches your DB
      
      print("🟢 SITES FETCHED: ${response.length}");
      
      setState(() {
        _availableSites = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("🔴 ERROR FETCHING SITES: $e");
    } finally {
      setState(() => _isLoadingSites = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _handleSubmit(RenewViewModel viewModel) {
    setState(() => _showErrors = true);

    if (viewModel.stillLivingAtSite == null || viewModel.changeInIncome == null) {
      return; 
    }

    if (viewModel.stillLivingAtSite == 'No' && _selectedNewSiteId == null) {
      return;
    }

    if (viewModel.changeInIncome == 'Yes' && _incomeController.text.isEmpty) {
      return; 
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Renewal request submitted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RenewViewModel>();
    final bool isNotLivingThere = viewModel.stillLivingAtSite == 'No';
    final bool showSiteError = _showErrors && isNotLivingThere && _selectedNewSiteId == null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('Renewal request', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: const Text('Renew PTO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expiry Date
                    const Text('Expiry date checked', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.expiryText,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Still living at site
                    const Text('Still living at this site', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    _buildRadioRow('living', viewModel.stillLivingAtSite, _showErrors, (val) => viewModel.setRadio('living', val)),
                    
                    // 🟢 NEW SITE DROPDOWN (Only shows if NO)
                    if (isNotLivingThere) ...[
                      const SizedBox(height: 16),
                      const Text('Select New Site', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: showSiteError ? Colors.red : Colors.transparent, width: 2)
                        ),
                        child: _isLoadingSites
                            ? const Padding(padding: EdgeInsets.all(12.0), child: LinearProgressIndicator())
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedNewSiteId,
                                  hint: const Text('Choose a site...', style: TextStyle(fontSize: 13)),
                                  items: _availableSites.isEmpty 
                                      ? [const DropdownMenuItem(value: null, child: Text('No sites available', style: TextStyle(fontSize: 13, color: Colors.red)))]
                                      : _availableSites.map((site) => DropdownMenuItem<String>(
                                          value: site['site_id'].toString(), 
                                          child: Text('${site['site_name']} - ${site['location']}', style: const TextStyle(fontSize: 13))
                                        )).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedNewSiteId = value;
                                    });
                                  },
                                ),
                              ),
                      ),
                      if (showSiteError)
                        const Padding(padding: EdgeInsets.only(top: 4, left: 4), child: Text('Please select a new site', style: TextStyle(color: Colors.red, fontSize: 12))),
                    ],
                    
                    const SizedBox(height: 16),

                    // Change in income
                    const Text('Change in income or household', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    _buildRadioRow('income', viewModel.changeInIncome, _showErrors, (val) => viewModel.setRadio('income', val)),
                    const SizedBox(height: 16),

                    // New Income Field (if yes)
                    if (viewModel.changeInIncome == 'Yes') ...[
                      const Text('New Monthly Income (R)', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => viewModel.newMonthlyIncome = val,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE0E0E0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6), 
                            borderSide: (_showErrors && _incomeController.text.isEmpty) ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      if (_showErrors && _incomeController.text.isEmpty)
                        const Padding(padding: EdgeInsets.only(top: 4, left: 4), child: Text('New income is required', style: TextStyle(color: Colors.red, fontSize: 12))),
                      const SizedBox(height: 16),
                    ],

                    // Notes
                    const Text('Notes (optional)', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      onChanged: (val) => viewModel.notes = val,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFE0E0E0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), border: Border(top: BorderSide(color: Colors.grey.shade400))),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(viewModel),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9C9C9), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Submit renewal request', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD9D9D9), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioRow(String field, String? groupValue, bool showErrors, ValueChanged<String> onChanged) {
    bool hasError = showErrors && groupValue == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged('Yes'),
              child: Row(
                children: [
                  Icon(groupValue == 'Yes' ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: groupValue == 'Yes' ? const Color(0xFFE87A2D) : Colors.grey),
                  const SizedBox(width: 4),
                  const Text('YES', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => onChanged('No'),
              child: Row(
                children: [
                  Icon(groupValue == 'No' ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: groupValue == 'No' ? const Color(0xFFE87A2D) : Colors.grey),
                  const SizedBox(width: 4),
                  const Text('NO', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        if (hasError)
          const Padding(padding: EdgeInsets.only(top: 4), child: Text('Please select an option', style: TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }
}