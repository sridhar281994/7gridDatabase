#!/bin/bash
set -e

echo "Updating agent names and adding funky descriptions..."

mkdir -p backup/db_inspect
OUTPUT_FILE="backup/db_inspect/agent_name_description_update_log.txt"

psql "$DATABASE_URL" <<'SQL'
DO $$
BEGIN
    -- ============================
    -- Indian Names (60%)
    -- ============================

    UPDATE public.users SET name = 'Aarav Sharma', description = 'Chess champ & coffee addict ☕♟️' WHERE id = 10001 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Arjun Mehta', description = 'Master of puzzles & chai enthusiast 🍵🧩' WHERE id = 10002 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Priya Nair', description = 'Spreadsheet queen & meme curator 😎📊' WHERE id = 10003 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Rohan Mehta', description = 'Code wizard & sneaker collector 👟💻' WHERE id = 10004 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Sneha Iyer', description = 'Queen of spreadsheets & coffee breaks ☕👑' WHERE id = 10005 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Kavya Iyer', description = 'Travel bug & food explorer 🌍🍕' WHERE id = 10006 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Aditya Verma', description = 'Guitar hero & karaoke star 🎸🎤' WHERE id = 10007 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Neha Reddy', description = 'Yoga lover & green tea addict 🧘‍♀️🍵' WHERE id = 10008 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Suresh Babu', description = 'Adventure seeker & pun master 🏞️😂' WHERE id = 10009 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Ananya Singh', description = 'Bookworm & midnight coder 📚🌙' WHERE id = 10010 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Karthik Menon', description = 'Soccer fan & chai lover ⚽🍵' WHERE id = 10011 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Sneha Patil', description = 'Painter & chocolate connoisseur 🎨🍫' WHERE id = 10012 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Varun Shetty', description = 'Tech geek & puzzle solver 🤖🧩' WHERE id = 10013 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Meera Joshi', description = 'Coffee enthusiast & meme queen ☕👑' WHERE id = 10014 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Rohit Kulkarni', description = 'Spreadsheet ninja & meme curator 😎📊' WHERE id = 10015 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Priya Desai', description = 'Tech whisperer & chai lover 🍵💻' WHERE id = 10016 AND name LIKE 'Agent%';

    -- ============================
    -- International Names (40%)
    -- ============================

    UPDATE public.users SET name = 'Daniel Costa', description = 'Beach bum & travel junkie 🏖️✈️' WHERE id = 10017 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Mia Svensson', description = 'Coffeeholic & sunrise chaser ☕🌅' WHERE id = 10018 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Jacob Müller', description = 'Cyclist & code tinkerer 🚴‍♂️💻' WHERE id = 10019 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Layla Ibrahim', description = 'Music lover & snack connoisseur 🎶🍿' WHERE id = 10020 AND name LIKE 'Agent%';

END $$;
SQL

echo "Agent name and description updates completed successfully."

echo "Exporting updated agent list..."

psql "$DATABASE_URL" -c \
"SELECT id, phone, email, name, description, wallet_balance FROM public.users WHERE id BETWEEN 10000 AND 10020 ORDER BY id;" \
> "$OUTPUT_FILE"

echo "Export completed: $OUTPUT_FILE"
