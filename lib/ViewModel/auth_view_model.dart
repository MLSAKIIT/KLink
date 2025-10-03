import 'package:flutter/material.dart';
import 'package:klink/Model/auth_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel with ChangeNotifier {
  final AuthModel _authUsername = AuthModel(value: null, error: null);
  final AuthModel _authEmail = AuthModel(value: null, error: null);

  int? otp;
  bool _isLoading = false;
  String? _error;

  AuthModel get username => _authUsername;
  AuthModel get email => _authEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final supabase = Supabase.instance.client;

  Future<bool> registerUser() async {
    if (_authUsername.value == null ||
        _authUsername.error != null ||
        _authEmail.value == null ||
        _authEmail.error != null) {
      _error = null;
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabase.auth.signInWithOtp(
        email: _authEmail.value!,
        data: {'name': _authUsername.value},
      );

      return true;
    } on AuthApiException catch (e) {
      _error = "Registration failed: ${e.message}";
      return false;
    } on AuthException catch (e) {
      _error = "Registration failed: ${e.message}";
      return false;
    } catch (e) {
      _error = "Registration failed: ${e.toString().split(':').last.trim()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmOtp(String otpCode) async {
    if (_authEmail.value == null) {
      _error = "Email address not found. Please go back.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final AuthResponse response = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: otpCode.trim(),
        email: _authEmail.value!,
      );

      final bool success = response.session != null;

      if (!success) {
        _error = "Verification failed. The code may be invalid or expired.";
      }
      return success;
    } on AuthException catch (e) {
      _error = "Verification failed: ${e.message}";
      return false;
    } catch (e) {
      _error = "An unexpected error occurred. Please try again.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn() async {
    if (_authEmail.value == null || _authEmail.error != null) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabase.auth.signInWithOtp(email: _authEmail.value!);

      return true;
    } on AuthException catch (e) {
      _error = 'Login failed: ${e.message}';
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString().split(':').last.trim()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void verifyUsername(String username) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      _authUsername
        ..value = null
        ..error = 'Enter a valid name';
    } else if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(trimmed)) {
      _authUsername
        ..value = null
        ..error = "User letters and spaces only";
    } else if (trimmed.length < 2) {
      _authUsername
        ..value = null
        ..error = null;
    } else {
      _authUsername
        ..value = username
        ..error = null;
    }
    _error = null;
    notifyListeners();
  }

  void verifyEmail(String email) {
    if (email.isEmpty) {
      _authEmail
        ..value = null
        ..error = 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _authEmail
        ..value = null
        ..error = 'Enter a valid email address';
    } else if (!email.toLowerCase().endsWith('@kiit.ac.in')) {
      _authEmail
        ..value = null
        ..error = 'Please enter a KIIT email';
    } else {
      _authEmail
        ..value = email
        ..error = null;
    }
    _error = null;
    notifyListeners();
  }
}
