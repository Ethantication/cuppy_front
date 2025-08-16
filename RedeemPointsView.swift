import SwiftUI

struct RedeemPointsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoffeeShop: CoffeeShop?
    @State private var pointsToRedeem = ""
    @State private var showingQRCode = false
    @State private var showingSuccess = false
    
    var coffeeShopsInCommunity: [CoffeeShop] {
        dataStore.coffeeShops.filter { $0.communityId == appState.selectedCommunity?.id }
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
            QRCodeView(
                coffeeShop: selectedCoffeeShop!,
                points: Int(pointsToRedeem)!,
                onSuccess: {
                    showingSuccess = true
                    showingQRCode = false
                }
            )
        }
        .alert("Points Redeemed!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Successfully redeemed \(pointsToRedeem) points at \(selectedCoffeeShop?.name ?? "")")
        }
    }
}

struct RedeemCoffeeShopCard: View {
    let coffeeShop: CoffeeShop
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color.brown.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.brown)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coffeeShop.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(coffeeShop.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .brown : .gray)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brown : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QRCodeView: View {
    let coffeeShop: CoffeeShop
    let points: Int
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var timer: Timer?
    @State private var countdown = 30
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Show this QR code to the cashier")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // QR Code Placeholder
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 200, height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "qrcode")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("QR CODE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    )
                    .cornerRadius(20)
                
                VStack(spacing: 10) {
                    Text(coffeeShop.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(points) points")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text("≈ $\(Double(points) / 100.0, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Text("This code expires in \(countdown) seconds")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Simulate Successful Redemption") {
                    onSuccess()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.green)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startCountdown()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
                dismiss()
            }
        }
    }
}

#Preview {
    RedeemPointsView()
        .environmentObject(AppState())
        .environmentObject(DataStore.shared)
}