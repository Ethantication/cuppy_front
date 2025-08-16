import SwiftUI

struct TransferPointsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var supabaseManager = SupabaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFriend: User?
    @State private var pointsToSend = ""
    @State private var showingSuccess = false
    
    var userPoints: Int {
        appState.currentUser?.points ?? 0
    }
    
    var isValidTransfer: Bool {
        guard let points = Int(pointsToSend),
              points > 0,
              points <= userPoints,
              selectedFriend != nil else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.brown)
                    
                    Text("Send Points")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your Balance: \(userPoints) points")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Friend Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Friend")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVStack(spacing: 10) {
                                ForEach(supabaseManager.friends.filter { $0.id != appState.currentUser?.id }) { friend in
                                    FriendCard(
                                        friend: friend,
                                        isSelected: selectedFriend?.id == friend.id
                                    ) {
                                        selectedFriend = friend
                                    }
                                }
                            }
                        }
                        
                        // Points Input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Points to Send")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter points amount", text: $pointsToSend)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            if let points = Int(pointsToSend), points > 0 {
                                Text("≈ $\(Double(points) / 100.0, specifier: "%.2f") value")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer(minLength: 30)
                        
                        // Send Button
                        Button(action: {
                            sendPoints()
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Points")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(isValidTransfer ? Color.brown : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!isValidTransfer)
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
        .alert("Points Sent!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Successfully sent \(pointsToSend) points to \(selectedFriend?.name ?? "")")
        }
        .task {
            do {
                try await supabaseManager.fetchFriends()
            } catch {
                print("Failed to load friends: \(error)")
            }
        }
    }
    
    private func sendPoints() {
        guard let friend = selectedFriend,
              let points = Int(pointsToSend),
              points > 0 else { return }
        
        Task {
            do {
                try await supabaseManager.transferPoints(
                    to: friend.id,
                    amount: points,
                    description: "Sent to \(friend.name)"
                )
                showingSuccess = true
            } catch {
                print("Failed to transfer points: \(error)")
            }
        }
    }
}

struct FriendCard: View {
    let friend: User
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color.brown.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(friend.name.prefix(1)))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.brown)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(friend.points) points")
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

struct FriendsListView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Friends") {
                    ForEach(dataStore.sampleUsers) { user in
                        HStack {
                            Circle()
                                .fill(Color.brown.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(user.name.prefix(1)))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.brown)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text("\(user.points) points")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Add Friends") {
                    Button(action: {
                        // Add friend functionality
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.brown)
                            Text("Add from Contacts")
                        }
                    }
                    
                    Button(action: {
                        // Search friend functionality
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.brown)
                            Text("Search by Email")
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TransferPointsView()
        .environmentObject(AppState())
        .environmentObject(DataStore.shared)
}