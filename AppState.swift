import SwiftUI
import Foundation

class AppState: ObservableObject {
    @Published var isFirstLaunch = true
    @Published var selectedCommunity: Community?
    @Published var currentUser: User?
    @Published var showRegistrationPopup = false
    @Published var selectedTab = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    
    init() {
        // Check if user has selected community before
        if let communityData = UserDefaults.standard.data(forKey: "selectedCommunity"),
           let community = try? JSONDecoder().decode(Community.self, from: communityData) {
            self.selectedCommunity = community
            self.isFirstLaunch = false
        }
        
        // Initialize with Supabase data
        Task {
            await loadInitialData()
        }
    }
    
    @MainActor
    private func loadInitialData() async {
        do {
            // Try to restore user session
            if let user = supabaseManager.currentUser {
                self.currentUser = user
            }
        } catch {
            print("Failed to load initial data: \(error)")
        }
    }
    
    func selectCommunity(_ community: Community) {
        self.selectedCommunity = community
        self.isFirstLaunch = false
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(community) {
            UserDefaults.standard.set(encoded, forKey: "selectedCommunity")
        }
        
        // Show registration popup if user not registered
        if currentUser == nil {
            showRegistrationPopup = true
        }
        
        // Load coffee shops for the selected community
        Task {
            await loadCommunityData(community.id)
        }
    }
    
    @MainActor
    private func loadCommunityData(_ communityId: String) async {
        do {
            isLoading = true
            try await supabaseManager.fetchCoffeeShops(for: communityId)
            isLoading = false
        } catch {
            errorMessage = "Failed to load community data: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func registerUser(name: String, email: String, password: String) async {
        guard let community = selectedCommunity else { return }
        
        do {
            isLoading = true
            let user = try await supabaseManager.signUp(
                email: email,
                password: password,
                name: name,
                communityId: community.id
            )
            
            self.currentUser = user
            
            // Save to UserDefaults for offline access
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
            
            showRegistrationPopup = false
            isLoading = false
            
            // Setup real-time subscriptions
            supabaseManager.setupRealtimeSubscriptions()
            
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            isLoading = true
            let user = try await supabaseManager.signIn(email: email, password: password)
            
            self.currentUser = user
            
            // Save to UserDefaults for offline access
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
            
            isLoading = false
            
            // Setup real-time subscriptions
            supabaseManager.setupRealtimeSubscriptions()
            
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func logout() async {
        do {
            try await supabaseManager.signOut()
            currentUser = nil
            UserDefaults.standard.removeObject(forKey: "currentUser")
        } catch {
            errorMessage = "Logout failed: \(error.localizedDescription)"
        }
    }
    
    func changeCommunity() {
        selectedCommunity = nil
        isFirstLaunch = true
        UserDefaults.standard.removeObject(forKey: "selectedCommunity")
    }
}