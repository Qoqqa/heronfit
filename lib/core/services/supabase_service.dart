import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  late final SupabaseClient client;
  
  static SupabaseClient get instance => _instance.client;
  
  factory SupabaseService() {
    return _instance;
  }
  
  SupabaseService._internal() {
    client = Supabase.instance.client;
  }
  
  // Add any additional Supabase helper methods here
}
