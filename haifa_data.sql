-- Real Data for Cuppy_backend App - Haifa
-- This script inserts the actual data for Haifa community and coffee shops

-- Clear existing data first (optional)
-- DELETE FROM transactions;
-- DELETE FROM friend_requests;
-- DELETE FROM friendships;
-- DELETE FROM beverages;
-- DELETE FROM coffee_shops;
-- DELETE FROM users;
-- DELETE FROM communities;

-- =====================================================
-- INSERT HAIFA COMMUNITY
-- =====================================================
INSERT INTO communities (id, name, city, country) VALUES
    ('haifa-001', 'Haifa Coffee Community', 'Haifa', 'Israel');

-- =====================================================
-- INSERT HAIFA COFFEE SHOPS
-- =====================================================
INSERT INTO coffee_shops (id, name, address, image_url, points_back_percentage, current_crowdedness, is_quiet_friendly, opening_hours, community_id) VALUES
    -- Nuna (Main branch)
    ('haifa-nuna-001', 'Nuna', 'Masada St, Haifa', null, 15, 65, true, '7:00 AM - 7:00 PM', 'haifa-001'),
    
    -- Nuna Technion Physics
    ('haifa-nuna-002', 'Nuna Technion Physics', 'Technion Physics Building, Haifa', null, 12, 45, true, '8:00 AM - 6:00 PM', 'haifa-001'),
    
    -- Nuna Technion Mechanical Engineering
    ('haifa-nuna-003', 'Nuna Technion Mech. Eng.', 'Technion Mechanical Engineering Building, Haifa', null, 12, 55, true, '8:00 AM - 6:00 PM', 'haifa-001'),
    
    -- Tsafon Roasters
    ('haifa-tsafon-001', 'Tsafon Roasters', 'German Colony, Haifa', null, 18, 70, false, '7:30 AM - 8:00 PM', 'haifa-001'),
    
    -- Naima
    ('haifa-naima-001', 'Naima', 'Wadi Nisnas, Haifa', null, 14, 40, true, '8:00 AM - 6:30 PM', 'haifa-001');

-- =====================================================
-- INSERT BEVERAGES FOR EACH COFFEE SHOP
-- =====================================================

-- Nuna (Main) - Classic coffee shop menu
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('nuna-001-bev-001', 'Espresso', 12.00, 'Rich Italian espresso', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-002', 'Americano', 14.00, 'Smooth black coffee', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-003', 'Cappuccino', 16.00, 'Perfect foam art', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-004', 'Latte', 18.00, 'Creamy steamed milk', 'coffee', 'haifa-nuna-001'),
    ('nuna-001-bev-005', 'Cold Brew', 16.00, 'Refreshing cold coffee', 'cold_drinks', 'haifa-nuna-001'),
    ('nuna-001-bev-006', 'Croissant', 15.00, 'Fresh buttery pastry', 'food', 'haifa-nuna-001'),
    ('nuna-001-bev-007', 'Shakshuka Sandwich', 28.00, 'Israeli breakfast sandwich', 'food', 'haifa-nuna-001');

-- Nuna Technion Physics - Student-friendly prices
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('nuna-002-bev-001', 'Student Espresso', 8.00, 'Budget-friendly espresso', 'coffee', 'haifa-nuna-002'),
    ('nuna-002-bev-002', 'Study Latte', 12.00, 'Perfect for long study sessions', 'coffee', 'haifa-nuna-002'),
    ('nuna-002-bev-003', 'Energy Americano', 10.00, 'Strong coffee for exams', 'coffee', 'haifa-nuna-002'),
    ('nuna-002-bev-004', 'Iced Coffee', 12.00, 'Cool refreshment', 'cold_drinks', 'haifa-nuna-002'),
    ('nuna-002-bev-005', 'Bagel with Cream Cheese', 18.00, 'Quick student meal', 'food', 'haifa-nuna-002'),
    ('nuna-002-bev-006', 'Green Tea', 8.00, 'Healthy alternative', 'tea', 'haifa-nuna-002');

-- Nuna Technion Mechanical Engineering - Similar student menu
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('nuna-003-bev-001', 'Engineer Espresso', 8.00, 'Fuel for innovation', 'coffee', 'haifa-nuna-003'),
    ('nuna-003-bev-002', 'CAD Cappuccino', 14.00, 'Perfect for design work', 'coffee', 'haifa-nuna-003'),
    ('nuna-003-bev-003', 'Prototype Latte', 12.00, 'Smooth as your designs', 'coffee', 'haifa-nuna-003'),
    ('nuna-003-bev-004', 'Cold Brew', 12.00, 'Cool down after lab work', 'cold_drinks', 'haifa-nuna-003'),
    ('nuna-003-bev-005', 'Energy Bar', 12.00, 'Quick energy boost', 'food', 'haifa-nuna-003'),
    ('nuna-003-bev-006', 'Mint Tea', 8.00, 'Refreshing break', 'tea', 'haifa-nuna-003');

-- Tsafon Roasters - Premium specialty coffee
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('tsafon-001-bev-001', 'Single Origin Ethiopia', 24.00, 'Floral and bright notes', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-002', 'House Blend Espresso', 18.00, 'Signature roast', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-003', 'V60 Pour Over', 28.00, 'Artisan brewing method', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-004', 'Flat White', 20.00, 'Velvety microfoam', 'coffee', 'haifa-tsafon-001'),
    ('tsafon-001-bev-005', 'Nitro Cold Brew', 22.00, 'Smooth nitrogen infusion', 'cold_drinks', 'haifa-tsafon-001'),
    ('tsafon-001-bev-006', 'Artisan Pastry', 18.00, 'Local bakery selection', 'food', 'haifa-tsafon-001'),
    ('tsafon-001-bev-007', 'Avocado Toast', 32.00, 'Fresh sourdough base', 'food', 'haifa-tsafon-001');

-- Naima - Middle Eastern influenced menu
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('naima-001-bev-001', 'Turkish Coffee', 16.00, 'Traditional preparation', 'coffee', 'haifa-naima-001'),
    ('naima-001-bev-002', 'Cardamom Latte', 20.00, 'Spiced Middle Eastern twist', 'coffee', 'haifa-naima-001'),
    ('naima-001-bev-003', 'Arabic Coffee', 14.00, 'Light roast with spices', 'coffee', 'haifa-naima-001'),
    ('naima-001-bev-004', 'Sage Tea', 12.00, 'Traditional herb tea', 'tea', 'haifa-naima-001'),
    ('naima-001-bev-005', 'Mint Lemonade', 16.00, 'Fresh and cooling', 'cold_drinks', 'haifa-naima-001'),
    ('naima-001-bev-006', 'Baklava', 18.00, 'Sweet honey pastry', 'food', 'haifa-naima-001'),
    ('naima-001-bev-007', 'Hummus Plate', 26.00, 'Local specialty with bread', 'food', 'haifa-naima-001'),
    ('naima-001-bev-008', 'Date Ma\'amoul', 14.00, 'Traditional filled cookies', 'food', 'haifa-naima-001');

-- =====================================================
-- SAMPLE USERS FOR HAIFA COMMUNITY
-- =====================================================
INSERT INTO users (id, name, email, profile_image_url, community_id, points, auth_user_id) VALUES
    ('haifa-user-001', 'Amit Cohen', 'amit@example.com', null, 'haifa-001', 850, null),
    ('haifa-user-002', 'Maya Levi', 'maya@example.com', null, 'haifa-001', 1200, null),
    ('haifa-user-003', 'David Mizrahi', 'david@example.com', null, 'haifa-001', 650, null),
    ('haifa-user-004', 'Sarah Katz', 'sarah@example.com', null, 'haifa-001', 1450, null),
    ('haifa-user-005', 'Yoni Goldberg', 'yoni@example.com', null, 'haifa-001', 920, null);

-- =====================================================
-- SAMPLE FRIENDSHIPS
-- =====================================================
INSERT INTO friendships (user1_id, user2_id) VALUES
    ('haifa-user-001', 'haifa-user-002'), -- Amit & Maya
    ('haifa-user-001', 'haifa-user-003'), -- Amit & David
    ('haifa-user-002', 'haifa-user-004'), -- Maya & Sarah
    ('haifa-user-003', 'haifa-user-005'), -- David & Yoni
    ('haifa-user-004', 'haifa-user-005'); -- Sarah & Yoni

-- =====================================================
-- SAMPLE TRANSACTIONS
-- =====================================================
INSERT INTO transactions (id, user_id, coffee_shop_id, transaction_type, amount, description) VALUES
    -- Amit's transactions
    ('haifa-trans-001', 'haifa-user-001', 'haifa-nuna-001', 'earned', 24, 'Cappuccino and croissant'),
    ('haifa-trans-002', 'haifa-user-001', 'haifa-tsafon-001', 'earned', 45, 'V60 pour over'),
    ('haifa-trans-003', 'haifa-user-001', 'haifa-nuna-001', 'redeemed', 100, 'Free latte'),
    
    -- Maya's transactions
    ('haifa-trans-004', 'haifa-user-002', 'haifa-naima-001', 'earned', 32, 'Turkish coffee and baklava'),
    ('haifa-trans-005', 'haifa-user-002', 'haifa-nuna-002', 'earned', 20, 'Study latte'),
    ('haifa-trans-006', 'haifa-user-002', 'haifa-tsafon-001', 'earned', 36, 'Flat white and pastry'),
    
    -- David's transactions
    ('haifa-trans-007', 'haifa-user-003', 'haifa-nuna-003', 'earned', 24, 'Engineer espresso and energy bar'),
    ('haifa-trans-008', 'haifa-user-003', 'haifa-naima-001', 'earned', 28, 'Arabic coffee and hummus'),
    
    -- Sarah's transactions
    ('haifa-trans-009', 'haifa-user-004', 'haifa-tsafon-001', 'earned', 42, 'Single origin and avocado toast'),
    ('haifa-trans-010', 'haifa-user-004', 'haifa-nuna-001', 'earned', 30, 'Latte and shakshuka sandwich'),
    ('haifa-trans-011', 'haifa-user-004', 'haifa-naima-001', 'redeemed', 150, 'Free meal'),
    
    -- Yoni's transactions
    ('haifa-trans-012', 'haifa-user-005', 'haifa-nuna-002', 'earned', 16, 'Student espresso and bagel'),
    ('haifa-trans-013', 'haifa-user-005', 'haifa-tsafon-001', 'earned', 40, 'Nitro cold brew and pastry');

-- =====================================================
-- SAMPLE POINT TRANSFERS
-- =====================================================
INSERT INTO transactions (id, user_id, related_user_id, transaction_type, amount, description) VALUES
    -- Amit sent points to Maya
    ('haifa-trans-014', 'haifa-user-001', 'haifa-user-002', 'sent', 50, 'Birthday gift'),
    ('haifa-trans-015', 'haifa-user-002', 'haifa-user-001', 'received', 50, 'Birthday gift from Amit'),
    
    -- Sarah sent points to Yoni
    ('haifa-trans-016', 'haifa-user-004', 'haifa-user-005', 'sent', 75, 'Help with coffee'),
    ('haifa-trans-017', 'haifa-user-005', 'haifa-user-004', 'received', 75, 'Coffee help from Sarah'),
    
    -- David sent points to Amit
    ('haifa-trans-018', 'haifa-user-003', 'haifa-user-001', 'sent', 30, 'Thanks for help'),
    ('haifa-trans-019', 'haifa-user-001', 'haifa-user-003', 'received', 30, 'Thanks from David');

-- =====================================================
-- SAMPLE FRIEND REQUESTS
-- =====================================================
INSERT INTO friend_requests (id, from_user_id, to_user_id, status) VALUES
    ('haifa-freq-001', 'haifa-user-001', 'haifa-user-004', 'pending'),
    ('haifa-freq-002', 'haifa-user-003', 'haifa-user-002', 'pending'),
    ('haifa-freq-003', 'haifa-user-001', 'haifa-user-002', 'accepted'),
    ('haifa-freq-004', 'haifa-user-004', 'haifa-user-005', 'accepted');