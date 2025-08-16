import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingCoffeeShopDetail = false
    @State private var selectedCoffeeShop: CoffeeShop?
    @State private var coffeeShops: [CoffeeShop] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var coffeeShopsInCommunity: [CoffeeShop] {
        coffeeShops.filter { $0.communityId == appState.selectedCommunity?.id }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        if let community = appState.selectedCommunity {
                            Text("Welcome to")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(community.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.brown)
                        }

                        if let user = appState.currentUser {
                            Text("You have \(user.points) points")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Loading indicator
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading coffee shops...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }

                    // Error message
                    if let errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Coffee Shops
                    ForEach(coffeeShopsInCommunity) { coffeeShop in
                        CoffeeShopCard(coffeeShop: coffeeShop) {
                            selectedCoffeeShop = coffeeShop
                            showingCoffeeShopDetail = true
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadData()
            }
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
        .sheet(isPresented: $showingCoffeeShopDetail) {
            if let coffeeShop = selectedCoffeeShop {
                CoffeeShopDetailView(coffeeShop: coffeeShop)
            }
        }
    }

    // MARK: - Load data from Supabase
    private func loadData() async {
        guard let communityId = appState.selectedCommunity?.id else { return }

        isLoading = true
        errorMessage = nil

        async let shopsResult = SupabaseService.shared.fetchCoffeeShops(for: communityId)
        async let userResult = appState.currentUser != nil
            ? SupabaseService.shared.fetchUser(by: appState.currentUser!.id)
            : nil

        do {
            let shops = try await shopsResult
            await MainActor.run {
                self.coffeeShops = shops
            }

            if let updatedUser = try await userResult {
                await MainActor.run {
                    appState.currentUser = updatedUser
                }
            }

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }

        await MainActor.run {
            self.isLoading = false
        }
    }
}

// MARK: - CoffeeShop Card
struct CoffeeShopCard: View {
    let coffeeShop: CoffeeShop
    let onTap: () -> Void

    var crowdednessColor: Color {
        switch coffeeShop.currentCrowdedness {
        case 0..<30: return .green
        case 30..<70: return .orange
        default: return .red
        }
    }

    var crowdednessText: String {
        switch coffeeShop.currentCrowdedness {
        case 0..<30: return "Quiet"
        case 30..<70: return "Moderate"
        default: return "Busy"
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {

                // Image placeholder
                Rectangle()
                    .fill(Color.brown.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.brown)
                    )
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 10) {
                    // Header with name and points back
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(coffeeShop.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text(coffeeShop.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack {
                            Text("\(coffeeShop.pointsBackPercentage)%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.brown)
                            Text("points back")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Crowdedness
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(crowdednessColor)
                                .frame(width: 10, height: 10)

                            Text(crowdednessText)
                                .font(.subheadline)
                                .foregroundColor(crowdednessColor)

                            Text("(\(coffeeShop.currentCrowdedness)%)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if coffeeShop.isQuietFriendly {
                            HStack(spacing: 4) {
                                Image(systemName: "moon.fill")
                                    .font(.caption)
                                Text("Quiet")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }

                    // Opening hours
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(coffeeShop.openingHours)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}
