/// Supabase Configuration for AggieRide
///
/// To connect to your free Supabase project:
/// 1. Create a free project at https://supabase.com
/// 2. Go to Project Settings -> API
/// 3. Paste your Project URL and anon public key below:
class SupabaseConfig {
  static const String supabaseUrl = 'https://bgbyywxvfombdnilxzzf.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_MnAwBSfPkbKbxD8N2tdnbA_sdFSGuvU';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL';
}
