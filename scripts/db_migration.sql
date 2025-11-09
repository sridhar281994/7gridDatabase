-- =====================================================
-- Add Virtual Merchant (System Account) if not exists
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = 0) THEN
        INSERT INTO users (id, phone, email, password_hash, name, upi_id, description, wallet_balance, profile_image)
        VALUES (
            0,
            '0000000000',
            'merchant@system.local',
            'system',
            'System Merchant',
            NULL,
            'System auto-account for game fees',
            0,
            'assets/default.png'
        );
        -- Reset auto-increment to avoid collision
        PERFORM setval(pg_get_serial_sequence('users', 'id'), 
                       (SELECT MAX(id) FROM users) + 1, false);
    END IF;
END $$;
