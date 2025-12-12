-- db_update_agent_names.sql
-- Update or insert the remaining 4 agent names

INSERT INTO users (id, name)
VALUES 
    (10002, 'Harish N'),
    (10005, 'Kavya S'),
    (10015, 'Raghav Menon'),
    (10016, 'Priya Desai')
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name;
