# Cuppy_backend - Database Setup Guide

## Overview

This document describes the data model and setup process for the Cuppy_backend app's Supabase database. The app is a location-based coffee shop loyalty platform that allows users to earn and redeem points, transfer points to friends, and discover coffee shops in their community.

## Data Model

### Core Entities

#### 1. Communities
Geographic groupings that contain coffee shops and users.
- **Purpose**: Organize users and coffee shops by location (NYC, LA, SF, London, Paris)
- **Key Fields**: `name`, `city`, `country`
- **Relationships**: One-to-many with Users and Coffee Shops

#### 2. Users
App users who can earn/spend points and connect with friends.
- **Purpose**: Store user profiles and point balances
- **Key Fields**: `name`, `email`, `points`, `community_id`, `auth_user_id`
- **Authentication**: Links to Supabase Auth via `auth_user_id`
- **Relationships**: 
  - Belongs to one Community
  - Many-to-many with other Users (friendships)
  - One-to-many with Transactions

#### 3. Coffee Shops
Physical locations where users can earn/redeem points.
- **Purpose**: Store coffee shop information and real-time data
- **Key Fields**: `name`, `address`, `points_back_percentage`, `current_crowdedness`, `is_quiet_friendly`
- **Real-time Features**: Crowdedness percentage, quiet-friendly indicator
- **Relationships**: 
  - Belongs to one Community
  - One-to-many with Beverages and Transactions

#### 4. Beverages
Menu items available at coffee shops.
- **Purpose**: Store coffee shop menus with pricing
- **Key Fields**: `name`, `price`, `description`, `category`
- **Categories**: Coffee, Tea, Cold Drinks, Food
- **Relationships**: Belongs to one Coffee Shop

#### 5. Transactions
Point movements (earned, redeemed, sent, received).
- **Purpose**: Track all point activities for auditing and history
- **Types**: 
  - `earned`: Points gained from purchases
  - `redeemed`: Points spent at coffee shops
  - `sent`: Points transferred to friends
  - `received`: Points received from friends
- **Key Fields**: `user_id`, `amount`, `transaction_type`, `coffee_shop_id`, `related_user_id`

#### 6. Friend Requests & Friendships
Social connection system between users.
- **Friend Requests**: Pending, accepted, or declined connection requests
- **Friendships**: Established bidirectional relationships between users
- **Purpose**: Enable social features like point transfers and friend discovery

## Database Schema

### Tables

```sql
-- Main entities
communities (id, name, city, country, created_at, updated_at)
users (id, name, email, profile_image_url, community_id, points, join_date, auth_user_id)
coffee_shops (id, name, address, image_url, points_back_percentage, current_crowdedness, is_quiet_friendly, opening_hours, community_id)
beverages (id, name, price, description, category, coffee_shop_id)
transactions (id, user_id, coffee_shop_id, related_user_id, transaction_type, amount, description, created_at)

-- Social features
friend_requests (id, from_user_id, to_user_id, status, created_at, updated_at)
friendships (id, user1_id, user2_id, created_at)
```

### Key Business Logic Functions

#### Point Transfer
```sql
SELECT transfer_points(sender_id, receiver_id, amount, description);
```
- Validates sender has sufficient points
- Creates atomic transaction (deducts from sender, adds to receiver)
- Creates both 'sent' and 'received' transaction records

#### Earn Points
```sql
SELECT earn_points(user_id, coffee_shop_id, purchase_amount, description);
```
- Calculates points based on coffee shop's points_back_percentage
- Updates user's point balance
- Creates 'earned' transaction record

#### Redeem Points
```sql
SELECT redeem_points(user_id, coffee_shop_id, amount, description);
```
- Validates user has sufficient points
- Deducts points from user balance
- Creates 'redeemed' transaction record

### Security Features

#### Row Level Security (RLS)
All tables have RLS enabled with policies that ensure:
- Users can only see data relevant to their community
- Users can only modify their own data
- Friend relationships are properly scoped
- Transactions are private to the involved users

#### Data Integrity
- Check constraints prevent negative point balances
- Unique constraints prevent duplicate friendships
- Foreign key constraints maintain referential integrity
- Triggers automatically manage friend relationships and timestamps

## Setup Instructions

### 1. Create Supabase Project
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Create a new project
3. Wait for project initialization

### 2. Run Database Setup
Execute the SQL scripts in order:

```bash
# 1. Create tables, functions, and policies
psql -h your-project.supabase.co -U postgres -d postgres -f supabase_setup.sql

# 2. Insert sample data (optional for testing)
psql -h your-project.supabase.co -U postgres -d postgres -f sample_data.sql
```

### 3. Configure Authentication
In your Supabase dashboard:
1. Go to Authentication → Settings
2. Configure your preferred auth providers (Email, Google, Apple)
3. Set up email templates if using email auth

### 4. Environment Variables
Add these to your app's environment:
```env
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## API Usage Examples

### Swift/iOS Integration

#### User Registration
```swift
// After Supabase Auth signup
let user = try await supabase.auth.user()
let newUser = User(
    authUserId: user.id,
    name: name,
    email: email,
    communityId: selectedCommunityId
)

try await supabase
    .from("users")
    .insert(newUser)
    .execute()
```

#### Get Coffee Shops in Community
```swift
let coffeeShops: [CoffeeShop] = try await supabase
    .from("coffee_shops")
    .select("*, beverages(*)")
    .eq("community_id", communityId)
    .execute()
    .value
```

#### Transfer Points
```swift
try await supabase.rpc(
    "transfer_points",
    parameters: [
        "sender_id": senderId,
        "receiver_id": receiverId,
        "amount": pointAmount,
        "description": description
    ]
).execute()
```

#### Get User's Transaction History
```swift
let transactions: [Transaction] = try await supabase
    .from("user_transaction_history")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", ascending: false)
    .execute()
    .value
```

## Real-time Features

### Supabase Realtime Subscriptions
The app can subscribe to real-time updates:

```swift
// Listen for point balance changes
supabase
    .from("users")
    .on(.update) { payload in
        // Update UI with new point balance
    }
    .subscribe()

// Listen for new friend requests
supabase
    .from("friend_requests")
    .on(.insert) { payload in
        // Show notification for new friend request
    }
    .subscribe()
```

## Performance Considerations

### Indexes
The setup script includes optimized indexes for:
- Community-based queries (users, coffee shops)
- Transaction history queries
- Friend relationship lookups
- Authentication queries

### Caching Strategy
Consider implementing:
- Coffee shop data caching (updates infrequently)
- User point balance caching with real-time sync
- Community data caching (rarely changes)

## Data Migration

### From Hardcoded Data
The current Swift app uses hardcoded data in `DataStore`. To migrate:

1. Export existing user data (if any) from local storage
2. Run the setup scripts to create the database
3. Update the Swift app to use Supabase instead of `DataStore`
4. Implement proper error handling and offline support

### Production Considerations
- Set up database backups
- Configure monitoring and alerting
- Implement rate limiting
- Set up staging environment for testing

## Troubleshooting

### Common Issues

#### RLS Policies Too Restrictive
If queries are returning empty results, check:
- User is properly authenticated
- `auth_user_id` is correctly set in users table
- User belongs to the correct community

#### Point Transfer Failures
Common causes:
- Insufficient point balance
- Invalid user IDs
- Users not in the same community (if restriction applies)

#### Performance Issues
- Check if indexes are being used (`EXPLAIN ANALYZE`)
- Consider pagination for large result sets
- Monitor connection pool usage

### Debugging Queries
Use Supabase Dashboard's SQL Editor to test queries:
```sql
-- Check user's point balance
SELECT name, points FROM users WHERE auth_user_id = 'your-auth-id';

-- Verify RLS policies
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Check transaction history
SELECT * FROM user_transaction_history WHERE user_id = 'user-id' LIMIT 10;
```

This database setup provides a robust foundation for the Cuppy_backend app with proper security, performance optimization, and scalability considerations.