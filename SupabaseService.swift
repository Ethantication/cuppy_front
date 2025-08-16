import Foundation
import Combine
import Supabase

// MARK: - Supabase Service
final class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    @Published var isLoading = false
    @Published var error: String?
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.shared.supabaseURL,
            supabaseKey: SupabaseConfig.shared.supabaseAnonKey
        )
    }
    
    // MARK: - Error Handling
    @MainActor
    private func handleError(_ error: Error) {
        self.error = error.localizedDescription
        self.isLoading = false
    }
    
    @MainActor
    private func clearError() {
        self.error = nil
    }
    
    // MARK: - Communities
    @MainActor
    func fetchCommunities() async -> [Community] {
        isLoading = true
        clearError()
        
        do {
            let response = try await client.database
                .from("communities")
                .select()
                .execute()
            
            guard let communities = response.decoded(to: [Community].self) else {
                throw NSError(domain: "SupabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode communities"])
            }
            
            isLoading = false
            return communities
        } catch {
            await handleError(error)
            return []
        }
    }
    
    // MARK: - Coffee Shops
    @MainActor
    func fetchCoffeeShops(for communityId: String) async -> [CoffeeShop] {
        isLoading = true
        clearError()
        
        do {
            let response = try await client.database
                .from("coffee_shops")
                .select()
                .eq(column: "community_id", value: communityId)
                .execute()
            
            guard let coffeeShops = response.decoded(to: [CoffeeShop].self) else {
                throw NSError(domain: "SupabaseService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode coffee shops"])
            }
            
            isLoading = false
            return coffeeShops
        } catch {
            await handleError(error)
            return []
        }
    }
    
    // MARK: - Users
    @MainActor
    func createUser(_ user: User) async -> Bool {
        isLoading = true
        clearError()
        
        do {
            try await client.database
                .from("users")
                .insert(values: user)
                .execute()
            
            isLoading = false
            return true
        } catch {
            await handleError(error)
            return false
        }
    }
    
    @MainActor
    func fetchUser(by authUserId: String) async -> User? {
        isLoading = true
        clearError()
        
        do {
            let response = try await client.database
                .from("users")
                .select()
                .eq(column: "auth_user_id", value: authUserId)
                .single()
                .execute()
            
            guard let user = response.decoded(to: User.self) else {
                throw NSError(domain: "SupabaseService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user"])
            }
            
            isLoading = false
            return user
        } catch {
            await handleError(error)
            return nil
        }
    }
    
    @MainActor
    func updateUserPoints(_ userId: String, newPoints: Int) async -> Bool {
        isLoading = true
        clearError()
        
        do {
            try await client.database
                .from("users")
                .update(values: ["points": newPoints])
                .eq(column: "id", value: userId)
                .execute()
            
            isLoading = false
            return true
        } catch {
            await handleError(error)
            return false
        }
    }
    
    // MARK: - Transactions
    @MainActor
    func createTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        clearError()
        
        do {
            try await client.database
                .from("transactions")
                .insert(values: transaction)
                .execute()
            
            isLoading = false
            return true
        } catch {
            await handleError(error)
            return false
        }
    }
    
    @MainActor
    func fetchUserTransactions(_ userId: String) async -> [Transaction] {
        isLoading = true
        clearError()
        
        do {
            let response = try await client.database
                .from("user_transaction_history")
                .select()
                .eq(column: "user_id", value: userId)
                .order(column: "created_at", ascending: false)
                .execute()
            
            guard let transactions = response.decoded(to: [Transaction].self) else {
                throw NSError(domain: "SupabaseService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode transactions"])
            }
            
            isLoading = false
            return transactions
        } catch {
            await handleError(error)
            return []
        }
    }
    
    // MARK: - Friends
    @MainActor
    func sendFriendRequest(from userId: String, to friendId: String) async -> Bool {
        isLoading = true
        clearError()
        
        do {
            try await client.database
                .from("friend_requests")
                .insert(values: ["from_user_id": userId, "to_user_id": friendId, "status": "pending"])
                .execute()
            
            isLoading = false
            return true
        } catch {
            await handleError(error)
            return false
        }
    }
    
    @MainActor
    func transferPoints(from senderId: String, to receiverId: String, amount: Int, description: String) async -> Bool {
        isLoading = true
        clearError()
        
        do {
            try await client.rpc(
                "transfer_points",
                parameters: ["sender_id": senderId, "receiver_id": receiverId, "amount": amount, "description": description]
            ).execute()
            
            isLoading = false
            return true
        } catch {
            await handleError(error)
            return false
        }
    }
    
    // MARK: - Real-time Updates (Optional)
    func subscribeToPointUpdates(for userId: String) {
        // Implement Supabase real-time subscription here if needed
    }
    
    func unsubscribeFromUpdates() {
        // Remove subscription
    }
}
