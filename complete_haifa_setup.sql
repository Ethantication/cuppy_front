-- Complete Haifa Coffee Community Database Setup
-- Run this entire script in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- SCHEMA SETUP - TABLES AND TYPES
-- =====================================================

-- Drop existing tables if they exist (in correct order to handle dependencies)
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS friend_requests CASCADE;
DROP TABLE IF EXISTS friendships CASCADE;
DROP TABLE IF EXISTS beverages CASCADE;
DROP TABLE IF EXISTS coffee_shops CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS communities CASCADE;

-- Drop types if they exist
DROP TYPE IF EXISTS beverage_category CASCADE;
DROP TYPE IF EXISTS transaction_type CASCADE;
DROP TYPE IF EXISTS friend_request_status CASCADE;

-- Create types
CREATE TYPE beverage_category AS ENUM ('coffee', 'tea', 'cold_drinks', 'food');
CREATE TYPE transaction_type AS ENUM ('earned', 'redeemed', 'sent', 'received');
CREATE TYPE friend_request_status AS ENUM ('pending', 'accepted', 'declined');

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
    auth_user_id UUID UNIQUE
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
-- TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coffee_shop_id UUID REFERENCES coffee_shops(id) ON DELETE SET NULL,
    related_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    transaction_type transaction_type NOT NULL,
    amount INTEGER NOT NULL CHECK (amount > 0),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
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
-- FRIEND REQUESTS TABLE
-- =====================================================
CREATE TABLE friend_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status friend_request_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(from_user_id, to_user_id),
    CONSTRAINT check_no_self_request CHECK (from_user_id != to_user_id)
);

-- =====================================================
-- FRIENDSHIPS TABLE
-- =====================================================
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user1_id, user2_id),
    CONSTRAINT check_no_self_friendship CHECK (user1_id != user2_id),
    CONSTRAINT check_ordered_friendship CHECK (user1_id < user2_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_users_community_id ON users(community_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_auth_user_id ON users(auth_user_id);
CREATE INDEX idx_users_points ON users(points DESC);
CREATE INDEX idx_coffee_shops_community_id ON coffee_shops(community_id);
CREATE INDEX idx_coffee_shops_name ON coffee_shops(name);
CREATE INDEX idx_beverages_coffee_shop_id ON beverages(coffee_shop_id);
CREATE INDEX idx_beverages_category ON beverages(category);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_coffee_shop_id ON transactions(coffee_shop_id);
CREATE INDEX idx_transactions_related_user_id ON transactions(related_user_id);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX idx_friend_requests_from_user_id ON friend_requests(from_user_id);
CREATE INDEX idx_friend_requests_to_user_id ON friend_requests(to_user_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);
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

-- Function to handle point transfers
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
    SELECT points INTO sender_points FROM users WHERE id = sender_id;
    
    IF sender_points < amount THEN
        RAISE EXCEPTION 'Insufficient points for transfer';
    END IF;
    
    BEGIN
        UPDATE users SET points = points - amount WHERE id = sender_id;
        UPDATE users SET points = points + amount WHERE id = receiver_id;
        
        INSERT INTO transactions (user_id, related_user_id, transaction_type, amount, description)
        VALUES (sender_id, receiver_id, 'sent', amount, description);
        
        INSERT INTO transactions (user_id, related_user_id, transaction_type, amount, description)
        VALUES (receiver_id, sender_id, 'received', amount, description);
        
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
END;
$$ language 'plpgsql';

-- Function to earn points
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
    SELECT points_back_percentage INTO points_back_pct 
    FROM coffee_shops WHERE id = coffee_shop_id;
    
    points_earned := CEIL(purchase_amount * points_back_pct / 100.0);
    
    UPDATE users SET points = points + points_earned WHERE id = user_id;
    
    INSERT INTO transactions (user_id, coffee_shop_id, transaction_type, amount, description)
    VALUES (user_id, coffee_shop_id, 'earned', points_earned, 
            COALESCE(description, 'Purchase at ' || (SELECT name FROM coffee_shops WHERE id = coffee_shop_id)));
    
    RETURN points_earned;
END;
$$ language 'plpgsql';

-- Function to redeem points
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
    SELECT points INTO user_points FROM users WHERE id = user_id;
    
    IF user_points < amount THEN
        RAISE EXCEPTION 'Insufficient points for redemption';
    END IF;
    
    UPDATE users SET points = points - amount WHERE id = user_id;
    
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

-- =====================================================
-- HAIFA DATA INSERTION
-- =====================================================

-- Insert Haifa Community
INSERT INTO communities (id, name, city, country) VALUES
    ('haifa-001', 'Haifa Coffee Community', 'Haifa', 'Israel');

-- Insert Haifa Coffee Shops
INSERT INTO coffee_shops (id, name, address, image_url, points_back_percentage, current_crowdedness, is_quiet_friendly, opening_hours, community_id) VALUES
    ('haifa-nuna-001', 'Nuna', 'Masada St, Haifa', null, 15, 65, true, '7:00 AM - 7:00 PM', 'haifa-001'),
    ('haifa-nuna-002', 'Nuna Technion Physics', 'Technion Physics Building, Haifa', null, 12, 45, true, '8:00 AM - 6:00 PM', 'haifa-001'),
    ('haifa-nuna-003', 'Nuna Technion Mech. Eng.', 'Technion Mechanical Engineering Building, Haifa', null, 12, 55, true, '8:00 AM - 6:00 PM', 'haifa-001'),
    ('haifa-tsafon-001', 'Tsafon Roasters', 'German Colony, Haifa', null, 18, 70, false, '7:30 AM - 8:00 PM', 'haifa-001'),
    ('haifa-naima-001', 'Naima', 'Wadi Nisnas, Haifa', null, 14, 40, true, '8:00 AM - 6:30 PM', 'haifa-001');

-- Insert Beverages for all coffee shops
-- Nuna (Main)
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('nuna-001-bev-001', 'Espresso', 12.00, 'Rich Italian espresso', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-002', 'Americano', 14.00, 'Smooth black coffee', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-003', 'Cappuccino', 16.00, 'Perfect foam art', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-004', 'Latte', 18.00, 'Creamy steamed milk', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-005', 'Cold Brew', 16.00, 'Refreshing cold coffee', 'cold_drinks', 'haifa-nuna-001'),
    ('nuna-001-bev-006', 'Croissant', 15.00, 'Fresh buttery pastry', 'food', 'haifa-nuna-001'),
    ('nuna-001-bev-007', 'Shakshuka Sandwich', 28.00, 'Israeli breakfast sandwich', 'food', 'haifa-nuna-001');

-- Nuna Technion Physics
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('nuna-002-bev-001', 'Student Espresso', 8.00, 'Budget-friendly espresso', 'coffee', 'haifa-nuna-002'),
    ('nuna-002-bev-002', 'Study Latte', 12.00, 'Perfect for long study sessions', 'coffee', 'haifa-nuna-002'),
    ('nuna-002-bev-003', 'Energy Americano', 10.00, 'Strong coffee for exams', 'coffee', 'haifa-nuna-002'),
    ('nuna-002-bev-004', 'Iced Coffee', 12.00, 'Cool refreshment', 'cold_drinks', 'haifa-nuna-002'),
    ('nuna-002-bev-005', 'Bagel with Cream Cheese', 18.00, 'Quick student meal', 'food', 'haifa-nuna-002'),
    ('nuna-002-bev-006', 'Green Tea', 8.00, 'Healthy alternative', 'tea', 'haifa-nuna-002');

-- Nuna Technion Mechanical Engineering
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('nuna-003-bev-001', 'Engineer Espresso', 8.00, 'Fuel for innovation', 'coffee', 'haifa-nuna-003'),
    ('nuna-003-bev-002', 'CAD Cappuccino', 14.00, 'Perfect for design work', 'coffee', 'haifa-nuna-003'),
    ('nuna-003-bev-003', 'Prototype Latte', 12.00, 'Smooth as your designs', 'coffee', 'haifa-nuna-003'),
    ('nuna-003-bev-004', 'Cold Brew', 12.00, 'Cool down after lab work', 'cold_drinks', 'haifa-nuna-003'),
    ('nuna-003-bev-005', 'Energy Bar', 12.00, 'Quick energy boost', 'food', 'haifa-nuna-003'),
    ('nuna-003-bev-006', 'Mint Tea', 8.00, 'Refreshing break', 'tea', 'haifa-nuna-003');

-- Tsafon Roasters
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('tsafon-001-bev-001', 'Single Origin Ethiopia', 24.00, 'Floral and bright notes', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-002', 'House Blend Espresso', 18.00, 'Signature roast', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-003', 'V60 Pour Over', 28.00, 'Artisan brewing method', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-004', 'Flat White', 20.00, 'Velvety microfoam', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-005', 'Nitro Cold Brew', 22.00, 'Smooth nitrogen infusion', 'cold_drinks', 'haifa-tsafon-001'),
    ('tsafon-001-bev-006', 'Artisan Pastry', 18.00, 'Local bakery selection', 'food', 'haifa-tsafon-001'),
    ('tsafon-001-bev-007', 'Avocado Toast', 32.00, 'Fresh sourdough base', 'food', 'haifa-tsafon-001');

-- Naima
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('naima-001-bev-001', 'Turkish Coffee', 16.00, 'Traditional preparation', 'coffee', 'haifa-naima-001'),
    ('naima-001-bev-002', 'Cardamom Latte', 20.00, 'Spiced Middle Eastern twist', 'coffee', 'haifa-naima-001'),
    ('naima-001-bev-003', 'Arabic Coffee', 14.00, 'Light roast with spices', 'coffee', 'haifa-naima-001'),
    ('naima-001-bev-004', 'Sage Tea', 12.00, 'Traditional herb tea', 'tea', 'haifa-naima-001'),
    ('naima-001-bev-005', 'Mint Lemonade', 16.00, 'Fresh and cooling', 'cold_drinks', 'haifa-naima-001'),
    ('naima-001-bev-006', 'Baklava', 18.00, 'Sweet honey pastry', 'food', 'haifa-naima-001'),
    ('naima-001-bev-007', 'Hummus Plate', 26.00, 'Local specialty with bread', 'food', 'haifa-naima-001'),
    ('naima-001-bev-008', 'Date Ma''amoul', 14.00, 'Traditional filled cookies', 'food', 'haifa-naima-001');

-- Insert Sample Users
INSERT INTO users (id, name, email, profile_image_url, community_id, points, auth_user_id) VALUES
    ('haifa-user-001', 'Amit Cohen', 'amit@example.com', null, 'haifa-001', 850, null),
    ('haifa-user-002', 'Maya Levi', 'maya@example.com', null, 'haifa-001', 1200, null),
    ('haifa-user-003', 'David Mizrahi', 'david@example.com', null, 'haifa-001', 650, null),
    ('haifa-user-004', 'Sarah Katz', 'sarah@example.com', null, 'haifa-001', 1450, null),
    ('haifa-user-005', 'Yoni Goldberg', 'yoni@example.com', null, 'haifa-001', 920, null);

-- Insert Sample Friendships
INSERT INTO friendships (user1_id, user2_id) VALUES
    ('haifa-user-001', 'haifa-user-002'),
    ('haifa-user-001', 'haifa-user-003'),
    ('haifa-user-002', 'haifa-user-004'),
    ('haifa-user-003', 'haifa-user-005'),
    ('haifa-user-004', 'haifa-user-005');

-- Insert Sample Transactions
INSERT INTO transactions (id, user_id, coffee_shop_id, transaction_type, amount, description) VALUES
    ('haifa-trans-001', 'haifa-user-001', 'haifa-nuna-001', 'earned', 24, 'Cappuccino and croissant'),
    ('haifa-trans-002', 'haifa-user-001', 'haifa-tsafon-001', 'earned', 45, 'V60 pour over'),
    ('haifa-trans-003', 'haifa-user-001', 'haifa-nuna-001', 'redeemed', 100, 'Free latte'),
    ('haifa-trans-004', 'haifa-user-002', 'haifa-naima-001', 'earned', 32, 'Turkish coffee and baklava'),
    ('haifa-trans-005', 'haifa-user-002', 'haifa-nuna-002', 'earned', 20, 'Study latte'),
    ('haifa-trans-006', 'haifa-user-002', 'haifa-tsafon-001', 'earned', 36, 'Flat white and pastry'),
    ('haifa-trans-007', 'haifa-user-003', 'haifa-nuna-003', 'earned', 24, 'Engineer espresso and energy bar'),
    ('haifa-trans-008', 'haifa-user-003', 'haifa-naima-001', 'earned', 28, 'Arabic coffee and hummus'),
    ('haifa-trans-009', 'haifa-user-004', 'haifa-tsafon-001', 'earned', 42, 'Single origin and avocado toast'),
    ('haifa-trans-010', 'haifa-user-004', 'haifa-nuna-001', 'earned', 30, 'Latte and shakshuka sandwich'),
    ('haifa-trans-011', 'haifa-user-004', 'haifa-naima-001', 'redeemed', 150, 'Free meal'),
    ('haifa-trans-012', 'haifa-user-005', 'haifa-nuna-002', 'earned', 16, 'Student espresso and bagel'),
    ('haifa-trans-013', 'haifa-user-005', 'haifa-tsafon-001', 'earned', 40, 'Nitro cold brew and pastry');

-- Insert Sample Point Transfers
INSERT INTO transactions (id, user_id, related_user_id, transaction_type, amount, description) VALUES
    ('haifa-trans-014', 'haifa-user-001', 'haifa-user-002', 'sent', 50, 'Birthday gift'),
    ('haifa-trans-015', 'haifa-user-002', 'haifa-user-001', 'received', 50, 'Birthday gift from Amit'),
    ('haifa-trans-016', 'haifa-user-004', 'haifa-user-005', 'sent', 75, 'Help with coffee'),
    ('haifa-trans-017', 'haifa-user-005', 'haifa-user-004', 'received', 75, 'Coffee help from Sarah'),
    ('haifa-trans-018', 'haifa-user-003', 'haifa-user-001', 'sent', 30, 'Thanks for help'),
    ('haifa-trans-019', 'haifa-user-001', 'haifa-user-003', 'received', 30, 'Thanks from David');

-- Insert Sample Friend Requests
INSERT INTO friend_requests (id, from_user_id, to_user_id, status) VALUES
    ('haifa-freq-001', 'haifa-user-001', 'haifa-user-004', 'pending'),
    ('haifa-freq-002', 'haifa-user-003', 'haifa-user-002', 'pending'),
    ('haifa-freq-003', 'haifa-user-001', 'haifa-user-002', 'accepted'),
    ('haifa-freq-004', 'haifa-user-004', 'haifa-user-005', 'accepted');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Verify the setup
SELECT 'Communities' as table_name, count(*) as count FROM communities
UNION ALL
SELECT 'Coffee Shops', count(*) FROM coffee_shops
UNION ALL
SELECT 'Beverages', count(*) FROM beverages
UNION ALL
SELECT 'Users', count(*) FROM users
UNION ALL
SELECT 'Transactions', count(*) FROM transactions
UNION ALL
SELECT 'Friendships', count(*) FROM friendships
UNION ALL
SELECT 'Friend Requests', count(*) FROM friend_requests;