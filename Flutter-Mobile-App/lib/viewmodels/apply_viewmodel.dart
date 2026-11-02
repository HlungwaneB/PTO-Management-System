import 'dart:io';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ApplyViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  // --- Reliable Info ---
  String monthlyIncome = '';
  String? isSouthAfrican;
  String? isFirstTimeHomeOwner;
  String? isOver21;
  String? isFirstTimeGovSubsidy;
  String? isMilitaryVeteran;
  String? isElderly;

  // --- Personal Info ---
  String surname = '';
  String initials = '';
  String title = '';
  String firstNames = '';
  DateTime? dateOfBirth;
  String idNumber = '';
  String gender = '';

  // --- Contact Info & Site ---
  String cellphone = '';
  String email = '';
  String homeCellphone = '';
  String? isDependant;
  String selectedSiteId = '';
  List<Map<String, dynamic>> availableSites = [];
  bool isLoadingSites = false;

  // --- Dependent Info ---
  String kinRelationship = '';
  String kinSurname = '';
  String kinInitials = '';
  String kinFirstNames = '';
  String kinIdNumber = '';
  String kinCellphone = '';
  String kinEmail = '';

  // 🟢 Document URLs (Restored for Upload Logic)
  String? certifiedIdUrl;
  String? proofOfIncomeUrl;
  String? dependentIdUrl;
  bool isUploading = false;

  // --- Password ---
  String password = '';
  String confirmPassword = '';

  // --- Status ---
  bool isSubmitting = false;

  // ═════════════════════════════════════════════
  // METHODS
  // ═════════════════════════════════════════════

  void toggleRadio(String field, String value) {
    switch (field) {
      case 'southAfrican':
        isSouthAfrican = value;
      case 'firstTimeHome':
        isFirstTimeHomeOwner = value;
      case 'over21':
        isOver21 = value;
      case 'govSubsidy':
        isFirstTimeGovSubsidy = value;
      case 'military':
        isMilitaryVeteran = value;
      case 'elderly':
        isElderly = value;
      case 'dependant':
        isDependant = value;
    }
    notifyListeners();
  }

  void updateIncome(String value) => monthlyIncome = value;

  Future<void> fetchSites() async {
    isLoadingSites = true;
    notifyListeners();
    try {
      availableSites = await _supabaseService.getSites();
    } catch (e) {
      debugPrint("Error fetching sites: $e");
    } finally {
      isLoadingSites = false;
      notifyListeners();
    }
  }

  // 🟢 Upload Document Logic
  Future<bool> uploadFile(File file, String docType) async {
    isUploading = true;
    notifyListeners();

    try {
      final url = await _supabaseService.uploadDocument(file, docType);
      if (url != null) {
        if (docType == 'certified_ids') certifiedIdUrl = url;
        if (docType == 'proof_of_income') proofOfIncomeUrl = url;
        if (docType == 'dependent_ids') dependentIdUrl = url;
        return true;
      }
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> submitApplication() async {
    isSubmitting = true;
    notifyListeners();

    try {
      final success = await _supabaseService.submitApplication(
        idNumber: idNumber,
        fullName: '$firstNames $surname',
        phone: cellphone,
        email: email,
        siteId: selectedSiteId,
        income: monthlyIncome,
        password: password,
        title: title,
        initials: initials,
        idUrl: certifiedIdUrl,
        incomeUrl: proofOfIncomeUrl,
        dependentUrl: dependentIdUrl,
      );
      return success;
    } catch (e) {
      debugPrint("Submission Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
