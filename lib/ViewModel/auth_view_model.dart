import 'package:flutter/material.dart';
import 'package:klink/Model/auth_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel with ChangeNotifier {
  final AuthModel _authUsername = AuthModel(value: null, error: null);
  final AuthModel _authEmail = AuthModel(value: null, error: null);
  final AuthModel _authPassword = AuthModel(value: null, error: null);

  bool _isLoading = false;
  String? _error;

  AuthModel get username => _authUsername;
  AuthModel get email => _authEmail;
  AuthModel get password => _authPassword;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final supabase = Supabase.instance.client;

  Future<bool> registerUser() async {
    if (_authUsername.value == null ||
        _authUsername.error != null ||
        _authEmail.value == null ||
        _authEmail.error != null ||
        _authPassword.value == null ||
        _authPassword.error != null) {
      _error = null;
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase.auth.signInWithOtp(
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

  Future<bool> confirmEmail(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: code.trim(),
      );

      final uid = response.session?.user.id ?? supabase.auth.currentUser?.id;
      if (uid == null) {
        _error = "Verification failed. Try again.";
        return false;
      }

      await supabase.from('profiles').upsert({
        'id': uid,
        'username': _authUsername.value,
      });
      return true;
    } on AuthApiException catch (e) {
      _error = "Registration failed: ${e.message}";
      return false;
    } on AuthException catch (e) {
      _error = "Verification failed: ${e.message}";
      return false;
    } catch (e) {
      _error = "Verification failed: ${e.toString().split(':').last.trim()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn() async {
    if (_authEmail.value == null ||
        _authEmail.error != null ||
        _authPassword.value == null ||
        _authPassword.error != null) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _authEmail.value!,
        password: _authPassword.value!,
      );

      final ok = response.user != null;

      if (!ok) {
        _error = "Login failed. Please try again.";
      }
      return ok;
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

  void verifyPassword(String password) {
    final bool valid =
        password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(password);

    if (!valid) {
      _authPassword
        ..value = null
        ..error =
            'Password must be at least 8 chars with upper, lower, number, special';
    } else {
      _authPassword
        ..value = password
        ..error = null;
    }
    _error = null;
    notifyListeners();
  }
}
