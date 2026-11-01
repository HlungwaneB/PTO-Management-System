import 'package:flutter/material.dart';

class TrackResultScreen extends StatelessWidget {
  final Map<String, dynamic> application;
  final Map<String, dynamic>? site;

  const TrackResultScreen({
    super.key, 
    required this.application,
    this.site,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data
    String fullName = application['full_name'] ?? 'Unknown';
    String idNumber = application['id_number'] ?? 'Unknown';
    String status = application['current_status'] ?? 'Unknown';
    String siteName = site?['site_name'] ?? 'Not Assigned';
    String year = application['end_date'] != null 
        ? application['end_date'].toString().substring(0, 4) 
        : 'N/A';

    // Split name (assuming format "First Last")
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String surname = nameParts.length > 1 ? nameParts.last : '';

    // Status color logic
    Color statusColor = Colors.orange; // Default
    if (status == 'Approved') statusColor = Colors.green;
    if (status == 'Rejected') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text('my', style: TextStyle(color: Color(0xFFE87A2D), fontStyle: FontStyle.italic, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('PTO', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
            Container(margin: const EdgeInsets.symmetric(horizontal: 8), height: 24, width: 1, color: Colors.grey.shade400),
            const Text('Mangaung', style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Image.asset('assets/logo.png', height: 30, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.green)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'P.T.O Status',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 30),

              _buildRow('ID number', idNumber),
              _buildRow('Title', 'Applicant'), // Adjust if you have title in DB
              _buildRow('Initials', ''),       // Adjust if you have initials in DB
              _buildRow('Name', firstName),
              _buildRow('Surname', surname),
              _buildRow('Year', year),
              _buildRow('Site', siteName),
              
              // Status with color
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const Text(':', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 20),
                    Text(
                      status, 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: statusColor)
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

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const Text(':', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}