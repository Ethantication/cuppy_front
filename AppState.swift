import SwiftUI
import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var isFirstLaunch = true
    @Published var selectedCommunity: Community?
    @Published var currentUser: User?
    @Published var showRegistrationPopup = false
    @Published var selectedTab = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabaseService = SupabaseService.shared

    init() {
        loadSavedCommunity()
        Task { await loadCurrentUser() }
    }

    // MARK: - Load saved community from UserDefaults
    private func loadSavedCommunity() {
        if let communityData = UserDefaults.standard.data(forKey: "selectedCommunity"),
           let community = try? JSONDecoder().decode(Community.self, from: communityData) {
            self.selectedCommunity = community
            self.isFirstLaunch = false
        }
    }

    // MARK: - Load current user from UserDefaults or Supabase
    private func loadCurrentUser() async {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        } else if let authUserId = getAuthUserId() {
            // Fetch real user from Supabase
            isLoading = true
            if let user = await supabaseService.fetchUser(by: authUserId) {
                self.currentUser = user
                saveCurrentUserLocally(user)
            } else {
                errorMessage = supabaseService.error
            }
            isLoading = false
        }
    }

    // Placeholder: Replace with your real Auth User ID logic
    private func getAuthUserId() -> String? {
        // For example, get user ID from Supabase Auth session
        return nil
    }

    // MARK: - Community selection
    func selectCommunity(_ community: Community) {
        self.selectedCommunity = community
        self.isFirstLaunch = false

        saveCommunityLocally(community)

        // Show registration popup if user not registered
        if currentUser == nil {
            showRegistrationPopup = true
        }
    }

    private func saveCommunityLocally(_ community: Community) {
        if let encoded = try? JSONEncoder().encode(community) {
            UserDefaults.standard.set(encoded, forKey: "selectedCommunity")
        }
    }

    // MARK: - User registration
    func registerUser(_ user: User) {
        self.currentUser = user
        saveCurrentUserLocally(user)

        Task {
            isLoading = true
            let success = await supabaseService.createUser(user)
            if !success {
                errorMessage = supabaseService.error
            }
            isLoading = false
        }

        showRegistrationPopup = false
    }

    private func saveCurrentUserLocally(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    // MARK: - Logout
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    // MARK: - Change community
    func changeCommunity() {
        selectedCommunity = nil
        isFirstLaunch = true
        UserDefaults.standard.removeObject(forKey: "selectedCommunity")
    }
}
