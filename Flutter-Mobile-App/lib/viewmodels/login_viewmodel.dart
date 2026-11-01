import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String idNumber, String password) async {
    if (idNumber.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter ID and Password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: '${idNumber.trim()}@pto.local',
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return response.user != null;
    } catch (error) {
      _errorMessage = 'Login failed: ${error.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}