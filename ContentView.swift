import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if appState.isFirstLaunch {
                CommunitySelectionView()
                    .environmentObject(appState)
            } else if let _ = appState.selectedCommunity {
                MainTabView()
                    .sheet(isPresented: $appState.showRegistrationPopup) {
                        RegistrationView()
                            .environmentObject(appState)
                    }
            }
        }
    }
}
