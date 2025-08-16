# Cuppy - Local Coffee Community Hub

A SwiftUI mobile application that connects coffee lovers within local communities, allowing them to earn and redeem points, discover coffee shops, and interact with friends.

## Features

### 🏘️ Community Selection
- First-time users select their local coffee community by city
- Each community has a unique ID and displays partnered coffee shops
- Users can switch communities from their profile

### 👤 User Registration & Authentication
- Multiple registration options:
  - Google Sign-In
  - Apple Sign-In  
  - Email & Password
- Optional registration (can skip initially)
- Profile management with name, email, and photo

### ☕ Coffee Shop Dashboard
- Browse all partnered coffee shops in your community
- Real-time crowdedness tracker (0-100%)
- Points back percentage display for each shop
- Quiet-friendly indicators
- Coffee shop details including:
  - Menu with beverages categorized by type
  - Opening hours
  - Crowdedness level with color-coded indicators
  - Atmosphere ratings (quiet vs social)

### 🏆 Cup Me - Points & Social Features
- **Points System:**
  - Earn points from coffee shop purchases
  - Redeem points for rewards
  - Send points to friends
  - View transaction history

- **Friends & Leaderboard:**
  - Weekly friend competition rankings
  - Add friends from contacts or by email search
  - Trophy system for top performers
  - Social point transfers

- **Redemption Methods:**
  - QR code generation for coffee shop scanning
  - Unique user ID sharing (8-character display)
  - Dual redemption validation (user or shop initiated)

### 👤 Profile Management
- Edit personal information
- View community details and statistics
- Change communities
- Track personal stats (points, friends, join date)
- Settings for notifications and support
- Sign out functionality

## App Architecture

### File Structure
```
/workspace/
├── CuppyApp.swift          # Main app entry point
├── AppState.swift          # Global state management
├── Models.swift            # Data models and hardcoded data
├── ContentView.swift       # Main content router
├── CommunitySelectionView.swift    # First-time community selection
├── RegistrationView.swift          # User registration popup
├── MainTabView.swift              # Main tab navigation
├── DashboardView.swift            # Coffee shops dashboard
├── CoffeeShopDetailView.swift     # Individual shop details
├── CupMeView.swift               # Points and social features
├── RedeemPointsView.swift        # Points redemption flow
├── TransferPointsView.swift      # Send points to friends
└── ProfileView.swift             # User profile and settings
```

### Data Models
- **Community**: City-based coffee communities
- **User**: User profiles with points and friends
- **CoffeeShop**: Shop details, menu, and crowdedness
- **Beverage**: Menu items with categories
- **Transaction**: Points earning/spending history

### Key Features Implementation

#### First Launch Flow
1. Community selection screen
2. Registration popup (optional)
3. Main dashboard access

#### Navigation Structure
- Tab-based navigation with 3 main sections:
  - Dashboard (coffee shops)
  - Cup Me (points & social)
  - Profile (user management)

#### State Management
- Uses `@StateObject` and `@EnvironmentObject` for app-wide state
- UserDefaults persistence for user data and community selection
- Reactive UI updates based on state changes

## Hardcoded Sample Data

The app includes comprehensive sample data for testing:
- 5 different coffee communities (NYC, LA, SF, London, Paris)
- 3 sample coffee shops with full details
- Sample users with varying point totals
- Transaction history examples
- Complete beverage menus with categories

## Technical Requirements

- iOS 15.0+
- SwiftUI
- Xcode 13.0+

## Running the App

1. Open the project in Xcode
2. Select a simulator or device
3. Build and run the project
4. Experience the full flow from community selection to points redemption

## App Flow Summary

1. **First Launch**: Select community → Optional registration → Dashboard
2. **Returning User**: Direct to dashboard of selected community
3. **Dashboard**: Browse coffee shops → View details → See crowdedness
4. **Cup Me**: Manage points → View leaderboard → Transfer to friends
5. **Profile**: Edit info → Change community → View stats

The app provides a complete coffee community experience with modern SwiftUI design patterns and intuitive user interactions.