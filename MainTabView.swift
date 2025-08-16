import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {

            // MARK: - Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)

            // MARK: - Cup Me
            CupMeView()
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Cup Me")
                }
                .tag(1)

            // MARK: - Profile
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.brown) // Sets the selected tab color
        .onAppear {
            // Optional: do any setup if needed when tabs first appear
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(DataStore.shared) // if other views need it
}
