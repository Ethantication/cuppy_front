-- Sample Data for Cuppy_backend App
-- This script inserts test data to populate the database

-- =====================================================
-- INSERT COMMUNITIES
-- =====================================================
INSERT INTO communities (id, name, city, country) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'NYC Coffee Community', 'New York', 'USA'),
    ('550e8400-e29b-41d4-a716-446655440002', 'LA Coffee Hub', 'Los Angeles', 'USA'),
    ('550e8400-e29b-41d4-a716-446655440003', 'SF Bay Area Coffee', 'San Francisco', 'USA'),
    ('550e8400-e29b-41d4-a716-446655440004', 'London Coffee Circle', 'London', 'UK'),
    ('550e8400-e29b-41d4-a716-446655440005', 'Paris Café Community', 'Paris', 'France');

-- =====================================================
-- INSERT COFFEE SHOPS
-- =====================================================
INSERT INTO coffee_shops (id, name, address, image_url, points_back_percentage, current_crowdedness, is_quiet_friendly, opening_hours, community_id) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', 'Blue Bottle Coffee', '123 Main St, NYC', 'coffeeshop1', 15, 75, true, '6:00 AM - 8:00 PM', '550e8400-e29b-41d4-a716-446655440001'),
    ('660e8400-e29b-41d4-a716-446655440002', 'Stumptown Coffee', '456 Coffee Ave, NYC', 'coffeeshop2', 12, 45, false, '7:00 AM - 9:00 PM', '550e8400-e29b-41d4-a716-446655440001'),
    ('660e8400-e29b-41d4-a716-446655440003', 'Joe Coffee', '789 Brew St, NYC', 'coffeeshop3', 18, 90, true, '6:30 AM - 7:30 PM', '550e8400-e29b-41d4-a716-446655440001'),
    
    -- LA Coffee Shops
    ('660e8400-e29b-41d4-a716-446655440004', 'Intelligentsia Coffee', '101 Venice Blvd, LA', 'coffeeshop4', 16, 60, true, '6:00 AM - 8:00 PM', '550e8400-e29b-41d4-a716-446655440002'),
    ('660e8400-e29b-41d4-a716-446655440005', 'Alfred Coffee', '202 Melrose Ave, LA', 'coffeeshop5', 14, 80, false, '7:00 AM - 9:00 PM', '550e8400-e29b-41d4-a716-446655440002'),
    
    -- SF Coffee Shops
    ('660e8400-e29b-41d4-a716-446655440006', 'Four Barrel Coffee', '303 Valencia St, SF', 'coffeeshop6', 20, 35, true, '6:00 AM - 7:00 PM', '550e8400-e29b-41d4-a716-446655440003'),
    ('660e8400-e29b-41d4-a716-446655440007', 'Ritual Coffee', '404 Union St, SF', 'coffeeshop7', 13, 55, false, '6:30 AM - 8:30 PM', '550e8400-e29b-41d4-a716-446655440003'),
    
    -- London Coffee Shops
    ('660e8400-e29b-41d4-a716-446655440008', 'Monmouth Coffee', '27 Monmouth St, London', 'coffeeshop8', 10, 70, true, '8:00 AM - 6:00 PM', '550e8400-e29b-41d4-a716-446655440004'),
    ('660e8400-e29b-41d4-a716-446655440009', 'Workshop Coffee', '1 Barrett St, London', 'coffeeshop9', 12, 40, false, '7:00 AM - 7:00 PM', '550e8400-e29b-41d4-a716-446655440004'),
    
    -- Paris Coffee Shops
    ('660e8400-e29b-41d4-a716-446655440010', 'Ten Belles', '10 Rue de la Grange aux Belles, Paris', 'coffeeshop10', 8, 85, true, '8:30 AM - 5:00 PM', '550e8400-e29b-41d4-a716-446655440005'),
    ('660e8400-e29b-41d4-a716-446655440011', 'Lomi Coffee', '3ter Rue Marcadet, Paris', 'coffeeshop11', 11, 50, false, '9:00 AM - 6:00 PM', '550e8400-e29b-41d4-a716-446655440005');

-- =====================================================
-- INSERT BEVERAGES
-- =====================================================

-- Blue Bottle Coffee beverages
INSERT INTO beverages (id, name, price, description, category, coffee_shop_id) VALUES
    ('770e8400-e29b-41d4-a716-446655440001', 'Espresso', 3.50, 'Rich and bold', 'coffee', '660e8400-e29b-41d4-a716-446655440001'),
    ('770e8400-e29b-41d4-a716-446655440002', 'Cappuccino', 4.50, 'Creamy and smooth', 'coffee', '660e8400-e29b-41d4-a716-446655440001'),
    ('770e8400-e29b-41d4-a716-446655440003', 'Croissant', 3.00, 'Buttery and flaky', 'food', '660e8400-e29b-41d4-a716-446655440001'),
    ('770e8400-e29b-41d4-a716-446655440004', 'Latte', 5.00, 'Perfect steamed milk', 'coffee', '660e8400-e29b-41d4-a716-446655440001'),

-- Stumptown Coffee beverages
    ('770e8400-e29b-41d4-a716-446655440005', 'Cold Brew', 4.00, 'Smooth and refreshing', 'cold_drinks', '660e8400-e29b-41d4-a716-446655440002'),
    ('770e8400-e29b-41d4-a716-446655440006', 'Latte', 5.00, 'Perfect milk foam', 'coffee', '660e8400-e29b-41d4-a716-446655440002'),
    ('770e8400-e29b-41d4-a716-446655440007', 'Green Tea', 3.00, 'Organic and fresh', 'tea', '660e8400-e29b-41d4-a716-446655440002'),
    ('770e8400-e29b-41d4-a716-446655440008', 'Iced Coffee', 3.75, 'Cool and energizing', 'cold_drinks', '660e8400-e29b-41d4-a716-446655440002'),

-- Joe Coffee beverages
    ('770e8400-e29b-41d4-a716-446655440009', 'Americano', 3.75, 'Classic and strong', 'coffee', '660e8400-e29b-41d4-a716-446655440003'),
    ('770e8400-e29b-41d4-a716-446655440010', 'Matcha Latte', 5.50, 'Creamy matcha goodness', 'tea', '660e8400-e29b-41d4-a716-446655440003'),
    ('770e8400-e29b-41d4-a716-446655440011', 'Blueberry Muffin', 3.50, 'Fresh baked daily', 'food', '660e8400-e29b-41d4-a716-446655440003'),
    ('770e8400-e29b-41d4-a716-446655440012', 'Cortado', 4.25, 'Perfect balance', 'coffee', '660e8400-e29b-41d4-a716-446655440003'),

-- Intelligentsia Coffee beverages
    ('770e8400-e29b-41d4-a716-446655440013', 'Single Origin Pour Over', 6.00, 'Artisan coffee experience', 'coffee', '660e8400-e29b-41d4-a716-446655440004'),
    ('770e8400-e29b-41d4-a716-446655440014', 'Flat White', 4.75, 'Velvety microfoam', 'coffee', '660e8400-e29b-41d4-a716-446655440004'),
    ('770e8400-e29b-41d4-a716-446655440015', 'Avocado Toast', 8.50, 'Fresh avocado on sourdough', 'food', '660e8400-e29b-41d4-a716-446655440004'),

-- Alfred Coffee beverages
    ('770e8400-e29b-41d4-a716-446655440016', 'Vanilla Latte', 5.25, 'Sweet vanilla flavor', 'coffee', '660e8400-e29b-41d4-a716-446655440005'),
    ('770e8400-e29b-41d4-a716-446655440017', 'Iced Matcha', 4.50, 'Refreshing green tea', 'cold_drinks', '660e8400-e29b-41d4-a716-446655440005'),
    ('770e8400-e29b-41d4-a716-446655440018', 'Acai Bowl', 12.00, 'Antioxidant-rich breakfast', 'food', '660e8400-e29b-41d4-a716-446655440005'),

-- Four Barrel Coffee beverages
    ('770e8400-e29b-41d4-a716-446655440019', 'Gibraltar', 4.00, 'SF specialty coffee', 'coffee', '660e8400-e29b-41d4-a716-446655440006'),
    ('770e8400-e29b-41d4-a716-446655440020', 'Drip Coffee', 3.25, 'House blend perfection', 'coffee', '660e8400-e29b-41d4-a716-446655440006'),
    ('770e8400-e29b-41d4-a716-446655440021', 'Chocolate Chip Cookie', 2.75, 'Homemade goodness', 'food', '660e8400-e29b-41d4-a716-446655440006'),

-- Ritual Coffee beverages
    ('770e8400-e29b-41d4-a716-446655440022', 'Ethiopian Pour Over', 5.50, 'Floral and bright', 'coffee', '660e8400-e29b-41d4-a716-446655440007'),
    ('770e8400-e29b-41d4-a716-446655440023', 'Chai Latte', 4.25, 'Spiced tea perfection', 'tea', '660e8400-e29b-41d4-a716-446655440007'),
    ('770e8400-e29b-41d4-a716-446655440024', 'Cold Brew Float', 5.75, 'Cold brew with ice cream', 'cold_drinks', '660e8400-e29b-41d4-a716-446655440007');

-- Sample users (NOTE: In production, auth_user_id would come from Supabase Auth)
INSERT INTO users (id, name, email, profile_image_url, community_id, points, auth_user_id) VALUES
    ('880e8400-e29b-41d4-a716-446655440001', 'John Doe', 'john@example.com', 'profile1', '550e8400-e29b-41d4-a716-446655440001', 1250, null),
    ('880e8400-e29b-41d4-a716-446655440002', 'Jane Smith', 'jane@example.com', 'profile2', '550e8400-e29b-41d4-a716-446655440001', 980, null),
    ('880e8400-e29b-41d4-a716-446655440003', 'Mike Johnson', 'mike@example.com', 'profile3', '550e8400-e29b-41d4-a716-446655440001', 1420, null),
    ('880e8400-e29b-41d4-a716-446655440004', 'Sarah Wilson', 'sarah@example.com', 'profile4', '550e8400-e29b-41d4-a716-446655440002', 750, null),
    ('880e8400-e29b-41d4-a716-446655440005', 'David Chen', 'david@example.com', 'profile5', '550e8400-e29b-41d4-a716-446655440003', 2100, null),
    ('880e8400-e29b-41d4-a716-446655440006', 'Emily Brown', 'emily@example.com', 'profile6', '550e8400-e29b-41d4-a716-446655440004', 890, null),
    ('880e8400-e29b-41d4-a716-446655440007', 'Pierre Dubois', 'pierre@example.com', 'profile7', '550e8400-e29b-41d4-a716-446655440005', 1350, null);

-- Sample friendships
INSERT INTO friendships (user1_id, user2_id) VALUES
    ('880e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440002'), -- John & Jane
    ('880e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440003'), -- John & Mike
    ('880e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440003'); -- Jane & Mike

-- Sample transactions
INSERT INTO transactions (id, user_id, coffee_shop_id, transaction_type, amount, description) VALUES
    ('990e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', 'earned', 50, 'Cappuccino purchase'),
    ('990e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'redeemed', 100, 'Free latte'),
    ('990e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'earned', 65, 'Espresso and croissant'),
    ('990e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440003', 'earned', 75, 'Matcha latte and muffin'),
    ('990e8400-e29b-41d4-a716-446655440005', '880e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440004', 'earned', 90, 'Pour over coffee'),
    ('990e8400-e29b-41d4-a716-446655440006', '880e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440006', 'earned', 120, 'Gibraltar and cookie');

-- Sample point transfers
INSERT INTO transactions (id, user_id, related_user_id, transaction_type, amount, description) VALUES
    ('990e8400-e29b-41d4-a716-446655440007', '880e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440002', 'sent', 25, 'Sent to Jane'),
    ('990e8400-e29b-41d4-a716-446655440008', '880e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', 'received', 25, 'Received from John'),
    ('990e8400-e29b-41d4-a716-446655440009', '880e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440001', 'sent', 50, 'Birthday gift'),
    ('990e8400-e29b-41d4-a716-446655440010', '880e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440003', 'received', 50, 'Birthday gift from Mike');

-- Sample friend requests
INSERT INTO friend_requests (id, from_user_id, to_user_id, status) VALUES
    ('aa0e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440005', 'pending'),
    ('aa0e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440006', '880e8400-e29b-41d4-a716-446655440007', 'pending'),
    ('aa0e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440002', 'accepted'),
    ('aa0e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440003', 'accepted'),
    ('aa0e8400-e29b-41d4-a716-446655440005', '880e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440003', 'accepted');