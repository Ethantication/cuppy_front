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
                        Button(action: { sendPoints() }) {
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
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .alert("Points Sent!", isPresented: $showingSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Successfully sent \(pointsToSend) points to \(selectedFriend?.name ?? "")")
        }
        .task {
            await loadFriends()
        }
    }

    // MARK: - Send Points
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

    // MARK: - Load Friends
    private func loadFriends() async {
        guard let currentUser = appState.currentUser else { return }

        // Fetch friends from Supabase
        let allUsers = await supabaseService.fetchCommunities() // Replace this with a proper query if needed

        // Filter only friends of current user
        let friendsList = allUsers.filter { currentUser.friends.contains($0.id) }

        await MainActor.run {
            self.friends = friendsList
        }
    }
}
