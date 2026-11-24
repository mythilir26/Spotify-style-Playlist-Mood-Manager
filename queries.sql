-- ==========================================
-- MEMBER 2: QUERIES (queries.sql)
-- Run AFTER schema.sql and data.sql. Screenshot each result for the report.
-- ==========================================

-- ------------------------------------------
-- A. JOIN QUERIES
-- ------------------------------------------

-- Q1. Users -> Playlists -> Playlist_Songs -> Songs (4-table JOIN)
-- Purpose: list every song in every playlist along with the owner.
SELECT u.username,
       p.playlist_name,
       ps.track_order,
       s.title,
       s.artist,
       s.mood
FROM users u
JOIN playlists p       ON p.user_id = u.user_id
JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
JOIN songs s           ON s.song_id = ps.song_id
ORDER BY u.username, p.playlist_name, ps.track_order;

-- Q2. Songs inside one playlist, in track order
-- Purpose: show what plays when a user opens "Morning Vibes".
SELECT ps.track_order, s.title, s.artist, s.duration_sec
FROM playlist_songs ps
JOIN songs s ON s.song_id = ps.song_id
JOIN playlists p ON p.playlist_id = ps.playlist_id
WHERE p.playlist_name = 'Morning Vibes'
ORDER BY ps.track_order;

-- Q3. Users who have no playlists (LEFT JOIN)
-- Purpose: find inactive users.
SELECT u.user_id, u.username, u.subscription_tier
FROM users u
LEFT JOIN playlists p ON p.user_id = u.user_id
WHERE p.playlist_id IS NULL
ORDER BY u.user_id;

-- ------------------------------------------
-- B. AGGREGATE QUERIES
-- ------------------------------------------

-- Q4. Most played genre (SUM + GROUP BY)
-- Purpose: which genre has the highest total plays.
SELECT genre,
       SUM(play_count) AS total_plays,
       COUNT(*)        AS songs_in_genre
FROM songs
GROUP BY genre
ORDER BY total_plays DESC;
-- To get only the top genre, add: LIMIT 1;

-- Q5. Total duration per playlist (SUM, COUNT, GROUP BY, HAVING)
-- Purpose: playlists with at least 3 songs and their total runtime.
SELECT p.playlist_name,
       COUNT(ps.song_id)                       AS song_count,
       SUM(s.duration_sec)                     AS total_seconds,
       ROUND(SUM(s.duration_sec) / 60.0, 2)    AS total_minutes
FROM playlists p
JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
JOIN songs s           ON s.song_id = ps.song_id
GROUP BY p.playlist_id, p.playlist_name
HAVING COUNT(ps.song_id) >= 3
ORDER BY total_seconds DESC;

-- Q6. Top 5 songs by play_count
SELECT song_id, title, artist, genre, play_count
FROM songs
ORDER BY play_count DESC
LIMIT 5;

-- Q7. Number of songs curated per user
-- Purpose: LEFT JOINs keep users with 0 playlists/songs in the output.
SELECT u.username,
       COUNT(DISTINCT p.playlist_id) AS playlists,
       COUNT(ps.song_id)             AS total_songs
FROM users u
LEFT JOIN playlists p       ON p.user_id = u.user_id
LEFT JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
GROUP BY u.user_id, u.username
ORDER BY total_songs DESC, u.username;

-- Q8. Playlists with more than 3 songs
SELECT p.playlist_name, COUNT(ps.song_id) AS song_count
FROM playlists p
JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
GROUP BY p.playlist_id, p.playlist_name
HAVING COUNT(ps.song_id) > 3
ORDER BY song_count DESC;

-- Q9. Engagement per subscription tier
-- Purpose: playlists and songs curated by Free vs Premium vs Student.
SELECT u.subscription_tier,
       COUNT(DISTINCT u.user_id)     AS users,
       COUNT(DISTINCT p.playlist_id) AS playlists,
       COUNT(ps.song_id)             AS songs_added
FROM users u
LEFT JOIN playlists p       ON p.user_id = u.user_id
LEFT JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
GROUP BY u.subscription_tier
ORDER BY songs_added DESC;

-- ------------------------------------------
-- C. MOOD QUERIES
-- ------------------------------------------

-- Q10. Songs for a chosen mood, most popular first
SELECT title, artist, genre, play_count
FROM songs
WHERE mood = 'Workout'
ORDER BY play_count DESC;

-- Q11. Songs and total plays per mood
SELECT mood, COUNT(*) AS songs, SUM(play_count) AS total_plays
FROM songs
GROUP BY mood
ORDER BY total_plays DESC;

-- Q12. Mood mismatch: songs whose mood differs from the playlist's target mood
SELECT p.playlist_name, p.target_mood, s.title, s.mood AS song_mood
FROM playlists p
JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
JOIN songs s           ON s.song_id = ps.song_id
WHERE p.target_mood <> 'Mixed'
  AND s.mood <> p.target_mood;

-- Q13. Songs not in any playlist (subquery)
SELECT song_id, title, artist
FROM songs
WHERE song_id NOT IN (SELECT song_id FROM playlist_songs)
ORDER BY title;

-- ------------------------------------------
-- D. INSERT / UPDATE / DELETE DEMOS
-- Each block is wrapped in a transaction and rolled back,
-- so your sample data stays unchanged. Select a block and run it.
-- ------------------------------------------

-- D1. INSERT
BEGIN;
INSERT INTO users (username, email) VALUES ('test_user', 'test@example.com');
SELECT * FROM users WHERE username = 'test_user';   -- subscription_tier defaults to 'Free'
ROLLBACK;

-- D2. UPDATE
BEGIN;
UPDATE users SET subscription_tier = 'Premium' WHERE username = 'rohan_k';
SELECT username, subscription_tier FROM users WHERE username = 'rohan_k';
ROLLBACK;

-- D3. DELETE with ON DELETE CASCADE
-- Deleting user 1 also removes their playlists and playlist_songs rows.
BEGIN;
SELECT COUNT(*) AS playlists_before FROM playlists WHERE user_id = 1;
DELETE FROM users WHERE user_id = 1;
SELECT COUNT(*) AS playlists_after  FROM playlists WHERE user_id = 1;   -- expect 0
ROLLBACK;

-- ------------------------------------------
-- E. CONSTRAINT TEST CASES (each one should FAIL; screenshot the error)
-- Run them one at a time.
-- ------------------------------------------

-- T1. Invalid mood -> violates CHECK on songs.mood
INSERT INTO songs (title, artist, genre, mood, duration_sec)
VALUES ('Bad Mood Song', 'Nobody', 'Pop', 'Angry', 200);

-- T2. Duplicate song in the same playlist -> violates composite PRIMARY KEY
INSERT INTO playlist_songs (playlist_id, song_id, track_order) VALUES (1, 1, 7);

-- T3. Playlist for a user that does not exist -> violates FOREIGN KEY
INSERT INTO playlists (user_id, playlist_name, target_mood) VALUES (999, 'Ghost', 'Happy');

-- T4. Duplicate email -> violates UNIQUE
INSERT INTO users (username, email) VALUES ('dup_user', 'aarav.sharma@example.com');

-- T5. Negative duration -> violates CHECK (duration_sec > 0)
INSERT INTO songs (title, artist, genre, mood, duration_sec)
VALUES ('Negative Song', 'Nobody', 'Pop', 'Happy', -5);
