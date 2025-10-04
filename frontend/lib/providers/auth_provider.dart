import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/config/supabase_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  AuthProvider() {
    _loadSession();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _handleAuthSuccess(session);
      } else if (event == AuthChangeEvent.signedOut) {
        _clearSession();
      }
    });
  }

  Future<void> _handleAuthSuccess(Session session) async {
    try {
      _accessToken = session.accessToken;
      await _saveSession(_accessToken!);

      try {
        _currentUser = await _authService.getCurrentUser(_accessToken!);
      } catch (e) {
        // Fallback: Create user from Supabase session if backend fails
        if (session.user.email != null) {
          _currentUser = User(
            id: session.user.id,
            email: session.user.email!,
            name:
                session.user.userMetadata?['full_name'] ??
                session.user.userMetadata?['name'] ??
                session.user.email!.split('@')[0],
            username: session.user.email!.split('@')[0],
            avatarUrl:
                session.user.userMetadata?['avatar_url'] ??
                session.user.userMetadata?['picture'],
            createdAt: DateTime.parse(session.user.createdAt),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user data';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');

      if (_accessToken != null) {
        try {
          _currentUser = await _authService.getCurrentUser(_accessToken!);
          notifyListeners();
        } catch (e) {
          await logout();
        }
      }
    } catch (e) {
      // Silent fail - session will be loaded on next login
    }
  }

  Future<void> _saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _accessToken = token;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _accessToken = null;
    _currentUser = null;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      _accessToken = response['session']['access_token'];
      await _saveSession(_accessToken!);

      _currentUser = User.fromJson(response['user']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _accessToken = response['session']['access_token'];
      await _saveSession(_accessToken!);

      _currentUser = User.fromJson(response['user']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_accessToken == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(
        accessToken: _accessToken!,
        name: name,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if service call fails
    }

    await _clearSession();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
