import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseClientManager {
  static final SupabaseClient client = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
  );
}