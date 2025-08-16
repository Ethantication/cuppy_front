import Foundation
import Supabase
import SwiftUI

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    private let supabase: SupabaseClient
    
    // Published properties for UI updates
    @Published var communities: [Community] = []
    @Published var coffeeShops: [CoffeeShop] = []
    @Published var currentUser: User?
    @Published var userTransactions: [Transaction] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var friends: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        // Initialize Supabase client
        let supabaseURL = URL(string: SupabaseConfig.url)!
        let supabaseKey = SupabaseConfig.anonKey
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, name: String, communityId: String) async throws -> User {
        // Sign up with Supabase Auth
        let authResponse = try await supabase.auth.signUp(email: email, password: password)
        
        guard let authUser = authResponse.user else {
            throw SupabaseError.authenticationFailed
        }
        
        // Create user profile in our users table
        let newUser = User(
            id: UUID().uuidString,
            name: name,
            email: email,
            profileImage: nil,
            communityId: communityId,
            points: 0,
            friends: [],
            joinDate: Date(),
            authUserId: authUser.id.uuidString
        )
        
        try await supabase
            .from("users")
            .insert(newUser.toSupabaseDict())
            .execute()
        
        self.currentUser = newUser
        return newUser
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let authResponse = try await supabase.auth.signIn(email: email, password: password)
        
        guard let authUser = authResponse.user else {
            throw SupabaseError.authenticationFailed
        }
        
        // Fetch user profile
        let response: [User] = try await supabase
            .from("users")
            .select()
            .eq("auth_user_id", value: authUser.id.uuidString)
            .execute()
            .value
        
        guard let user = response.first else {
            throw SupabaseError.userNotFound
        }
        
        self.currentUser = user
        return user
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
        self.currentUser = nil
        self.coffeeShops = []
        self.userTransactions = []
        self.friendRequests = []
        self.friends = []
    }
    
    // MARK: - Communities
    
    func fetchCommunities() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [Community] = try await supabase
                .from("communities")
                .select()
                .order("name")
                .execute()
                .value
            
            self.communities = response
        } catch {
            self.errorMessage = "Failed to fetch communities: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Coffee Shops
    
    func fetchCoffeeShops(for communityId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [CoffeeShop] = try await supabase
                .from("coffee_shops")
                .select("*, beverages(*)")
                .eq("community_id", value: communityId)
                .execute()
                .value
            
            self.coffeeShops = response
        } catch {
            self.errorMessage = "Failed to fetch coffee shops: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Transactions
    
    func fetchUserTransactions() async throws {
        guard let userId = currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [Transaction] = try await supabase
                .from("user_transaction_history")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.userTransactions = response
        } catch {
            self.errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
            throw error
        }
    }
    
    func transferPoints(to receiverId: String, amount: Int, description: String) async throws {
        guard let senderId = currentUser?.id else { return }
        
        do {
            try await supabase.rpc("transfer_points", parameters: [
                "sender_id": senderId,
                "receiver_id": receiverId,
                "amount": amount,
                "description": description
            ]).execute()
            
            // Update local user points
            if let currentUser = currentUser {
                self.currentUser = User(
                    id: currentUser.id,
                    name: currentUser.name,
                    email: currentUser.email,
                    profileImage: currentUser.profileImage,
                    communityId: currentUser.communityId,
                    points: currentUser.points - amount,
                    friends: currentUser.friends,
                    joinDate: currentUser.joinDate,
                    authUserId: currentUser.authUserId
                )
            }
            
            // Refresh transactions
            try await fetchUserTransactions()
        } catch {
            self.errorMessage = "Failed to transfer points: \(error.localizedDescription)"
            throw error
        }
    }
    
    func earnPoints(at coffeeShopId: String, purchaseAmount: Double, description: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        do {
            let result: Int = try await supabase.rpc("earn_points", parameters: [
                "user_id": userId,
                "coffee_shop_id": coffeeShopId,
                "purchase_amount": purchaseAmount,
                "description": description
            ]).execute().value
            
            // Update local user points
            if let currentUser = currentUser {
                self.currentUser = User(
                    id: currentUser.id,
                    name: currentUser.name,
                    email: currentUser.email,
                    profileImage: currentUser.profileImage,
                    communityId: currentUser.communityId,
                    points: currentUser.points + result,
                    friends: currentUser.friends,
                    joinDate: currentUser.joinDate,
                    authUserId: currentUser.authUserId
                )
            }
            
            // Refresh transactions
            try await fetchUserTransactions()
        } catch {
            self.errorMessage = "Failed to earn points: \(error.localizedDescription)"
            throw error
        }
    }
    
    func redeemPoints(at coffeeShopId: String, amount: Int, description: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        do {
            try await supabase.rpc("redeem_points", parameters: [
                "user_id": userId,
                "coffee_shop_id": coffeeShopId,
                "amount": amount,
                "description": description
            ]).execute()
            
            // Update local user points
            if let currentUser = currentUser {
                self.currentUser = User(
                    id: currentUser.id,
                    name: currentUser.name,
                    email: currentUser.email,
                    profileImage: currentUser.profileImage,
                    communityId: currentUser.communityId,
                    points: currentUser.points - amount,
                    friends: currentUser.friends,
                    joinDate: currentUser.joinDate,
                    authUserId: currentUser.authUserId
                )
            }
            
            // Refresh transactions
            try await fetchUserTransactions()
        } catch {
            self.errorMessage = "Failed to redeem points: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Friends
    
    func fetchFriends() async throws {
        guard let userId = currentUser?.id else { return }
        
        do {
            let response: [User] = try await supabase
                .from("user_friends")
                .select("friend_id, friend_name, friend_email, friend_profile_image, friend_points")
                .eq("user_id", value: userId)
                .execute()
                .value
            
            self.friends = response
        } catch {
            self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
            throw error
        }
    }
    
    func sendFriendRequest(to userId: String) async throws {
        guard let fromUserId = currentUser?.id else { return }
        
        do {
            let friendRequest = FriendRequest(
                id: UUID().uuidString,
                fromUserId: fromUserId,
                toUserId: userId,
                status: .pending,
                date: Date()
            )
            
            try await supabase
                .from("friend_requests")
                .insert(friendRequest.toSupabaseDict())
                .execute()
        } catch {
            self.errorMessage = "Failed to send friend request: \(error.localizedDescription)"
            throw error
        }
    }
    
    func respondToFriendRequest(requestId: String, accept: Bool) async throws {
        do {
            let status: FriendRequestStatus = accept ? .accepted : .declined
            
            try await supabase
                .from("friend_requests")
                .update(["status": status.rawValue])
                .eq("id", value: requestId)
                .execute()
            
            // Refresh friend requests
            try await fetchFriendRequests()
            
            // If accepted, refresh friends list
            if accept {
                try await fetchFriends()
            }
        } catch {
            self.errorMessage = "Failed to respond to friend request: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchFriendRequests() async throws {
        guard let userId = currentUser?.id else { return }
        
        do {
            let response: [FriendRequest] = try await supabase
                .from("friend_requests")
                .select()
                .or("from_user_id.eq.\(userId),to_user_id.eq.\(userId)")
                .eq("status", value: "pending")
                .execute()
                .value
            
            self.friendRequests = response
        } catch {
            self.errorMessage = "Failed to fetch friend requests: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Real-time Subscriptions
    
    func setupRealtimeSubscriptions() {
        guard let userId = currentUser?.id else { return }
        
        // Listen for point balance changes
        Task {
            for await change in supabase.channel("user-changes").postgresChanges(
                InsertAction.self,
                schema: "public",
                table: "users",
                filter: "id=eq.\(userId)"
            ) {
                // Handle user updates
                DispatchQueue.main.async {
                    // Refresh user data
                    Task {
                        try await self.refreshCurrentUser()
                    }
                }
            }
        }
        
        // Listen for new friend requests
        Task {
            for await change in supabase.channel("friend-requests").postgresChanges(
                InsertAction.self,
                schema: "public",
                table: "friend_requests",
                filter: "to_user_id=eq.\(userId)"
            ) {
                // Handle new friend requests
                DispatchQueue.main.async {
                    Task {
                        try await self.fetchFriendRequests()
                    }
                }
            }
        }
    }
    
    private func refreshCurrentUser() async throws {
        guard let authUser = try? await supabase.auth.user(),
              let userId = currentUser?.id else { return }
        
        let response: [User] = try await supabase
            .from("users")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        if let user = response.first {
            self.currentUser = user
        }
    }
}

// MARK: - Custom Errors

enum SupabaseError: LocalizedError {
    case authenticationFailed
    case userNotFound
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed"
        case .userNotFound:
            return "User not found"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - Extensions for Supabase Compatibility

extension User {
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "profile_image_url": profileImage ?? NSNull(),
            "community_id": communityId,
            "points": points,
            "auth_user_id": authUserId ?? NSNull()
        ]
    }
}

extension FriendRequest {
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id,
            "from_user_id": fromUserId,
            "to_user_id": toUserId,
            "status": status.rawValue
        ]
    }
}