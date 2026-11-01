import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'reliable_info_screen.dart'; // To navigate to Apply

import 'track_result_screen.dart';

class TrackSearchScreen extends StatefulWidget {
  const TrackSearchScreen({super.key});

  @override
  State<TrackSearchScreen> createState() => _TrackSearchScreenState();
}

class _TrackSearchScreenState extends State<TrackSearchScreen> {
  final _idController = TextEditingController();
  bool _isLoading = false;

 
  bool _showNotFound = false;
  String _searchedId = '';

  Future<void> _searchApplication() async {
    final idNumber = _idController.text.trim();

    if (idNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ID Number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showNotFound = false;
    });

    try {
      final response = await Supabase.instance.client
          .from('applications')
          .select()
          .eq('id_number', idNumber)
          .maybeSingle();
      if (response == null) {
        setState(() {
          _showNotFound = true;
          _searchedId = idNumber;
        });
      } else {
        // 🟢 Application found: Fetch the site details
        Map<String, dynamic>? siteData;
        if (response['site_id'] != null) {
          final siteResponse = await Supabase.instance.client
              .from('sites')
              .select()
              .eq('site_id', response['site_id'])
              .maybeSingle();
          siteData = siteResponse;
        }

        if (mounted) {
          // 🟢 Navigate to the Status Card screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TrackResultScreen(application: response, site: siteData),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error searching: $e')));
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'my',
              style: TextStyle(
                color: Color(0xFFE87A2D),
                fontStyle: FontStyle.italic,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'PTO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 24,
              width: 1,
              color: Colors.grey.shade400,
            ),
            const Text(
              'Mangaung',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Image.asset(
              'assets/logo.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business, color: Colors.green),
            ),
          ),
        ],
      ),
      body: _showNotFound ? _buildNotFoundScreen() : _buildSearchScreen(),
    );
  }

  // 🟢 The Search Form View
  Widget _buildSearchScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search for your PTO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE0E0E0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search using ID number.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  'Required items marked with a *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text(
            'ID Number*',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _idController,
            keyboardType: TextInputType.number,
            maxLength: 13,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE0E0E0),
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _searchApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9C9C9),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Search'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9C9C9),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text('Back'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🟢 The Not Found View
  Widget _buildNotFoundScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search for your PTO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 40),

          // Message with ID and Apply link
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: 'Cannot find an Application for this ID NO: ',
                ),
                TextSpan(
                  text: '$_searchedId. ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReliableInfoScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Back Button
          ElevatedButton(
            onPressed: () {
              // Reset state to show the search form again
              setState(() {
                _showNotFound = false;
                _idController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9C9C9),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
