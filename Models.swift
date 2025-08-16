import Foundation

// MARK: - Community
struct Community: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let city: String
    let country: String
}

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let profileImage: String?
    let communityId: String
    var points: Int
    let friends: [String] // Friend IDs
    let joinDate: Date
    let authUserId: String? // Supabase Auth ID
}

// MARK: - Coffee Shop
struct CoffeeShop: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let imageUrl: String
    let pointsBackPercentage: Int
    let currentCrowdedness: Int // 0-100%
    let isQuietFriendly: Bool
    let openingHours: String
    let beverages: [Beverage]
    let communityId: String
}

// MARK: - Beverage
struct Beverage: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let category: BeverageCategory
}

enum BeverageCategory: String, Codable, CaseIterable {
    case coffee = "Coffee"
    case tea = "Tea"
    case cold = "Cold Drinks"
    case food = "Food"
}

// MARK: - Transaction
struct Transaction: Codable, Identifiable {
    let id: String
    let userId: String
    let coffeeShopId: String
    let type: TransactionType
    let amount: Int // points
    let date: Date
    let description: String
}

enum TransactionType: String, Codable {
    case earned
    case redeemed
    case sent
    case received
}

// MARK: - Friend Request
struct FriendRequest: Codable, Identifiable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let status: FriendRequestStatus
    let date: Date
}

enum FriendRequestStatus: String, Codable {
    case pending
    case accepted
    case declined
}
