import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Temporary getters until we implement the Profiles table
  String get userName {
    final email = currentUser?.email ?? "";
    if (email.isEmpty) return "Guest";
    final namePart = email.split('@')[0];
    return namePart.substring(0, 1).toUpperCase() + namePart.substring(1);
  }

  Map<String, dynamic>? _profile;

  // Getters for Profile Data
  String get userHandle => _profile?['handle'] ?? "@\${userName.toLowerCase()}";
  String get userNiche => _profile?['niche'] ?? "Content Creation";
  int get userFollowers => _profile?['audience_size'] ?? 0;

  int _generatedCount = 0;
  int get generatedAssetsCount => _generatedCount;

  double get potentialRevenue => (_profile?['potential_revenue'] as num?)?.toDouble() ?? 0.0;

  AuthService() {
    // Listen to Auth State Changes
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchProfile();
        refreshStats();
      } else {
        _profile = null;
        _generatedCount = 0;
        notifyListeners();
      }
    });
  }

  Future<void> fetchProfile() async {
    try {
      final uid = currentUser?.id;
      if (uid == null) return;
      final data = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
      if (data != null) {
        _profile = data;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshStats() async {
     // TODO: Implement stats refresh logic
  }

  Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _supabase.auth.signUp(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<void> updateProfile({
    required String handle, 
    required String niche, 
    required int followers
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;

    final updates = {
      'id': uid, // Required for RLS alignment
      'handle': handle,
      'niche': niche,
      'audience_size': followers, 
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _supabase.from('profiles').upsert(updates);
      if (_profile != null) {
        _profile!.addAll(updates);
      } else {
        _profile = updates;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePotentialRevenue(double amount) async {
    final uid = currentUser?.id;
    if (uid == null) return;

    final updates = {
      'potential_revenue': amount,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // Try to update DB column 'potential_revenue'
      await _supabase.from('profiles').update(updates).eq('id', uid);
      
      if (_profile != null) {
        _profile!['potential_revenue'] = amount;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error saving revenue: \$e");
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
