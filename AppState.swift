import SwiftUI
import Foundation

class AppState: ObservableObject {
    @Published var isFirstLaunch = true
    @Published var selectedCommunity: Community?
    @Published var currentUser: User?
    @Published var showRegistrationPopup = false
    @Published var selectedTab = 0
    
    init() {
        // Check if user has selected community before
        if let communityData = UserDefaults.standard.data(forKey: "selectedCommunity"),
           let community = try? JSONDecoder().decode(Community.self, from: communityData) {
            self.selectedCommunity = community
            self.isFirstLaunch = false
        }
        
        // Check if user is registered
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
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
    }
    
    func registerUser(_ user: User) {
        self.currentUser = user
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
        
        showRegistrationPopup = false
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func changeCommunity() {
        selectedCommunity = nil
        isFirstLaunch = true
        UserDefaults.standard.removeObject(forKey: "selectedCommunity")
    }
}