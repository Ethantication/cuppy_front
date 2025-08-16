# Supabase Integration Guide

This guide explains how to configure and use the Supabase database integration in your Cuppy app.

## Prerequisites

1. A Supabase project with the database schema set up (see `DATABASE_SETUP.md`)
2. Your Supabase project URL and anon key

## Configuration

### 1. Update SupabaseConfig.swift

Open `SupabaseConfig.swift` and replace the placeholder values with your actual Supabase credentials:

```swift
private init() {
    self.supabaseURL = "https://your-project-id.supabase.co"
    self.supabaseAnonKey = "your-actual-anon-key-here"
}
```

### 2. Install Supabase Swift Package

Add the Supabase Swift package to your Xcode project:

1. In Xcode, go to File → Add Package Dependencies
2. Enter the URL: `https://github.com/supabase-community/supabase-swift`
3. Select the latest version and add it to your target

### 3. Update SupabaseService.swift

Once you have the Supabase package installed, replace the placeholder API calls in `SupabaseService.swift` with actual Supabase calls.

For example, replace:

```swift
// Simulate API call for now - replace with actual Supabase call
// In production, this would be:
// let response = try await supabase.from("communities").select("*").execute()
```

With:

```swift
let response = try await supabase.from("communities").select("*").execute()
let communities: [Community] = try response.decoded()
return communities
```

## Current Status

The app has been updated to use a `SupabaseService` class that:

- ✅ Replaces the hardcoded `DataStore` class
- ✅ Provides async/await API methods for all database operations
- ✅ Includes loading states and error handling
- ✅ Maintains the same UI while preparing for real database integration
- ⚠️ Currently uses simulated API calls (you need to replace these with real Supabase calls)

## Files Modified

- `SupabaseConfig.swift` - Configuration file for Supabase credentials
- `SupabaseService.swift` - Service class for all database operations
- `Models.swift` - Updated to include `authUserId` field
- `AppState.swift` - Integrated with SupabaseService for user creation
- `DashboardView.swift` - Now loads coffee shops from SupabaseService
- `CommunitySelectionView.swift` - Now loads communities from SupabaseService

## Next Steps

1. **Configure Supabase credentials** in `SupabaseConfig.swift`
2. **Install the Supabase Swift package** in Xcode
3. **Replace simulated API calls** with real Supabase calls in `SupabaseService.swift`
4. **Test the integration** with your actual database
5. **Add authentication** using Supabase Auth if needed

## Testing

The current implementation includes simulated network delays and error handling, so you can test the UI flow before connecting to the real database.

## Error Handling

The app now includes proper error handling and loading states. Users will see:
- Loading indicators while data is being fetched
- Error messages if something goes wrong
- Proper fallbacks for empty states

## Real-time Features

Once fully integrated, you can enable real-time features like:
- Live point balance updates
- Real-time crowdedness updates for coffee shops
- Instant friend request notifications

See the `subscribeToPointUpdates` method in `SupabaseService.swift` for examples.