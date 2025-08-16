import SwiftUI

struct CommunitySelectionView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var selectedCommunity: Community?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.brown)
                    
                    Text("Welcome to Cuppy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Choose your local coffee community")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Community List
                                        if supabaseManager.isLoading {
                            LoadingView(message: "Loading communities...")
                        } else if let errorMessage = supabaseManager.errorMessage {
                            ErrorView(message: errorMessage) {
                                Task {
                                    do {
                                        try await supabaseManager.fetchCommunities()
                                    } catch {
                                        print("Failed to retry loading communities: \(error)")
                                    }
                                }
                            }
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(supabaseManager.communities) { community in
                                    CommunityCard(
                                        community: community,
                                        isSelected: selectedCommunity?.id == community.id
                                    ) {
                                        selectedCommunity = community
                                    }
                                }
                            }
                        }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    if let community = selectedCommunity {
                        appState.selectCommunity(community)
                    }
                }) {
                    HStack {
                        Text("Join Community")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        selectedCommunity != nil ? Color.brown : Color.gray
                    )
                    .cornerRadius(12)
                }
                .disabled(selectedCommunity == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .background(Color(.systemGroupedBackground))
            .task {
                do {
                    try await supabaseManager.fetchCommunities()
                } catch {
                    print("Failed to load communities: \(error)")
                }
            }
        }
    }
}

struct CommunityCard: View {
    let community: Community
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(community.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(community.city), \(community.country)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .brown : .gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brown : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CommunitySelectionView()
        .environmentObject(AppState())
        .environmentObject(DataStore.shared)
}