import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @State private var showingEditProfile = false
    @State private var showingCommunityChange = false
    @State private var showingLogoutAlert = false
    
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
                        StatRow(icon: "cup.and.saucer.fill", title: "Favorite Shop", value: "Blue Bottle Coffee")
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
            CommunityChangeView()
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await appState.logout()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct ProfileHeaderView: View {
    let user: User
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile Image
            Circle()
                .fill(Color.brown.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(user.name.prefix(1)))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.brown)
                        .font(.caption)
                    
                    Text("\(user.points) points")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.brown)
                }
            }
            
            Spacer()
            
            Button("Edit") {
                onEdit()
            }
            .font(.subheadline)
            .foregroundColor(.brown)
        }
        .padding(.vertical, 8)
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let style: Text.DateStyle?
    
    init(icon: String, title: String, value: String) {
        self.icon = icon
        self.title = title
        self.value = value
        self.style = nil
    }
    
    init(icon: String, title: String, value: Date, style: Text.DateStyle) {
        self.icon = icon
        self.title = title
        self.value = ""
        self.style = style
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brown)
                .font(.title3)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if let style = style {
                Text(Date(), style: style)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let hasDisclosure: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brown)
                .font(.title3)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if hasDisclosure {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Profile Picture") {
                    Button("Change Photo") {
                        // Photo picker functionality
                    }
                    .foregroundColor(.brown)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save profile changes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let user = appState.currentUser {
                name = user.name
                email = user.email
            }
        }
    }
}

struct CommunityChangeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCommunity: Community?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select a new community")
                    .font(.headline)
                    .padding(.top, 20)
                
                LazyVStack(spacing: 15) {
                    ForEach(dataStore.communities) { community in
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
            selectedCommunity = appState.selectedCommunity
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
        .environmentObject(DataStore.shared)
}