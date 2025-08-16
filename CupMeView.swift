import SwiftUI

struct CupMeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var friends: [User] = []
    @State private var transactions: [Transaction] = []
    
    @State private var showingRedeemSheet = false
    @State private var showingTransferSheet = false
    @State private var showingFriendsList = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Points Header
                    VStack(spacing: 15) {
                        Text("Your Balance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(appState.currentUser?.points ?? 0)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.brown)
                        
                        Text("Points")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    HStack(spacing: 15) {
                        Button(action: { showingRedeemSheet = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "gift")
                                    .font(.title2)
                                Text("Redeem")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(Color.brown)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingTransferSheet = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                    .font(.title2)
                                Text("Send")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.brown)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(Color.brown.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Friends Leaderboard
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Friends Leaderboard")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("View All") {
                                showingFriendsList = true
                            }
                            .foregroundColor(.brown)
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 10) {
                            ForEach(Array(friends.sorted(by: { $0.points > $1.points }).enumerated()), id: \.element.id) { index, user in
                                FriendLeaderboardRow(user: user, rank: index + 1, isCurrentUser: user.id == appState.currentUser?.id)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 10) {
                            ForEach(transactions) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Cup Me")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
        .sheet(isPresented: $showingRedeemSheet) {
            RedeemPointsView()
        }
        .sheet(isPresented: $showingTransferSheet) {
            TransferPointsView()
        }
        .sheet(isPresented: $showingFriendsList) {
            FriendsListView()
        }
    }
    
    // MARK: - Data Loading
    private func loadData() async {
        guard let currentUser = appState.currentUser else { return }
        
        // Fetch friends and transactions from Supabase
        friends = await supabaseService.fetchFriends(for: currentUser.id)
        transactions = await supabaseService.fetchUserTransactions(currentUser.id)
    }
}

// MARK: - Friend Row
struct FriendLeaderboardRow: View {
    let user: User
    let rank: Int
    let isCurrentUser: Bool
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 30, height: 30)
                
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor == .clear ? .secondary : rankColor)
            }
            
            // Profile
            Circle()
                .fill(Color.brown.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(user.name.prefix(1)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                )
            
            // Name and points
            VStack(alignment: .leading, spacing: 2) {
                Text(isCurrentUser ? "\(user.name) (You)" : user.name)
                    .font(.headline)
                    .fontWeight(isCurrentUser ? .bold : .medium)
                
                Text("\(user.points) points")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if rank <= 3 {
                Image(systemName: "trophy.fill")
                    .foregroundColor(rankColor)
            }
        }
        .padding()
        .background(isCurrentUser ? Color.brown.opacity(0.1) : Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    
    var icon: String {
        switch transaction.type {
        case .earned: return "plus.circle.fill"
        case .redeemed: return "gift.fill"
        case .sent: return "paperplane.fill"
        case .received: return "arrow.down.circle.fill"
        }
    }
    
    var color: Color {
        switch transaction.type {
        case .earned, .received: return .green
        case .redeemed, .sent: return .orange
        }
    }
    
    var prefix: String {
        switch transaction.type {
        case .earned, .received: return "+"
        case .redeemed, .sent: return "-"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(prefix)\(transaction.amount)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    CupMeView()
        .environmentObject(AppState())
}
