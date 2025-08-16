import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if appState.isFirstLaunch {
                CommunitySelectionView()
            } else if let community = appState.selectedCommunity {
                MainTabView()
                    .sheet(isPresented: $appState.showRegistrationPopup) {
                        RegistrationView()
                    }
            }
        }
    }
}