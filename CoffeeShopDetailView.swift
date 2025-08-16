import SwiftUI

struct CoffeeShopDetailView: View {
    @EnvironmentObject var appState: AppState
    let coffeeShop: CoffeeShop
    
    @State private var selectedCategory: BeverageCategory = .coffee
    @State private var beverages: [Beverage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss
    
    var filteredBeverages: [Beverage] {
        beverages.filter { $0.category == selectedCategory }
    }
    
    var crowdednessColor: Color {
        switch coffeeShop.currentCrowdedness {
        case 0..<30: return .green
        case 30..<70: return .orange
        default: return .red
        }
    }
    
    var crowdednessText: String {
        switch coffeeShop.currentCrowdedness {
        case 0..<30: return "Quiet - Perfect for work"
        case 30..<70: return "Moderate crowd"
        default: return "Busy - Great atmosphere"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header Image
                    AsyncImage(url: URL(string: coffeeShop.imageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.brown.opacity(0.3)
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Basic Info
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(coffeeShop.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(coffeeShop.address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack {
                                Text("\(coffeeShop.pointsBackPercentage)%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.brown)
                                Text("points back")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Features Row
                        HStack(spacing: 20) {
                            VStack(spacing: 5) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(crowdednessColor)
                                        .frame(width: 12, height: 12)
                                    Text("\(coffeeShop.currentCrowdedness)%")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(crowdednessColor)
                                }
                                Text(crowdednessText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(12)
                            
                            VStack(spacing: 5) {
                                Image(systemName: coffeeShop.isQuietFriendly ? "moon.fill" : "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundColor(coffeeShop.isQuietFriendly ? .blue : .orange)
                                
                                Text(coffeeShop.isQuietFriendly ? "Quiet\nFriendly" : "Social\nAtmosphere")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Opening Hours
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Opening Hours")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.brown)
                                Text(coffeeShop.openingHours)
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Menu Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        // Category Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(BeverageCategory.allCases, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        Text(category.rawValue.capitalized)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedCategory == category ? .white : .brown)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(selectedCategory == category ? Color.brown : Color.brown.opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Menu Items
                        if isLoading {
                            ProgressView().padding()
                        } else if let errorMessage {
                            Text(errorMessage).foregroundColor(.red).padding()
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredBeverages) { beverage in
                                    BeverageRow(beverage: beverage)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await loadBeverages()
            }
        }
    }
    
    // MARK: - Load beverages from Supabase
    func loadBeverages() async {
        guard let communityId = appState.selectedCommunity?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            beverages = await SupabaseService.shared.fetchCoffeeShops(for: communityId)
                .first(where: { $0.id == coffeeShop.id })?.beverages ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct BeverageRow: View {
    let beverage: Beverage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(beverage.name)
                    .font(.headline)
                    .fontWeight(.medium)
                Text(beverage.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(beverage.price, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.brown)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}
