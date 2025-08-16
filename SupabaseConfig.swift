import Foundation

struct SupabaseConfig {
    // MARK: - Shared Instance
    static let shared = SupabaseConfig()
    
    // MARK: - Environment Variables
    let supabaseURL: String
    let supabaseAnonKey: String
    
    private init() {
        // Attempt to load from environment first, fallback to hardcoded (for dev only)
        self.supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://buabdjvvvnzkpotmomph.supabase.co"
        self.supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1YWJkanZ2dm56a3BvdG1vbXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzMzk3MjMsImV4cCI6MjA3MDkxNTcyM30.dejv_qAqtgyaHU786GeocCKDUCAOAUE-eb0p_fkPVhU"
    }
    
    // MARK: - Convenience
    var url: URL? {
        return URL(string: supabaseURL)
    }
    
    // MARK: - Validation
    var isValid: Bool {
        return !supabaseURL.isEmpty && !supabaseAnonKey.isEmpty &&
               supabaseURL != "https://buabdjvvvnzkpotmomph.supabase.co" &&
               supabaseAnonKey != "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1YWJkanZ2dm56a3BvdG1vbXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzMzk3MjMsImV4cCI6MjA3MDkxNTcyM30.dejv_qAqtgyaHU786GeocCKDUCAOAUE-eb0p_fkPVhU"
    }
    
    var configurationError: String? {
        guard !isValid else { return nil }
        return """
        Supabase configuration is missing or invalid.
        Please set SUPABASE_URL and SUPABASE_ANON_KEY in SupabaseConfig.swift or environment variables.
        """
    }
}
