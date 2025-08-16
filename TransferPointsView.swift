import SwiftUI

struct TransferPointsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var supabaseService = SupabaseService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFriend: User?
    @State private var pointsToSend = ""
    @State private var showingSuccess = false
    @State private var friends: [User] = []
    
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
                                if supabaseService.isLoading {
                                    ProgressView("Loading friends...")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else if friends.isEmpty {
                                    Text("No friends available")
                                        .foregroundColor(.secondary)
                                        .padding()
                                } else {
                                    ForEach(friends.filter { $0.id != appState.currentUser?.id }) { friend in
                                        FriendCard(
                                            friend: friend,
                                            isSelected: selectedFriend?.id == friend.id
                                        ) {
                                            selectedFriend = friend
                                        }
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
        .onAppear {
            Task {
                await loadFriends()
            }
        }
    }
    
    private func sendPoints() {
        guard let friend = selectedFriend,
              let points = Int(pointsToSend),
              let currentUser = appState.currentUser else { return }
        
        Task {
            let success = await supabaseService.transferPoints(
                from: currentUser.id,
                to: friend.id,
                amount: points,
                description: "Points sent to \(friend.name)"
            )
            
            if success {
                // Update local user points
                let newPoints = currentUser.points - points
                await supabaseService.updateUserPoints(currentUser.id, newPoints: newPoints)
                
                // Update app state
                await MainActor.run {
                    appState.currentUser?.points = newPoints
                    showingSuccess = true
                }
            }
        }
    }
    
    private func loadFriends() async {
        // For now, we'll use sample data - replace with actual Supabase call
        let sampleFriends = [
            User(id: "user2", name: "Jane Smith", email: "jane@example.com", profileImage: "profile2", communityId: "nyc", points: 980, friends: ["user1", "user3"], joinDate: Date(), authUserId: nil),
            User(id: "user3", name: "Mike Johnson", email: "mike@example.com", profileImage: "profile3", communityId: "nyc", points: 1420, friends: ["user1", "user2"], joinDate: Date(), authUserId: nil)
        ]
        
        await MainActor.run {
            self.friends = sampleFriends
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
    @StateObject private var supabaseService = SupabaseService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var friends: [User] = []
    
    var body: some View {
        NavigationView {
            List {
                Section("Friends") {
                    if supabaseService.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading friends...")
                        }
                    } else if friends.isEmpty {
                        Text("No friends yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(friends) { user in
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
            .onAppear {
                Task {
                    await loadFriends()
                }
            }
        }
    }
    
    private func loadFriends() async {
        // For now, we'll use sample data - replace with actual Supabase call
        let sampleFriends = [
            User(id: "user2", name: "Jane Smith", email: "jane@example.com", profileImage: "profile2", communityId: "nyc", points: 980, friends: ["user1", "user3"], joinDate: Date(), authUserId: nil),
            User(id: "user3", name: "Mike Johnson", email: "mike@example.com", profileImage: "profile3", communityId: "nyc", points: 1420, friends: ["user1", "user2"], joinDate: Date(), authUserId: nil)
        ]
        
        await MainActor.run {
            self.friends = sampleFriends
        }
    }
}

#Preview {
    TransferPointsView()
        .environmentObject(AppState())
}