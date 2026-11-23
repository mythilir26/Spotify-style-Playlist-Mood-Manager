# Spotify-style-Playlist-Mood-Manager
​A Spotify-style Playlist &amp; Mood Manager DBMS mini-project built with PostgreSQL and Supabase, featuring normalized relational schemas, mood-based indexing, and automated playlist management.

# 🎵 Spotify-Style Playlist & Mood Manager (DBMS Mini-Project)

A relational Database Management System (DBMS) modeled after Spotify's playlist and mood-based recommendation features. Built on **PostgreSQL** and hosted on **Supabase**, this project demonstrates normalized relational schema design, data integrity constraints, performance indexing, CRUD operations, and complex SQL analytics.

---

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Database Schema & Architecture](#-database-schema--architecture)
- [Core DBMS Features](#-core-dbms-features)
- [Setup & Execution Guide](#-setup--execution-guide)
- [Sample Queries & Use Cases](#-sample-queries--use-cases)
- [Team Contributions](#-team-contributions)

---

## 🎯 Project Overview
Modern music streaming platforms rely heavily on metadata tagging (mood, genre, tempo) to curate dynamic user playlists. This project implements the backend database engine for such a platform, enabling:
- User account and subscription management (`Free`, `Premium`, `Student`).
- Comprehensive song cataloging with strict validation on genres, moods, durations, and release years.
- Custom playlist creation matched to target moods (`Happy`, `Sad`, `Chill`, `Energetic`, `Focus`, `Workout`, `Romantic`, `Mixed`).
- Many-to-many playlist-to-song mapping with track ordering and cascading deletions.
- Analytical reporting on user listening habits, top moods, and playlist durations.

---

## 🛠️ Tech Stack
- **Database Engine:** PostgreSQL 15+
- **Cloud Hosting & BaaS:** [Supabase](https://supabase.com/)
- **Version Control:** Git & GitHub
- **ER Modeling:** Supabase Schema Visualizer

---

## 🗂️ Repository Structure

```text
├── database/
│   ├── schema.sql       # DDL: Database setup, 4 normalized tables, constraints, indexes, and ALTER updates
│   ├── seed.sql         # DML: Realistic sample records for users, songs, playlists, and mappings
│   └── queries.sql      # DQL & PL/pgSQL: Joins, aggregations, subqueries, views, and triggers
├── docs/
│   └── er_diagram.png   # Entity-Relationship (ER) diagram exported from Supabase
└── README.md            # Project documentation
```

---

## 🏗️ Database Schema & Architecture

The database is normalized up to **Third Normal Form (3NF)** to eliminate redundancy and ensure update/deletion anomalies are prevented.

### 1. `users`
Stores platform user profiles and subscription plans.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | `SERIAL` | `PRIMARY KEY` | Unique identifier for each user |
| `username` | `VARCHAR(50)` | `NOT NULL`, `UNIQUE` | User's display handle |
| `email` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Registered email address |
| `subscription_tier` | `VARCHAR(20)` | `DEFAULT 'Free'`, `CHECK` | Allowed: `'Free'`, `'Premium'`, `'Student'` |
| `created_at` | `TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` | Account creation timestamp |

### 2. `songs`
Master catalog of tracks tagged with mood and genre metadata.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `song_id` | `SERIAL` | `PRIMARY KEY` | Unique identifier for each song |
| `title` | `VARCHAR(150)` | `NOT NULL` | Track title |
| `artist` | `VARCHAR(100)` | `NOT NULL` | Performing artist or band |
| `album` | `VARCHAR(100)` | *Nullable* | Album name |
| `genre` | `VARCHAR(50)` | `NOT NULL` | Music genre (e.g., Pop, Lo-Fi, Rock) |
| `mood` | `VARCHAR(50)` | `NOT NULL`, `CHECK` | Allowed: `'Happy'`, `'Sad'`, `'Chill'`, `'Energetic'`, `'Focus'`, `'Workout'`, `'Romantic'` |
| `duration_sec` | `INT` | `NOT NULL`, `CHECK (> 0)` | Track length in seconds |
| `release_year` | `INT` | `CHECK (1900 - 2026)` | Year of release |
| `play_count` | `INT` | `DEFAULT 0`, `CHECK (>= 0)` | Total stream count *(added via `ALTER TABLE`)* |

### 3. `playlists`
User-curated playlists designed around specific target moods.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `playlist_id` | `SERIAL` | `PRIMARY KEY` | Unique identifier for each playlist |
| `user_id` | `INT` | `NOT NULL`, `FOREIGN KEY` | References `users(user_id)` (`ON DELETE CASCADE`) |
| `playlist_name` | `VARCHAR(100)` | `NOT NULL` | Name of the playlist |
| `target_mood` | `VARCHAR(50)` | `CHECK` | Intended mood (`'Happy'`, `'Sad'`, ..., `'Mixed'`) |
| `is_public` | `BOOLEAN` | `DEFAULT TRUE` | Public visibility toggle |
| `created_at` | `TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` | Playlist creation timestamp |
| `cover_url` | `TEXT` | *Nullable* | Playlist cover image link *(added via `ALTER TABLE`)* |

### 4. `playlist_songs` (Junction Table)
Resolves the **Many-to-Many (M:N)** relationship between `playlists` and `songs`.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `playlist_id` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | References `playlists(playlist_id)` (`ON DELETE CASCADE`) |
| `song_id` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | References `songs(song_id)` (`ON DELETE CASCADE`) |
| `added_at` | `TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` | Timestamp when track was added |
| `track_order` | `INT` | `CHECK (> 0)` | Position of the song inside the playlist |

---

## ⚙️ Core DBMS Features

- **Referential Integrity (`ON DELETE CASCADE`):** Deleting a user automatically removes their playlists and playlist-song mappings; deleting a song cleanly removes it from all user playlists without leaving orphaned records.
- **Domain & Entity Integrity:** Enforced using `PRIMARY KEY`, composite keys, `UNIQUE` constraints, `NOT NULL`, and strict `CHECK` conditions.
- **Performance Optimization (`CREATE INDEX`):** B-Tree indexes created on high-frequency lookup and join columns:
  - `idx_songs_genre` on `songs(genre)`
  - `idx_songs_mood` on `songs(mood)`
  - `idx_playlists_target_mood` on `playlists(target_mood)`
  - `idx_playlists_user_id` on `playlists(user_id)`
- **Non-Destructive Schema Evolution (`ALTER TABLE`):** Additional columns (`play_count`, `cover_url`) appended modularly without dropping existing production data.

---

## 🚀 Setup & Execution Guide

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/spotify-mood-manager-dbms.git
   cd spotify-mood-manager-dbms
   ```
2. **Initialize Supabase:**
   - Log in to [Supabase](https://supabase.com/) and create a new project.
   - Navigate to the **SQL Editor** in the left sidebar.
3. **Execute Scripts in Order:**
   - **Step 1:** Copy and run `database/schema.sql` to build tables, constraints, indexes, and `ALTER` updates.
   - **Step 2:** Copy and run `database/seed.sql` to populate test users, songs, and playlists.
   - **Step 3:** Copy and run `database/queries.sql` to execute analytical queries, views, and triggers.
4. **Inspect Schema:**
   - Open **Database > Schema Visualizer** in Supabase to view the live ER diagram.

---

## 📊 Sample Queries & Use Cases

- **Mood-Based Song Discovery:** Filter all tracks matching a specific mood (`Workout` or `Focus`) sorted by popularity (`play_count`).
- **Playlist Duration Calculation:** Use `JOIN` and `SUM(duration_sec)` to compute total runtime per playlist.
- **Mood Mismatch Detection:** Identify songs inside a playlist whose `mood` differs from the playlist's `target_mood`.
- **User Engagement Summary:** Aggregate total playlists and tracks curated per user tier (`Free` vs. `Premium`).

---

## 👥 Team Contributions

| Member | Role & Responsibilities | Deliverable File |
| :--- | :--- | :--- |
| **Member 1** | GitHub & Supabase Setup, ER Design, 4-Table Schema, Constraints (`PK`, `FK`, `CHECK`, `UNIQUE`, `CASCADE`), Indexes & `ALTER` fixes | `database/schema.sql` |
| **Member 2** | Sample Dataset Creation, `INSERT`/`UPDATE`/`DELETE` Operations & Constraint Testing | `database/seed.sql` |
| **Member 3** | Complex Joins, Aggregations, Subqueries, Database Views & Triggers | `database/queries.sql` |

