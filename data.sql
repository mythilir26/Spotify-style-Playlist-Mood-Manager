-- ==========================================
-- MEMBER 2: SAMPLE DATA (data.sql)
-- Run AFTER schema.sql. Order: users -> songs -> playlists -> playlist_songs
-- ==========================================

-- Safe to re-run: clears old rows and restarts the SERIAL ids from 1
TRUNCATE TABLE playlist_songs, playlists, songs, users RESTART IDENTITY CASCADE;

-- 1. USERS (25 rows)
INSERT INTO users (username, email, subscription_tier) VALUES
('aarav_s',   'aarav.sharma@example.com',  'Premium'),
('diya_p',    'diya.patel@example.com',    'Student'),
('rohan_k',   'rohan.kumar@example.com',   'Free'),
('ananya_r',  'ananya.reddy@example.com',  'Premium'),
('karthik_n', 'karthik.nair@example.com',  'Student'),
('priya_m',   'priya.menon@example.com',   'Free'),
('vikram_s',  'vikram.singh@example.com',  'Premium'),
('sneha_g',   'sneha.gupta@example.com',   'Student'),
('arjun_d',   'arjun.das@example.com',     'Free'),
('meera_i',   'meera.iyer@example.com',    'Premium'),
('rahul_v',   'rahul.verma@example.com',   'Free'),
('isha_b',    'isha.bose@example.com',     'Student'),
('nikhil_j',  'nikhil.joshi@example.com',  'Premium'),
('kavya_h',   'kavya.hegde@example.com',   'Free'),
('siddharth_t','siddharth.t@example.com',  'Student'),
('pooja_c',   'pooja.chopra@example.com',  'Premium'),
('manish_y',  'manish.yadav@example.com',  'Free'),
('tara_f',    'tara.fernandes@example.com','Student'),
('devansh_m', 'devansh.mehta@example.com', 'Premium'),
('lakshmi_o', 'lakshmi.o@example.com',     'Free'),
('harsh_l',   'harsh.lal@example.com',     'Student'),
('nisha_k',   'nisha.khan@example.com',    'Premium'),
('om_p',      'om.prakash@example.com',    'Free'),
('riya_a',    'riya.arora@example.com',    'Student'),
('yash_w',    'yash.wagle@example.com',    'Premium');

-- 2. SONGS (30 rows; durations are approximate)
INSERT INTO songs (title, artist, album, genre, mood, duration_sec, release_year, play_count) VALUES
('Happy',                    'Pharrell Williams',  'G I R L',                 'Pop',        'Happy',     233, 2013, 4500),
('Uptown Funk',              'Mark Ronson',        'Uptown Special',          'Funk',       'Happy',     270, 2014, 5200),
('Can''t Stop the Feeling!', 'Justin Timberlake',  'Trolls',                  'Pop',        'Happy',     236, 2016, 3100),
('Shake It Off',             'Taylor Swift',       '1989',                    'Pop',        'Happy',     219, 2014, 3900),
('Someone Like You',         'Adele',              '21',                      'Pop',        'Sad',       285, 2011, 4800),
('Fix You',                  'Coldplay',           'X&Y',                     'Rock',       'Sad',       295, 2005, 4100),
('Hurt',                     'Johnny Cash',        'American IV',             'Country',    'Sad',       218, 2002, 1700),
('Channa Mereya',            'Arijit Singh',       'Ae Dil Hai Mushkil',      'Bollywood',  'Sad',       289, 2016, 3600),
('Weightless',               'Marconi Union',      'Weightless',              'Ambient',    'Chill',     480, 2011,  900),
('Sunflower',                'Post Malone',        'Spider-Man: Into the Spider-Verse','Hip-Hop','Chill', 158, 2018, 4300),
('Ocean Eyes',               'Billie Eilish',      'dont smile at me',        'Pop',        'Chill',     200, 2016, 2700),
('Electric Feel',            'MGMT',               'Oracular Spectacular',    'Indie',      'Chill',     229, 2007, 2100),
('Don''t Stop Me Now',       'Queen',              'Jazz',                    'Rock',       'Energetic', 209, 1979, 3800),
('Mr. Brightside',           'The Killers',        'Hot Fuss',                'Rock',       'Energetic', 223, 2004, 4400),
('Levitating',               'Dua Lipa',           'Future Nostalgia',        'Pop',        'Energetic', 203, 2020, 4600),
('Blinding Lights',          'The Weeknd',         'After Hours',             'Synth-pop',  'Energetic', 200, 2019, 5800),
('Lose Yourself',            'Eminem',             '8 Mile',                  'Hip-Hop',    'Workout',   326, 2002, 5000),
('Stronger',                 'Kanye West',         'Graduation',              'Hip-Hop',    'Workout',   311, 2007, 3300),
('Eye of the Tiger',         'Survivor',           'Eye of the Tiger',        'Rock',       'Workout',   246, 1982, 3700),
('Till I Collapse',          'Eminem',             'The Eminem Show',         'Hip-Hop',    'Workout',   297, 2002, 2900),
('Believer',                 'Imagine Dragons',    'Evolve',                  'Rock',       'Workout',   204, 2017, 4200),
('Clair de Lune',            'Claude Debussy',     'Suite bergamasque',       'Classical',  'Focus',     300, 1905, 1800),
('Experience',               'Ludovico Einaudi',   'In a Time Lapse',         'Classical',  'Focus',     315, 2013, 2400),
('Time',                     'Hans Zimmer',        'Inception OST',           'Soundtrack', 'Focus',     275, 2010, 3000),
('Nuvole Bianche',           'Ludovico Einaudi',   'Una Mattina',             'Classical',  'Focus',     357, 2004, 2000),
('Perfect',                  'Ed Sheeran',         'Divide',                  'Pop',        'Romantic',  263, 2017, 5400),
('Tum Hi Ho',                'Arijit Singh',       'Aashiqui 2',              'Bollywood',  'Romantic',  262, 2013, 4900),
('All of Me',                'John Legend',        'Love in the Future',      'R&B',        'Romantic',  269, 2013, 3500),
('Thinking Out Loud',        'Ed Sheeran',         'x',                       'Pop',        'Romantic',  281, 2014, 4000),
('Kesariya',                 'Arijit Singh',       'Brahmastra',              'Bollywood',  'Romantic',  268, 2022, 3200);

-- 3. PLAYLISTS (25 rows)
INSERT INTO playlists (user_id, playlist_name, target_mood, is_public) VALUES
(1,  'Morning Vibes',     'Happy',     TRUE),
(2,  'Gym Beast Mode',    'Workout',   TRUE),
(3,  'Late Night Feels',  'Sad',       FALSE),
(4,  'Study Session',     'Focus',     TRUE),
(5,  'Weekend Chill',     'Chill',     TRUE),
(6,  'Date Night',        'Romantic',  FALSE),
(7,  'Road Trip Mix',     'Mixed',     TRUE),
(8,  'Party Starters',    'Energetic', TRUE),
(9,  'Rainy Day',         'Sad',       FALSE),
(10, 'Deep Work',         'Focus',     TRUE),
(1,  'Throwback Hits',    'Mixed',     TRUE),
(2,  'Cardio Boost',      'Workout',   TRUE),
(3,  'Sunday Slow',       'Chill',     FALSE),
(11, 'Bollywood Love',    'Romantic',  TRUE),
(12, 'Feel Good Friday',  'Happy',     TRUE),
(13, 'Coding Night',      'Focus',     TRUE),
(14, 'Heartbreak Hotel',  'Sad',       FALSE),
(15, 'Pre-Game Hype',     'Energetic', TRUE),
(16, 'Sleep Easy',        'Chill',     FALSE),
(17, 'Wedding Songs',     'Romantic',  TRUE),
(18, 'Mood Swings',       'Mixed',     TRUE),
(19, 'Morning Run',       'Workout',   TRUE),
(20, 'Coffee Shop',       'Chill',     TRUE),
(21, 'Exam Week',         'Focus',     FALSE),
(22, 'Summer Smiles',     'Happy',     TRUE);

-- 4. PLAYLIST_SONGS (30 rows)
-- Playlists 1-5 have more than 3 songs (needed for the HAVING queries)
INSERT INTO playlist_songs (playlist_id, song_id, track_order) VALUES
-- 1 Morning Vibes (6 songs)
(1, 1, 1), (1, 2, 2), (1, 3, 3), (1, 4, 4), (1, 15, 5), (1, 10, 6),
-- 2 Gym Beast Mode (5 songs)
(2, 17, 1), (2, 18, 2), (2, 19, 3), (2, 20, 4), (2, 21, 5),
-- 3 Late Night Feels (5 songs; song 26 is Romantic, a deliberate mood mismatch)
(3, 5, 1), (3, 6, 2), (3, 7, 3), (3, 8, 4), (3, 26, 5),
-- 4 Study Session (4 songs)
(4, 22, 1), (4, 23, 2), (4, 24, 3), (4, 25, 4),
-- 5 Weekend Chill (4 songs)
(5, 9, 1), (5, 10, 2), (5, 11, 3), (5, 12, 4),
-- Smaller playlists
(6, 27, 1),
(7, 13, 1),
(8, 16, 1),
(9, 8, 1),
(10, 24, 1),
(14, 30, 1);

-- Quick check: expect 25, 30, 25, 30
SELECT (SELECT COUNT(*) FROM users) AS users,
       (SELECT COUNT(*) FROM songs) AS songs,
       (SELECT COUNT(*) FROM playlists) AS playlists,
       (SELECT COUNT(*) FROM playlist_songs) AS playlist_songs;
