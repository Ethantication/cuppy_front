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
    let points: Int
    let friends: [String] // Friend IDs
    let joinDate: Date
    let authUserId: String? // Links to Supabase Auth
    
    // Custom coding keys to match database schema
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profileImage = "profile_image_url"
        case communityId = "community_id"
        case points
        case friends
        case joinDate = "join_date"
        case authUserId = "auth_user_id"
    }
}

// MARK: - Coffee Shop
struct CoffeeShop: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let imageUrl: String?
    let pointsBackPercentage: Int
    let currentCrowdedness: Int // 0-100%
    let isQuietFriendly: Bool
    let openingHours: String?
    let beverages: [Beverage]
    let communityId: String
    
    // Custom coding keys to match database schema
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case imageUrl = "image_url"
        case pointsBackPercentage = "points_back_percentage"
        case currentCrowdedness = "current_crowdedness"
        case isQuietFriendly = "is_quiet_friendly"
        case openingHours = "opening_hours"
        case beverages
        case communityId = "community_id"
    }
}

// MARK: - Beverage
struct Beverage: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
    let description: String?
    let category: BeverageCategory
    let coffeeShopId: String?
    
    // Custom coding keys to match database schema
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case description
        case category
        case coffeeShopId = "coffee_shop_id"
    }
}

enum BeverageCategory: String, Codable, CaseIterable {
    case coffee = "coffee"
    case tea = "tea"
    case cold = "cold_drinks"
    case food = "food"
    
    var displayName: String {
        switch self {
        case .coffee: return "Coffee"
        case .tea: return "Tea"
        case .cold: return "Cold Drinks"
        case .food: return "Food"
        }
    }
}

// MARK: - Transaction
struct Transaction: Codable, Identifiable {
    let id: String
    let userId: String
    let coffeeShopId: String?
    let relatedUserId: String?
    let type: TransactionType
    let amount: Int // points
    let date: Date
    let description: String?
    let coffeeShopName: String?
    let coffeeShopAddress: String?
    let relatedUserName: String?
    let relatedUserEmail: String?
    
    // Custom coding keys to match database schema
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case coffeeShopId = "coffee_shop_id"
        case relatedUserId = "related_user_id"
        case type = "transaction_type"
        case amount
        case date = "created_at"
        case description
        case coffeeShopName = "coffee_shop_name"
        case coffeeShopAddress = "coffee_shop_address"
        case relatedUserName = "related_user_name"
        case relatedUserEmail = "related_user_email"
    }
}

enum TransactionType: String, Codable {
    case earned = "earned"
    case redeemed = "redeemed"
    case sent = "sent"
    case received = "received"
}

// MARK: - Friend Request
struct FriendRequest: Codable, Identifiable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let status: FriendRequestStatus
    let date: Date
    
    // Custom coding keys to match database schema
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case status
        case date = "created_at"
    }
}

enum FriendRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
}

// MARK: - Hardcoded Data
class DataStore: ObservableObject {
    static let shared = DataStore()
    
    let communities: [Community] = [
        Community(id: "nyc", name: "NYC Coffee Community", city: "New York", country: "USA"),
        Community(id: "la", name: "LA Coffee Hub", city: "Los Angeles", country: "USA"),
        Community(id: "sf", name: "SF Bay Area Coffee", city: "San Francisco", country: "USA"),
        Community(id: "london", name: "London Coffee Circle", city: "London", country: "UK"),
        Community(id: "paris", name: "Paris Café Community", city: "Paris", country: "France")
    ]
    
    let coffeeShops: [CoffeeShop] = [
        CoffeeShop(
            id: "shop1",
            name: "Blue Bottle Coffee",
            address: "123 Main St, NYC",
            imageUrl: "coffeeshop1",
            pointsBackPercentage: 15,
            currentCrowdedness: 75,
            isQuietFriendly: true,
            openingHours: "6:00 AM - 8:00 PM",
            beverages: [
                Beverage(id: "b1", name: "Espresso", price: 3.50, description: "Rich and bold", category: .coffee, coffeeShopId: "shop1"),
                Beverage(id: "b2", name: "Cappuccino", price: 4.50, description: "Creamy and smooth", category: .coffee, coffeeShopId: "shop1"),
                Beverage(id: "b3", name: "Croissant", price: 3.00, description: "Buttery and flaky", category: .food, coffeeShopId: "shop1")
            ],
            communityId: "nyc"
        ),
        CoffeeShop(
            id: "shop2",
            name: "Stumptown Coffee",
            address: "456 Coffee Ave, NYC",
            imageUrl: "coffeeshop2",
            pointsBackPercentage: 12,
            currentCrowdedness: 45,
            isQuietFriendly: false,
            openingHours: "7:00 AM - 9:00 PM",
            beverages: [
                Beverage(id: "b4", name: "Cold Brew", price: 4.00, description: "Smooth and refreshing", category: .cold, coffeeShopId: "shop2"),
                Beverage(id: "b5", name: "Latte", price: 5.00, description: "Perfect milk foam", category: .coffee, coffeeShopId: "shop2"),
                Beverage(id: "b6", name: "Green Tea", price: 3.00, description: "Organic and fresh", category: .tea, coffeeShopId: "shop2")
            ],
            communityId: "nyc"
        ),
        CoffeeShop(
            id: "shop3",
            name: "Joe Coffee",
            address: "789 Brew St, NYC",
            imageUrl: "coffeeshop3",
            pointsBackPercentage: 18,
            currentCrowdedness: 90,
            isQuietFriendly: true,
            openingHours: "6:30 AM - 7:30 PM",
            beverages: [
                Beverage(id: "b7", name: "Americano", price: 3.75, description: "Classic and strong", category: .coffee, coffeeShopId: "shop3"),
                Beverage(id: "b8", name: "Matcha Latte", price: 5.50, description: "Creamy matcha goodness", category: .tea, coffeeShopId: "shop3"),
                Beverage(id: "b9", name: "Blueberry Muffin", price: 3.50, description: "Fresh baked daily", category: .food, coffeeShopId: "shop3")
            ],
            communityId: "nyc"
        )
    ]
    
    let sampleUsers: [User] = [
        User(id: "user1", name: "John Doe", email: "john@example.com", profileImage: "profile1", communityId: "nyc", points: 1250, friends: ["user2", "user3"], joinDate: Date(), authUserId: nil),
        User(id: "user2", name: "Jane Smith", email: "jane@example.com", profileImage: "profile2", communityId: "nyc", points: 980, friends: ["user1", "user3"], joinDate: Date(), authUserId: nil),
        User(id: "user3", name: "Mike Johnson", email: "mike@example.com", profileImage: "profile3", communityId: "nyc", points: 1420, friends: ["user1", "user2"], joinDate: Date(), authUserId: nil)
    ]
    
    let sampleTransactions: [Transaction] = [
        Transaction(id: "t1", userId: "user1", coffeeShopId: "shop1", relatedUserId: nil, type: .earned, amount: 50, date: Date(), description: "Cappuccino purchase", coffeeShopName: nil, coffeeShopAddress: nil, relatedUserName: nil, relatedUserEmail: nil),
        Transaction(id: "t2", userId: "user1", coffeeShopId: "shop2", relatedUserId: nil, type: .redeemed, amount: 100, date: Date(), description: "Free latte", coffeeShopName: nil, coffeeShopAddress: nil, relatedUserName: nil, relatedUserEmail: nil),
        Transaction(id: "t3", userId: "user1", coffeeShopId: nil, relatedUserId: "user2", type: .sent, amount: 25, date: Date(), description: "Sent to Jane", coffeeShopName: nil, coffeeShopAddress: nil, relatedUserName: "Jane Smith", relatedUserEmail: nil)
    ]
}