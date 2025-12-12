-- ============================================================
-- Update system agent names (remaining 4 only)
-- Safe, idempotent migration script
-- ============================================================

DO $$
BEGIN
    -- Agent 10002
    UPDATE public.users 
    SET name = 'Arjun Mehta'
    WHERE id = 10002 AND name = 'Agent 10002';

    -- Agent 10005
    UPDATE public.users 
    SET name = 'Sneha Iyer'
    WHERE id = 10005 AND name = 'Agent 10005';

    -- Agent 10015
    UPDATE public.users 
    SET name = 'Rohit Kulkarni'
    WHERE id = 10015 AND name = 'Agent 10015';

    -- Agent 10016
    UPDATE public.users 
    SET name = 'Priya Desai'
    WHERE id = 10016 AND name = 'Agent 10016';

END $$;
