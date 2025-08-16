import Foundation

struct SupabaseConfig {
    // MARK: - Configuration
    static let shared = SupabaseConfig()
    
    // MARK: - Environment Variables
    // In production, these should be set in your environment or configuration
    let supabaseURL: String
    let supabaseAnonKey: String
    
    private init() {
        // For development, you can set these directly or use environment variables
        // In production, use proper environment variable management
        self.supabaseURL = "https://buabdjvvvnzkpotmomph.supabase.co" // Replace with your actual Supabase URL
        self.supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1YWJkanZ2dm56a3BvdG1vbXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzMzk3MjMsImV4cCI6MjA3MDkxNTcyM30.dejv_qAqtgyaHU786GeocCKDUCAOAUE-eb0p_fkPVhU" // Replace with your actual anon key
        
        // You can also load from environment variables:
        // self.supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        // self.supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
    }
    
    // MARK: - Validation
    var isValid: Bool {
        return !supabaseURL.isEmpty && !supabaseAnonKey.isEmpty && 
               supabaseURL != "YOUR_SUPABASE_URL" && 
               supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY"
    }
    
    // MARK: - Error Messages
    var configurationError: String? {
        if !isValid {
            return "Supabase configuration is missing. Please set SUPABASE_URL and SUPABASE_ANON_KEY in SupabaseConfig.swift"
        }
        return nil
    }
}
