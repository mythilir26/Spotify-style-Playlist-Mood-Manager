-- ==========================================
-- MEMBER 3: ADVANCED SQL (advanced.sql)
-- Run AFTER schema.sql and data.sql (Supabase / PostgreSQL)
-- Safe to re-run: uses CREATE OR REPLACE / DROP IF EXISTS
--
-- HOW TO RUN IN SUPABASE (SQL Editor):
--   Do NOT run the whole file at once. Run it in parts:
--   1) Sections A, B, C (views, procedures, triggers) together
--   2) Section D queries, one at a time
--   3) Section E tests, one block at a time
--   (Running everything together makes the ROLLBACK in section E
--    undo the objects created in sections A-C.)
-- ==========================================

-- ------------------------------------------
-- A. VIEWS
-- ------------------------------------------

-- V1. playlist_summary: one row per playlist with owner, song count, runtime
CREATE OR REPLACE VIEW playlist_summary AS
SELECT p.playlist_id,
       p.playlist_name,
       u.username                                   AS owner,
       p.target_mood,
       p.is_public,
       COUNT(ps.song_id)                            AS song_count,
       COALESCE(SUM(s.duration_sec), 0)             AS total_seconds,
       ROUND(COALESCE(SUM(s.duration_sec), 0) / 60.0, 2) AS total_minutes
FROM playlists p
JOIN users u                ON u.user_id = p.user_id
LEFT JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
LEFT JOIN songs s           ON s.song_id = ps.song_id
GROUP BY p.playlist_id, p.playlist_name, u.username, p.target_mood, p.is_public;

-- V2. happy_songs: all Happy songs, most played first
CREATE OR REPLACE VIEW happy_songs AS
SELECT song_id, title, artist, genre, play_count
FROM songs
WHERE mood = 'Happy'
ORDER BY play_count DESC;

-- V3. mood_match_report: how well each playlist's songs match its target mood
CREATE OR REPLACE VIEW mood_match_report AS
SELECT p.playlist_id,
       p.playlist_name,
       p.target_mood,
       COUNT(*)                                          AS total_songs,
       COUNT(*) FILTER (WHERE s.mood = p.target_mood)    AS matching_songs,
       ROUND(100.0 * COUNT(*) FILTER (WHERE s.mood = p.target_mood) / COUNT(*), 1)
                                                         AS match_percent
FROM playlists p
JOIN playlist_songs ps ON ps.playlist_id = p.playlist_id
JOIN songs s           ON s.song_id = ps.song_id
WHERE p.target_mood <> 'Mixed'
GROUP BY p.playlist_id, p.playlist_name, p.target_mood;

-- ------------------------------------------
-- B. STORED PROCEDURES / FUNCTIONS
-- ------------------------------------------

-- P1. add_song_to_playlist: validates, then appends the song at the end
--     (track_order is filled automatically by trigger T1 below)
CREATE OR REPLACE PROCEDURE add_song_to_playlist(p_playlist_id INT, p_song_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM playlists WHERE playlist_id = p_playlist_id) THEN
        RAISE EXCEPTION 'Playlist % does not exist', p_playlist_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM songs WHERE song_id = p_song_id) THEN
        RAISE EXCEPTION 'Song % does not exist', p_song_id;
    END IF;

    INSERT INTO playlist_songs (playlist_id, song_id)
    VALUES (p_playlist_id, p_song_id);

    RAISE NOTICE 'Song % added to playlist %', p_song_id, p_playlist_id;
END;
$$;

-- P2. get_songs_by_mood: returns songs of a mood, most played first
CREATE OR REPLACE FUNCTION get_songs_by_mood(p_mood VARCHAR)
RETURNS TABLE (song_id INT, title VARCHAR, artist VARCHAR, genre VARCHAR, play_count INT)
LANGUAGE sql
AS $$
    SELECT s.song_id, s.title, s.artist, s.genre, s.play_count
    FROM songs s
    WHERE s.mood = p_mood
    ORDER BY s.play_count DESC;
$$;

-- P3. recommend_songs: songs matching a playlist's target mood
--     that are not already in that playlist
CREATE OR REPLACE FUNCTION recommend_songs(p_playlist_id INT)
RETURNS TABLE (song_id INT, title VARCHAR, artist VARCHAR, mood VARCHAR, play_count INT)
LANGUAGE sql
AS $$
    SELECT s.song_id, s.title, s.artist, s.mood, s.play_count
    FROM songs s
    JOIN playlists p ON p.playlist_id = p_playlist_id
    WHERE s.mood = p.target_mood
      AND s.song_id NOT IN (SELECT ps.song_id
                            FROM playlist_songs ps
                            WHERE ps.playlist_id = p_playlist_id)
    ORDER BY s.play_count DESC;
$$;

-- ------------------------------------------
-- C. TRIGGERS
-- ------------------------------------------

-- T1. Auto-assign track_order when it is not provided
CREATE OR REPLACE FUNCTION fn_set_track_order()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.track_order IS NULL THEN
        SELECT COALESCE(MAX(track_order), 0) + 1
        INTO NEW.track_order
        FROM playlist_songs
        WHERE playlist_id = NEW.playlist_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_track_order ON playlist_songs;
CREATE TRIGGER trg_set_track_order
BEFORE INSERT ON playlist_songs
FOR EACH ROW
EXECUTE FUNCTION fn_set_track_order();

-- T2. Block duplicate songs in a playlist with a friendly error message
CREATE OR REPLACE FUNCTION fn_block_duplicate_song()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM playlist_songs
               WHERE playlist_id = NEW.playlist_id
                 AND song_id = NEW.song_id) THEN
        RAISE EXCEPTION 'Song % is already in playlist %', NEW.song_id, NEW.playlist_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_block_duplicate_song ON playlist_songs;
CREATE TRIGGER trg_block_duplicate_song
BEFORE INSERT ON playlist_songs
FOR EACH ROW
EXECUTE FUNCTION fn_block_duplicate_song();

-- T3. Auto-update songs.play_count whenever a play is logged
--     (needs a small new table to record plays)
CREATE TABLE IF NOT EXISTS song_plays (
    play_id   SERIAL PRIMARY KEY,
    user_id   INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    song_id   INT NOT NULL REFERENCES songs(song_id) ON DELETE CASCADE,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_increment_play_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE songs
    SET play_count = play_count + 1
    WHERE song_id = NEW.song_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_increment_play_count ON song_plays;
CREATE TRIGGER trg_increment_play_count
AFTER INSERT ON song_plays
FOR EACH ROW
EXECUTE FUNCTION fn_increment_play_count();

-- ------------------------------------------
-- D. MOOD-BASED FILTERING QUERIES
-- ------------------------------------------

-- M1. Use the views
SELECT * FROM playlist_summary ORDER BY total_seconds DESC;
SELECT * FROM happy_songs;
SELECT * FROM mood_match_report ORDER BY match_percent;

-- M2. Use the functions
SELECT * FROM get_songs_by_mood('Chill');
SELECT * FROM recommend_songs(4);      -- suggestions for "Study Session"

-- M3. Top 2 songs in every mood (window function)
SELECT mood, title, artist, play_count
FROM (
    SELECT mood, title, artist, play_count,
           ROW_NUMBER() OVER (PARTITION BY mood ORDER BY play_count DESC) AS rank_in_mood
    FROM songs
) ranked
WHERE rank_in_mood <= 2
ORDER BY mood, rank_in_mood;

-- M4. Mood breakdown of the songs inside one playlist
SELECT s.mood, COUNT(*) AS songs
FROM playlist_songs ps
JOIN songs s     ON s.song_id = ps.song_id
JOIN playlists p ON p.playlist_id = ps.playlist_id
WHERE p.playlist_name = 'Late Night Feels'
GROUP BY s.mood
ORDER BY songs DESC;

-- M5. Average duration and popularity per mood
SELECT mood,
       ROUND(AVG(duration_sec) / 60.0, 2) AS avg_minutes,
       ROUND(AVG(play_count), 0)          AS avg_plays
FROM songs
GROUP BY mood
ORDER BY avg_plays DESC;

-- ------------------------------------------
-- E. TEST DEMOS (run each block separately; ROLLBACK keeps data unchanged)
-- ------------------------------------------

-- X1. Procedure + auto track_order trigger (playlist 6 has 1 song, so new one gets track 2)
BEGIN;
CALL add_song_to_playlist(6, 28);
SELECT * FROM playlist_songs WHERE playlist_id = 6 ORDER BY track_order;
ROLLBACK;

-- X2. Duplicate blocked (should FAIL with "already in playlist")
CALL add_song_to_playlist(1, 1);

-- X3. Bad playlist id (should FAIL with "does not exist")
CALL add_song_to_playlist(999, 1);

-- X4. play_count trigger (Happy has 4500 plays -> 4501 inside the transaction)
BEGIN;
SELECT title, play_count FROM songs WHERE song_id = 1;
INSERT INTO song_plays (user_id, song_id) VALUES (1, 1);
SELECT title, play_count FROM songs WHERE song_id = 1;
ROLLBACK;
