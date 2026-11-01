import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Fetch from 'notifications' table matching user_id
        final response = await Supabase.instance.client
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('sent_at', ascending: false); // Note: column is 'sent_at'

        setState(() {
          _notifications = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('Notifications', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('You have no new notifications.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['is_read'] ?? false;
                      // 🟢 Use 'sent_at' to match database
                      final dateSent = DateTime.parse(notif['sent_at']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12, height: 12,
                              margin: const EdgeInsets.only(top: 4, right: 12),
                              decoration: BoxDecoration(
                                color: isRead ? Colors.blue : const Color(0xFFE87A2D), 
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isRead ? "System Notification" : "New Alert", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(notif['message'] ?? '', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                ],
                              ),
                            ),
                            Text(DateFormat('dd MMM yyyy').format(dateSent), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}