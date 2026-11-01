import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
    });

    // 🟢 Auto-refresh every 10 seconds so the dots move live
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        context.read<DashboardViewModel>().loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final app = viewModel.application;

    String status = app?['current_status'] ?? 'Submitted';

    // 🟢 STATUS LOGIC
    bool step1Done = true; 
    bool step2Done = (status == "Pending" || status == "Verifying" || status == "Approved" || status == "Rejected"); 
    bool step3Done = (status == "Verifying" || status == "Approved" || status == "Rejected"); 
    bool step4Done = (status == "Approved" || status == "Rejected");
    bool isRejected = (status == "Rejected");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text(
          'PTO Tracking',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: viewModel.isLoading && app == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PTO Tracking', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('Track your application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 40),

                  // ═══════════ TIMELINE ═══════════
                  Row(
                    children: [
                      _buildTimelineStep('submitted', step1Done, false),
                      _buildTimelineLine(step2Done, isRejected),
                      _buildTimelineStep('Pending', step2Done, false),
                      _buildTimelineLine(step3Done, isRejected),
                      _buildTimelineStep('Verifying', step3Done, isRejected),
                      _buildTimelineLine(step4Done, isRejected),
                      _buildTimelineStep(isRejected ? 'Rejected' : 'Approved', step4Done, isRejected),
                    ],
                  ),
                  
                  const SizedBox(height: 60),

                  // Action Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9C9C9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      child: const Text('Done', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 🟢 Helper to draw the dot + label
  Widget _buildTimelineStep(String label, bool isDone, bool isRejected) {
    Color circleColor = Colors.grey.shade400;
    if (isDone) {
      circleColor = isRejected ? const Color(0xFFD62828) : const Color(0xFFE53935);
    }

    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRejected && label == 'Rejected' ? Icons.close : Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  // 🟢 Helper to draw the connecting line
  Widget _buildTimelineLine(bool isDone, bool isRejected) {
    Color lineColor = isDone 
        ? (isRejected ? const Color(0xFFD62828) : const Color(0xFFE53935)) 
        : Colors.grey.shade300;

    return Expanded(
      flex: 1,
      child: Container(
        height: 4,
        margin: const EdgeInsets.only(bottom: 24), // Push line up to center of dots
        color: lineColor,
      ),
    );
  }
}