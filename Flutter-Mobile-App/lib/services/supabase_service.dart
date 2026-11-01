import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<String?> uploadDocument(File file, String folder) async {
    try {
      final fileName =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      await client.storage.from('pto-documents').upload(fileName, file);
      return client.storage.from('pto-documents').getPublicUrl(fileName);
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<bool> submitApplication({
    required String idNumber,
    required String fullName,
    required String phone,
    required String email,
    required String siteId,
    required String income,
    required String password,
    required String title,
    required String initials,
    String? idUrl,
    String? incomeUrl,
    String? dependentUrl,
  }) async {
    try {
      final emailFake = '${idNumber.trim()}@pto.local';
      final authResponse = await client.auth.signUp(
        email: emailFake,
        password: password,
      );
      if (authResponse.user == null) throw Exception("Failed to create user.");

      // 🟢 Ensure data types match the database exactly
      await client.from('applications').insert({
        'id_number': idNumber.toString().trim(), // String
        'full_name': fullName.toString(),
        'phone_number': phone.toString(),
        'email': email.toString(),
        'site_id': siteId.toString(),
        'pto_type': 'Residential', // String
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now()
            .add(const Duration(days: 180))
            .toIso8601String(),
        'current_status': 'Submitted', // String
        'is_active': true, // 🟢 Boolean
        'monthly_income': income.toString(), // String
        'title': title.toString(),
        'initials': initials.toString(),
        'certified_id_url': idUrl,
        'proof_of_income_url': incomeUrl,
        'dependent_id_url': dependentUrl,
      });
      return true;
    } catch (e) {
      print("Submission error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSites() async {
    try {
      final response = await client
          .from('sites')
          .select()
          .eq('is_available', true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
