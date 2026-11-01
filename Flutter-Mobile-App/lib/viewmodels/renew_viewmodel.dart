import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RenewViewModel extends ChangeNotifier {
  DateTime? expiryDate;

  void setExpiryDate(String? dateString) {
    if (dateString != null) {
      expiryDate = DateTime.parse(dateString);
      notifyListeners();
    }
  }

  // 🟢 Calculate Days Left
  int get daysLeft {
    if (expiryDate == null) return 0;
    final today = DateTime.now();
    final difference = expiryDate!.difference(today).inDays;
    return difference > 0 ? difference : 0;
  }

  // 🟢 Format the Text (e.g., "24 Apr 2027 — 182 days left")
  String get expiryText {
    if (expiryDate == null) return 'No active PTO found';
    final formattedDate = DateFormat('dd MMM yyyy').format(expiryDate!);
    return '$formattedDate — $daysLeft days left';
  }

  // Form State
  String stillLivingAtSite = 'Yes';
  String changeInIncome = 'No';
  String newMonthlyIncome = '';
  String notes = '';

  void setRadio(String field, String value) {
    if (field == 'living') stillLivingAtSite = value;
    if (field == 'income') changeInIncome = value;
    notifyListeners();
  }
}