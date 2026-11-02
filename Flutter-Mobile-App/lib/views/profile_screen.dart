import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  String _activeTab = 'personal';

  // Controllers
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // 🟢 Site Data for Address Tab
  String _siteName = 'Not assigned';
  String _siteLocation = 'No address available';
  String _applicationStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final idNumber = user.email?.split('@').first ?? '';
        _idNumberController.text = idNumber;

        // Fetch Application Data
        final response = await Supabase.instance.client
            .from('applications')
            .select('*, sites(*)') // 🟢 Fetch the related site data
            .eq('id_number', idNumber)
            .maybeSingle();

        if (response != null) {
          final parts = (response['full_name'] ?? '').split(' ');
          _nameController.text = parts.isNotEmpty ? parts[0] : '';
          _surnameController.text = parts.length > 1 ? parts.last : '';
          _phoneController.text = response['phone_number'] ?? '';
          _emailController.text = response['email'] ?? '';

          _applicationStatus = response['current_status'] ?? 'Pending';

          // 🟢 Extract Site Data if Approved
          if (_applicationStatus == 'Approved' && response['sites'] != null) {
            _siteName = response['sites']['site_name'] ?? 'Unknown Site';
            _siteLocation = response['sites']['location'] ?? 'Unknown Location';
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('applications')
          .update({
            'full_name': '${_nameController.text} ${_surnameController.text}',
            'phone_number': _phoneController.text,
            'email': _emailController.text,
          })
          .eq('id_number', _idNumberController.text);

      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
        (route) => false
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('My Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ═══════════ HEADER BANNER ═══════════
          Container(
            height: 130,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
            child: Stack(
              children: [
                // Buttons
                Positioned(
                  top: 15,
                  right: 15,
                  child: Row(
                    children: [
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE87A2D), foregroundColor: Colors.white),
                          child: const Text('Save Changes', style: TextStyle(fontSize: 14)),
                        )
                      else
                        OutlinedButton(
                          onPressed: () => setState(() => _isEditing = true),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE87A2D))),
                          child: const Text('Edit details', style: TextStyle(color: Color(0xFFE87A2D), fontSize: 14)),
                        ),
                      const SizedBox(width: 10),
                      if (!_isEditing)
                        ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62828), foregroundColor: Colors.white),
                          child: const Text('Log out', style: TextStyle(fontSize: 14)),
                        ),
                    ],
                  ),
                ),
                // Avatar & Name
                Positioned(
                  bottom: 15,
                  left: 20,
                  child: Row(
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(color: const Color(0xFFE87A2D), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                        child: const Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 15),
                      Text('${_nameController.text} ${_surnameController.text}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ═══════════ TABS ═══════════
          Container(
            color: const Color(0xFFF7A56B),
            child: Row(
              children: [
                _buildTab('Personal', 'personal'),
                _buildTab('Address', 'address'),
                _buildTab('Next of kin', 'nextofkin'),
              ],
            ),
          ),

          // ═══════════ CONTENT ═══════════
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0).copyWith(bottom: 80), 
              children: [
                if (_activeTab == 'personal') ...[
                  const Text('Personal details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildEditableField('Name', _nameController),
                  _buildEditableField('Surname', _surnameController),
                  _buildEditableField('Identity Number', _idNumberController, isReadOnly: true),
                  const SizedBox(height: 20),
                  const Text('Contact details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildEditableField('Primary mobile number', _phoneController),
                  _buildEditableField('Primary email address', _emailController),
                  
                ] else if (_activeTab == 'address') ...[
                  const Text('Address details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // 🟢 SHOW SITE IF APPROVED
                  if (_applicationStatus == 'Approved') ...[
                    _buildEditableField('Site Name', TextEditingController(text: _siteName), isReadOnly: true),
                    _buildEditableField('Location / Suburb', TextEditingController(text: _siteLocation), isReadOnly: true),
                    _buildEditableField('Address Type', TextEditingController(text: 'Residential PTO'), isReadOnly: true),
                  ] else ...[
                    // SHOW EMPTY STATE IF NOT APPROVED
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200)
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.location_off, color: Colors.red, size: 40),
                          SizedBox(height: 10),
                          Text('No address assigned yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                          SizedBox(height: 5),
                          Text('Your address will appear here once your application is approved.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    )
                  ],
                  
                ] else if (_activeTab == 'nextofkin') ...[
                  const Text('Next of kin details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildEditableField('Name', TextEditingController()),
                  _buildEditableField('Surname', TextEditingController()),
                  _buildEditableField('Contact number', TextEditingController()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String tabId) {
    bool isActive = _activeTab == tabId;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: isActive ? const Color(0xFFE87A2D) : const Color(0xFFF7A56B),
          child: Text(
            label, 
            textAlign: TextAlign.center, 
            style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: !_isEditing || isReadOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: (!_isEditing || isReadOnly) ? const Color(0xFFF0F0F0) : const Color(0xFFE0E0E0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}