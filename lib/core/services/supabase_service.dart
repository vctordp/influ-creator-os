import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_credentials.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Placeholder for future methods
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseCredentials.url,
      anonKey: SupabaseCredentials.anonKey,
    );
  }
}
