-- ==========================================
-- MEMBER 1: DATABASE SCHEMA (schema.sql)
-- ==========================================

-- Note: Uncomment the next two lines only if running on local PostgreSQL.
-- Supabase automatically creates and connects to the default 'postgres' database.
-- CREATE DATABASE spotify_mood_db;
-- \c spotify_mood_db;

-- Clean reset if you need to re-run the script during testing
DROP TABLE IF EXISTS playlist_songs CASCADE;
DROP TABLE IF EXISTS playlists CASCADE;
DROP TABLE IF EXISTS songs CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. USERS TABLE
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    subscription_tier VARCHAR(20) DEFAULT 'Free' CHECK (subscription_tier IN ('Free', 'Premium', 'Student')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SONGS TABLE
CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    album VARCHAR(100),
    genre VARCHAR(50) NOT NULL,
    mood VARCHAR(50) NOT NULL CHECK (mood IN ('Happy', 'Sad', 'Chill', 'Energetic', 'Focus', 'Workout', 'Romantic')),
    duration_sec INT NOT NULL CHECK (duration_sec > 0),
    release_year INT CHECK (release_year >= 1900 AND release_year <= 2026)
);

-- 3. PLAYLISTS TABLE
CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    playlist_name VARCHAR(100) NOT NULL,
    target_mood VARCHAR(50) CHECK (target_mood IN ('Happy', 'Sad', 'Chill', 'Energetic', 'Focus', 'Workout', 'Romantic', 'Mixed')),
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_playlist_user
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE
);

-- 4. PLAYLIST_SONGS TABLE (Junction Table for Many-to-Many relationship)
CREATE TABLE playlist_songs (
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    track_order INT CHECK (track_order > 0),
    PRIMARY KEY (playlist_id, song_id),
    CONSTRAINT fk_ps_playlist
        FOREIGN KEY (playlist_id) 
        REFERENCES playlists(playlist_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_ps_song
        FOREIGN KEY (song_id) 
        REFERENCES songs(song_id) 
        ON DELETE CASCADE
);

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================
CREATE INDEX idx_songs_genre ON songs(genre);
CREATE INDEX idx_songs_mood ON songs(mood);
CREATE INDEX idx_playlists_target_mood ON playlists(target_mood);
CREATE INDEX idx_playlists_user_id ON playlists(user_id);

-- ==========================================
-- FINAL ALTER FIXES
-- ==========================================
ALTER TABLE songs 
ADD COLUMN play_count INT DEFAULT 0 CHECK (play_count >= 0);

ALTER TABLE playlists 
ADD COLUMN cover_url TEXT;
