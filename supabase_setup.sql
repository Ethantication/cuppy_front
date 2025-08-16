-- Supabase Database Setup for Cuppy_backend App
-- This script creates all tables, relationships, indexes, and RLS policies

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- COMMUNITIES TABLE
-- =====================================================
CREATE TABLE communities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, city, country)
);

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    profile_image_url TEXT,
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    points INTEGER NOT NULL DEFAULT 0 CHECK (points >= 0),
    join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- User authentication fields for Supabase Auth
    auth_user_id UUID UNIQUE -- Links to auth.users table
);

-- =====================================================
-- COFFEE SHOPS TABLE
-- =====================================================
CREATE TABLE coffee_shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    image_url TEXT,
    points_back_percentage INTEGER NOT NULL DEFAULT 0 CHECK (points_back_percentage >= 0 AND points_back_percentage <= 100),
    current_crowdedness INTEGER NOT NULL DEFAULT 0 CHECK (current_crowdedness >= 0 AND current_crowdedness <= 100),
    is_quiet_friendly BOOLEAN NOT NULL DEFAULT false,
    opening_hours VARCHAR(255),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- BEVERAGE CATEGORIES ENUM
-- =====================================================
CREATE TYPE beverage_category AS ENUM ('coffee', 'tea', 'cold_drinks', 'food');

-- =====================================================
-- BEVERAGES TABLE
-- =====================================================
CREATE TABLE beverages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    category beverage_category NOT NULL,
    coffee_shop_id UUID NOT NULL REFERENCES coffee_shops(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TRANSACTION TYPES ENUM
-- =====================================================
CREATE TYPE transaction_type AS ENUM ('earned', 'redeemed', 'sent', 'received');

-- =====================================================
-- TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coffee_shop_id UUID REFERENCES coffee_shops(id) ON DELETE SET NULL,
    related_user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- For sent/received transactions
    transaction_type transaction_type NOT NULL,
    amount INTEGER NOT NULL CHECK (amount > 0),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints to ensure data integrity
    CONSTRAINT check_coffee_shop_required CHECK (
        (transaction_type IN ('earned', 'redeemed') AND coffee_shop_id IS NOT NULL) OR
        (transaction_type IN ('sent', 'received'))
    ),
    CONSTRAINT check_related_user_required CHECK (
        (transaction_type IN ('sent', 'received') AND related_user_id IS NOT NULL) OR
        (transaction_type IN ('earned', 'redeemed'))
    ),
    CONSTRAINT check_no_self_transfer CHECK (user_id != related_user_id)
);

-- =====================================================
-- FRIEND REQUEST STATUS ENUM
-- =====================================================
CREATE TYPE friend_request_status AS ENUM ('pending', 'accepted', 'declined');

-- =====================================================
-- FRIEND REQUESTS TABLE
-- =====================================================
CREATE TABLE friend_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status friend_request_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate requests and self-requests
    UNIQUE(from_user_id, to_user_id),
    CONSTRAINT check_no_self_request CHECK (from_user_id != to_user_id)
);

-- =====================================================
-- FRIENDSHIPS TABLE (for accepted friend relationships)
-- =====================================================
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure friendships are bidirectional and unique
    UNIQUE(user1_id, user2_id),
    CONSTRAINT check_no_self_friendship CHECK (user1_id != user2_id),
    CONSTRAINT check_ordered_friendship CHECK (user1_id < user2_id) -- Ensure consistent ordering
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_community_id ON users(community_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_auth_user_id ON users(auth_user_id);
CREATE INDEX idx_users_points ON users(points DESC);

-- Coffee shops indexes
CREATE INDEX idx_coffee_shops_community_id ON coffee_shops(community_id);
CREATE INDEX idx_coffee_shops_name ON coffee_shops(name);

-- Beverages indexes
CREATE INDEX idx_beverages_coffee_shop_id ON beverages(coffee_shop_id);
CREATE INDEX idx_beverages_category ON beverages(category);

-- Transactions indexes
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_coffee_shop_id ON transactions(coffee_shop_id);
CREATE INDEX idx_transactions_related_user_id ON transactions(related_user_id);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);

-- Friend requests indexes
CREATE INDEX idx_friend_requests_from_user_id ON friend_requests(from_user_id);
CREATE INDEX idx_friend_requests_to_user_id ON friend_requests(to_user_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);

-- Friendships indexes
CREATE INDEX idx_friendships_user1_id ON friendships(user1_id);
CREATE INDEX idx_friendships_user2_id ON friendships(user2_id);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to relevant tables
CREATE TRIGGER update_communities_updated_at BEFORE UPDATE ON communities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_coffee_shops_updated_at BEFORE UPDATE ON coffee_shops FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_beverages_updated_at BEFORE UPDATE ON beverages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_friend_requests_updated_at BEFORE UPDATE ON friend_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically create friendship when friend request is accepted
CREATE OR REPLACE FUNCTION handle_friend_request_acceptance()
RETURNS TRIGGER AS $$
BEGIN
    -- If status changed to accepted, create friendship
    IF NEW.status = 'accepted' AND OLD.status = 'pending' THEN
        INSERT INTO friendships (user1_id, user2_id)
        VALUES (
            LEAST(NEW.from_user_id, NEW.to_user_id),
            GREATEST(NEW.from_user_id, NEW.to_user_id)
        )
        ON CONFLICT (user1_id, user2_id) DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER friend_request_acceptance_trigger 
    AFTER UPDATE ON friend_requests 
    FOR EACH ROW 
    EXECUTE FUNCTION handle_friend_request_acceptance();

-- Function to handle point transfers (creates both sent and received transactions)
CREATE OR REPLACE FUNCTION transfer_points(
    sender_id UUID,
    receiver_id UUID,
    amount INTEGER,
    description TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    sender_points INTEGER;
BEGIN
    -- Check if sender has enough points
    SELECT points INTO sender_points FROM users WHERE id = sender_id;
    
    IF sender_points < amount THEN
        RAISE EXCEPTION 'Insufficient points for transfer';
    END IF;
    
    -- Start transaction
    BEGIN
        -- Deduct points from sender
        UPDATE users SET points = points - amount WHERE id = sender_id;
        
        -- Add points to receiver
        UPDATE users SET points = points + amount WHERE id = receiver_id;
        
        -- Create sent transaction
        INSERT INTO transactions (user_id, related_user_id, transaction_type, amount, description)
        VALUES (sender_id, receiver_id, 'sent', amount, description);
        
        -- Create received transaction
        INSERT INTO transactions (user_id, related_user_id, transaction_type, amount, description)
        VALUES (receiver_id, sender_id, 'received', amount, description);
        
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback is automatic in function context
            RAISE;
    END;
END;
$$ language 'plpgsql';

-- Function to earn points from coffee shop purchase
CREATE OR REPLACE FUNCTION earn_points(
    user_id UUID,
    coffee_shop_id UUID,
    purchase_amount DECIMAL,
    description TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    points_back_pct INTEGER;
    points_earned INTEGER;
BEGIN
    -- Get coffee shop points back percentage
    SELECT points_back_percentage INTO points_back_pct 
    FROM coffee_shops WHERE id = coffee_shop_id;
    
    -- Calculate points earned (assuming 1 point per dollar * percentage)
    points_earned := CEIL(purchase_amount * points_back_pct / 100.0);
    
    -- Add points to user
    UPDATE users SET points = points + points_earned WHERE id = user_id;
    
    -- Create earned transaction
    INSERT INTO transactions (user_id, coffee_shop_id, transaction_type, amount, description)
    VALUES (user_id, coffee_shop_id, 'earned', points_earned, 
            COALESCE(description, 'Purchase at ' || (SELECT name FROM coffee_shops WHERE id = coffee_shop_id)));
    
    RETURN points_earned;
END;
$$ language 'plpgsql';

-- Function to redeem points at coffee shop
CREATE OR REPLACE FUNCTION redeem_points(
    user_id UUID,
    coffee_shop_id UUID,
    amount INTEGER,
    description TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    user_points INTEGER;
BEGIN
    -- Check if user has enough points
    SELECT points INTO user_points FROM users WHERE id = user_id;
    
    IF user_points < amount THEN
        RAISE EXCEPTION 'Insufficient points for redemption';
    END IF;
    
    -- Deduct points from user
    UPDATE users SET points = points - amount WHERE id = user_id;
    
    -- Create redeemed transaction
    INSERT INTO transactions (user_id, coffee_shop_id, transaction_type, amount, description)
    VALUES (user_id, coffee_shop_id, 'redeemed', amount, 
            COALESCE(description, 'Redeemed at ' || (SELECT name FROM coffee_shops WHERE id = coffee_shop_id)));
    
    RETURN TRUE;
END;
$$ language 'plpgsql';

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE coffee_shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE beverages ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

-- Communities: Read-only for authenticated users
CREATE POLICY "Communities are viewable by authenticated users" ON communities
    FOR SELECT USING (auth.role() = 'authenticated');

-- Users: Users can view users in their community, update their own profile
CREATE POLICY "Users can view users in their community" ON users
    FOR SELECT USING (
        auth.role() = 'authenticated' AND 
        community_id = (SELECT community_id FROM users WHERE auth_user_id = auth.uid())
    );

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth_user_id = auth.uid());

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth_user_id = auth.uid());

-- Coffee shops: Viewable by users in the same community
CREATE POLICY "Coffee shops are viewable by community members" ON coffee_shops
    FOR SELECT USING (
        auth.role() = 'authenticated' AND
        community_id = (SELECT community_id FROM users WHERE auth_user_id = auth.uid())
    );

-- Beverages: Viewable by community members
CREATE POLICY "Beverages are viewable by community members" ON beverages
    FOR SELECT USING (
        auth.role() = 'authenticated' AND
        coffee_shop_id IN (
            SELECT cs.id FROM coffee_shops cs
            JOIN users u ON cs.community_id = u.community_id
            WHERE u.auth_user_id = auth.uid()
        )
    );

-- Transactions: Users can only see their own transactions
CREATE POLICY "Users can view their own transactions" ON transactions
    FOR SELECT USING (
        auth.role() = 'authenticated' AND
        user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
    );

CREATE POLICY "Users can create their own transactions" ON transactions
    FOR INSERT WITH CHECK (
        auth.role() = 'authenticated' AND
        user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
    );

-- Friend requests: Users can see requests involving them
CREATE POLICY "Users can view friend requests involving them" ON friend_requests
    FOR SELECT USING (
        auth.role() = 'authenticated' AND
        (from_user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid()) OR
         to_user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid()))
    );

CREATE POLICY "Users can create friend requests" ON friend_requests
    FOR INSERT WITH CHECK (
        auth.role() = 'authenticated' AND
        from_user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
    );

CREATE POLICY "Users can update friend requests sent to them" ON friend_requests
    FOR UPDATE USING (
        auth.role() = 'authenticated' AND
        to_user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
    );

-- Friendships: Users can see their own friendships
CREATE POLICY "Users can view their own friendships" ON friendships
    FOR SELECT USING (
        auth.role() = 'authenticated' AND
        (user1_id = (SELECT id FROM users WHERE auth_user_id = auth.uid()) OR
         user2_id = (SELECT id FROM users WHERE auth_user_id = auth.uid()))
    );

-- =====================================================
-- HELPER VIEWS
-- =====================================================

-- View to get user's friends list
CREATE VIEW user_friends AS
SELECT 
    f.user1_id as user_id,
    f.user2_id as friend_id,
    u.name as friend_name,
    u.email as friend_email,
    u.profile_image_url as friend_profile_image,
    u.points as friend_points,
    f.created_at as friendship_date
FROM friendships f
JOIN users u ON f.user2_id = u.id

UNION ALL

SELECT 
    f.user2_id as user_id,
    f.user1_id as friend_id,
    u.name as friend_name,
    u.email as friend_email,
    u.profile_image_url as friend_profile_image,
    u.points as friend_points,
    f.created_at as friendship_date
FROM friendships f
JOIN users u ON f.user1_id = u.id;

-- View to get user transaction history with details
CREATE VIEW user_transaction_history AS
SELECT 
    t.id,
    t.user_id,
    t.transaction_type,
    t.amount,
    t.description,
    t.created_at,
    cs.name as coffee_shop_name,
    cs.address as coffee_shop_address,
    ru.name as related_user_name,
    ru.email as related_user_email
FROM transactions t
LEFT JOIN coffee_shops cs ON t.coffee_shop_id = cs.id
LEFT JOIN users ru ON t.related_user_id = ru.id;

-- View to get coffee shop stats
CREATE VIEW coffee_shop_stats AS
SELECT 
    cs.id,
    cs.name,
    cs.community_id,
    COUNT(DISTINCT b.id) as total_beverages,
    COUNT(DISTINCT t.id) as total_transactions,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'earned' THEN t.amount END), 0) as total_points_given,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'redeemed' THEN t.amount END), 0) as total_points_redeemed
FROM coffee_shops cs
LEFT JOIN beverages b ON cs.id = b.coffee_shop_id
LEFT JOIN transactions t ON cs.id = t.coffee_shop_id
GROUP BY cs.id, cs.name, cs.community_id;