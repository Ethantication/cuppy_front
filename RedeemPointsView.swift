import SwiftUI

struct RedeemPointsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var supabaseService = SupabaseService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoffeeShop: CoffeeShop?
    @State private var pointsToRedeem = ""
    @State private var showingQRCode = false
    @State private var showingSuccess = false
    @State private var coffeeShops: [CoffeeShop] = []

    var coffeeShopsInCommunity: [CoffeeShop] {
        coffeeShops.filter { $0.communityId == appState.selectedCommunity?.id }
    }

    var userPoints: Int {
        appState.currentUser?.points ?? 0
    }

    var isValidRedemption: Bool {
        guard let points = Int(pointsToRedeem),
              points > 0,
              points <= userPoints,
              selectedCoffeeShop != nil else {
            return false
        }
        return true
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.brown)

                    Text("Redeem Points")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Your Balance: \(userPoints) points")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        // Coffee Shop Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Coffee Shop")
                                .font(.headline)
                                .fontWeight(.semibold)

                            LazyVStack(spacing: 10) {
                                ForEach(coffeeShopsInCommunity) { coffeeShop in
                                    RedeemCoffeeShopCard(
                                        coffeeShop: coffeeShop,
                                        isSelected: selectedCoffeeShop?.id == coffeeShop.id
                                    ) {
                                        selectedCoffeeShop = coffeeShop
                                    }
                                }
                            }
                        }

                        // Points Input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Points to Redeem")
                                .font(.headline)
                                .fontWeight(.semibold)

                            TextField("Enter points amount", text: $pointsToRedeem)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)

                            if let points = Int(pointsToRedeem), points > 0 {
                                Text("≈ $\(Double(points) / 100.0, specifier: "%.2f") value")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer(minLength: 20)

                        // Redemption Method
                        if isValidRedemption {
                            VStack(spacing: 15) {
                                Text("Redemption Method")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                VStack(spacing: 12) {
                                    // Show QR Code
                                    Button(action: {
                                        showingQRCode = true
                                    }) {
                                        HStack {
                                            Image(systemName: "qrcode")
                                                .font(.title2)

                                            VStack(alignment: .leading) {
                                                Text("Show QR Code")
                                                    .font(.headline)
                                                    .fontWeight(.medium)

                                                Text("Let the coffee shop scan your code")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }

                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.brown)
                                        .cornerRadius(12)
                                    }

                                    // Share User ID
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Or share your User ID:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        HStack {
                                            Text(appState.currentUser?.id.prefix(8).uppercased() ?? "")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.brown)

                                            Spacer()

                                            Button("Copy") {
                                                UIPasteboard.general.string = appState.currentUser?.id
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(.brown)
                                        }
                                        .padding()
                                        .background(Color(.systemGroupedBackground))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingQRCode) {
            if let selectedCoffeeShop = selectedCoffeeShop, let points = Int(pointsToRedeem) {
                QRCodeView(
                    coffeeShop: selectedCoffeeShop,
                    points: points,
                    onSuccess: {
                        showingSuccess = true
                        showingQRCode = false
                    }
                )
            }
        }
        .alert("Points Redeemed!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Successfully redeemed \(pointsToRedeem) points at \(selectedCoffeeShop?.name ?? "")")
        }
        .onAppear {
            Task {
                if let communityId = appState.selectedCommunity?.id {
                    coffeeShops = await supabaseService.fetchCoffeeShops(for: communityId)
                }
            }
        }
    }
}
