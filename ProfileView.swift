import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var communities: [Community] = []
    @State private var showingEditProfile = false
    @State private var showingCommunityChange = false
    @State private var showingLogoutAlert = false
    @State private var selectedCommunity: Community?

    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    if let user = appState.currentUser {
                        ProfileHeaderView(user: user) {
                            showingEditProfile = true
                        }
                    } else {
                        Button("Sign In") {
                            appState.showRegistrationPopup = true
                        }
                        .foregroundColor(.brown)
                    }
                }

                // Community Info
                Section("Community") {
                    if let community = appState.selectedCommunity {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.brown)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(community.name)
                                        .font(.headline)
                                        .fontWeight(.medium)

                                    Text("\(community.city), \(community.country)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)

                        Button("Change Community") {
                            showingCommunityChange = true
                        }
                        .foregroundColor(.brown)
                    }
                }

                // Statistics
                if let user = appState.currentUser {
                    Section("Your Stats") {
                        StatRow(icon: "star.fill", title: "Total Points", value: "\(user.points)")
                        StatRow(icon: "person.2.fill", title: "Friends", value: "\(user.friends.count)")
                        StatRow(icon: "calendar", title: "Member Since", value: user.joinDate, style: .date)
                        StatRow(icon: "cup.and.saucer.fill", title: "Favorite Shop", value: "—")
                    }
                }

                // Settings
                Section("Settings") {
                    SettingsRow(icon: "bell.fill", title: "Notifications", hasDisclosure: true)
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", hasDisclosure: true)
                    SettingsRow(icon: "doc.text.fill", title: "Terms & Privacy", hasDisclosure: true)
                }

                // Account Actions
                Section {
                    if appState.currentUser != nil {
                        Button("Sign Out") {
                            showingLogoutAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingCommunityChange) {
            CommunityChangeView(communities: communities, selectedCommunity: $selectedCommunity)
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                appState.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            Task {
                communities = await supabaseService.fetchCommunities()
                selectedCommunity = appState.selectedCommunity
            }
        }
    }
}

// Modified CommunityChangeView to use Supabase communities
struct CommunityChangeView: View {
    let communities: [Community]
    @Binding var selectedCommunity: Community?
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select a new community")
                    .font(.headline)
                    .padding(.top, 20)

                LazyVStack(spacing: 15) {
                    ForEach(communities) { community in
                        CommunityCard(
                            community: community,
                            isSelected: selectedCommunity?.id == community.id
                        ) {
                            selectedCommunity = community
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                Button("Switch Community") {
                    if let community = selectedCommunity {
                        appState.selectCommunity(community)
                        dismiss()
                    }
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(selectedCommunity != nil ? Color.brown : Color.gray)
                .cornerRadius(12)
                .disabled(selectedCommunity == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .navigationTitle("Change Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if selectedCommunity == nil {
                selectedCommunity = appState.selectedCommunity
            }
        }
    }
}
