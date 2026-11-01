import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardViewModel extends ChangeNotifier {
  bool isLoading = true;
  Map<String, dynamic>? application;
  Map<String, dynamic>? site;
  String fullName = 'User';

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // 1. Get the ID Number from the email (e.g., 96050...@pto.local)
        final idNumber = user.email?.split('@').first ?? '';

        // 2. Fetch the Application
        final appResponse = await Supabase.instance.client
            .from('applications')
            .select()
            .eq('id_number', idNumber)
            .order('start_date', ascending: false)
            .limit(1)
            .maybeSingle();

        if (appResponse != null) {
          application = appResponse;
          fullName = application!['full_name'] ?? 'User';

          // 3. Fetch the Site details using the SiteId
          final siteId = application!['site_id'];
          if (siteId != null) {
            final siteResponse = await Supabase.instance.client
                .from('sites')
                .select()
                .eq('site_id', siteId)
                .maybeSingle();
            site = siteResponse;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading dashboard: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper to format dates nicely
  String formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}