CREATE DATABASE spotify_project;

USE spotify_project;

CREATE TABLE IF NOT EXISTS `Songs` (
	`song_id` BIGINT NOT NULL AUTO_INCREMENT UNIQUE,
	`genre_id` BIGINT NOT NULL,
	`artist_id` BIGINT NOT NULL,
	`song_title` VARCHAR(255) NOT NULL,
	`bpm` INTEGER NOT NULL,
	`energy` INTEGER NOT NULL,
	`danceability` INTEGER NOT NULL,
	`loudness` INTEGER NOT NULL,
	`liveness` INTEGER NOT NULL,
	`valence` INTEGER NOT NULL,
	`length_ms` INTEGER NOT NULL,
	`accousticness` INTEGER NOT NULL,
	`speechiness` INTEGER NOT NULL,
	`popularity` INTEGER NOT NULL,
	`collaboration` BOOLEAN NOT NULL,
	PRIMARY KEY(`song_id`)
);


CREATE TABLE IF NOT EXISTS `Artists` (
	`artist_id` BIGINT NOT NULL AUTO_INCREMENT UNIQUE,
	`artist_name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`artist_id`)
);


CREATE TABLE IF NOT EXISTS `Genre` (
	`genre_id` BIGINT NOT NULL AUTO_INCREMENT UNIQUE,
	`genre_name` VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(`genre_id`)
);


ALTER TABLE `Songs`
ADD FOREIGN KEY(`artist_id`) REFERENCES `Artists`(`artist_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Songs`
ADD FOREIGN KEY(`genre_id`) REFERENCES `Genre`(`genre_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

SELECT 
    (SELECT COUNT(*) FROM Genre) as nb_genres,
    (SELECT COUNT(*) FROM Artists) as nb_artists,
    (SELECT COUNT(*) FROM Songs) as nb_songs;


SELECT 
    s.song_title,
    a.artist_name,
    g.genre_name,
    s.popularity,
    s.collaboration,
    s.energy
FROM Songs s
JOIN Artists a ON s.artist_id = a.artist_id
JOIN Genre g ON s.genre_id = g.genre_id
ORDER BY s.popularity DESC
LIMIT 20;

-- View Songs_With_Position
CREATE OR REPLACE VIEW Songs_With_Position AS
SELECT 
    s.*,
    a.artist_name,
    g.genre_name,
    ROW_NUMBER() OVER (ORDER BY s.popularity DESC) as chart_position
FROM Songs s
JOIN Artists a ON s.artist_id = a.artist_id
JOIN Genre g ON s.genre_id = g.genre_id;

SELECT song_title, popularity, chart_position 
FROM Songs_With_Position 
ORDER BY chart_position 
LIMIT 10;

SELECT * FROM Songs;
SELECT * FROM Artists;

DESCRIBE Songs;
ALTER TABLE Songs 
ADD COLUMN song_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

DESCRIBE Songs;
SELECT * FROM Genre;

-- EXPLORATORY ANALYSIS
-- ==================================================================================
-- Top 10 LEAST Popular Songs

SELECT song_title, popularity
FROM Songs
ORDER BY popularity ASC
LIMIT 10;
-- The songs with lower popularity scores (typically 70-85).

-- Top 10 Most Popular Songs
SELECT song_title, popularity
FROM Songs
ORDER BY popularity DESC
LIMIT 10;
-- Identifies the songs with the highest popularity scores (90+).

-- JOINING SONGS AND ARTISTS
SELECT  
    s.song_title, 
    s.popularity, 
    a.artist_name 
FROM Songs s 
JOIN Artists a ON s.artist_id = a.artist_id 
ORDER BY s.popularity DESC 
LIMIT 10;
-- Replaces numeric artist_id with actual artist names.

-- JOIN Songs + Artists + Genre
SELECT  
    s.song_title, 
    s.popularity, 
    a.artist_name,
    g.genre_name,
    s.energy,
    s.danceability
FROM Songs s 
JOIN Artists a ON s.artist_id = a.artist_id 
JOIN Genre g ON s.genre_id = g.genre_id
ORDER BY s.popularity DESC 
LIMIT 10;

-- Popularity Statistics
SELECT
	ROUND(AVG(popularity), 2) as popularity_mean,
    MIN(popularity) as min_popularity,
    MAX(popularity) as max_popularity,
    ROUND(stddev(popularity), 2) as standard_deviation,
    COUNT(*) total_songs
FROM Songs;
-- The Top 50 songs of 2019 show a relatively tight distribution of popularity scores, with an average of 87.50 and a standard deviation of only 4.45. 
-- This low variability indicates that songs in the Top 50 are fairly homogeneous in terms of their success metrics, with 68% of songs falling between 83 and 92 in popularity. 
-- The range spans from 70 (position 50) to 95 (position 1), representing a 25-point spread. 
-- This narrow distribution suggests that even small differences in musical characteristics between the Top 10 and positions 40-50 may be meaningful indicators of what elevates a song from a moderate hit to a mega hit.

-- Statistics on All Musical Features
SELECT
 ROUND(AVG(energy), 2) as avg_energy,
 ROUND(AVG(danceability), 2) as avg_danceability,
 ROUND(AVG(loudness), 2) as avg_loudness,
 ROUND(AVG(liveness), 2) as avg_liveness,
 ROUND(AVG(valence), 2) as avg_valence,
 ROUND(AVG(length_ms), 2) as avg_duration,
 ROUND(AVG(bpm), 2) as avg_bpm,
 ROUND(AVG(accousticness), 2) as avg_accousticness,
 ROUND(AVG(speechiness), 2) as avg_speechiness
FROM Songs;
 -- The average Top 50 song in 2019 exhibits several consistent characteristics: high danceability (71.38), moderate energy (64.06), very loud mastering (-5.66 dB), and predominantly electronic production (acousticness: 22.16). 
 -- With an average tempo of 120 BPM and neutral valence (54.60), these songs strike a balance between being energetic enough to capture attention while remaining accessible to broad audiences. 
--  The low liveness score (14.66) confirms these are studio-polished productions rather than live recordings, reflecting modern streaming platform standards. 
 -- Notably, high danceability and competitive loudness emerge as defining features of commercial success..
 
-- Number of Songs per Genre
SELECT
    g.genre_name,
    COUNT(s.song_id) as songs_count
FROM Genre g
LEFT JOIN Songs s ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY songs_count DESC;
-- Pop dominates the Top 50 in 2019

-- Average Popularity by Genre
SELECT
	g.genre_name,
    COUNT(*) as songs_count,
    ROUND(AVG(s.popularity), 2) as popularity_mean,
    ROUND(AVG(s.energy), 2) AS energy_mean,
    MIN(popularity) as min_popularity,
    MAX(popularity) as max_popularity
FROM Songs s
JOIN Genre g ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY popularity_mean DESC;
-- Insight: Genre distribution: Pop quantity vs Rap/Latin quality
-- While pop dominates by volume, rap and Latin genres deliver higher average quality. 
-- Pop's large presence masks its inconsistency - it includes both the #1 song (95) and many moderate hits (70-85). 
-- Rap shows the highest "hit rate" - when rap reaches Top 50, it performs exceptionally well (88-92 range). 
-- Latin represents the best of both worlds: significant presence (20%) with high quality (89.40 avg).

-- Comparison collab vs single
SELECT
	CASE WHEN collaboration = 1 THEN 'Collaboration' ELSE 'Single' END as type,
	COUNT(*) as songs_count,
    ROUND(AVG(popularity), 2) as popularity_mean,
    ROUND(AVG(energy), 2) AS energy_mean,
    ROUND(AVG(danceability), 2) as avg_danceability
FROM Songs
GROUP BY Collaboration;
-- INSIGHT: Singles are MORE popular than collaborations by +1.47 points
-- Collaborations have higher energy (+4.09) and danceability (+2.36)

-- SONGS BY POPULARITY LEVEL

SELECT
	song_title,
    popularity,
    CASE	
		WHEN popularity >= 90 THEN 'Very popular'
        WHEN popularity >= 85 THEN 'popular'
        ELSE 'Less popular'
	END as popularity_level
FROM Songs
ORDER BY popularity DESC;

-- Loudness Impact on Popularity
SELECT
    CASE	
		WHEN loudness >= -5 THEN 'high loudness'
        WHEN loudness >= -7 THEN 'Loud'
        ELSE 'Low loudness'
	END as loudness_level,
    COUNT(*) as songs_count,
    ROUND(AVG(popularity), 2) as popularity_mean
FROM Songs
GROUP BY 
	CASE
		WHEN loudness >= -5 THEN 'high loudness'
        WHEN loudness >= -7 THEN 'Loud'
        ELSE 'Low loudness'
	END
ORDER BY popularity_mean DESC;

-- INSIGHTS

-- Observation 1: Low loudness songs have slightly higher popularity (87.86)
-- But the difference is minimal (0.11 points vs high loudness), With only 7 songs in this category, this could be random variation

-- Observation 2: Most songs (24 out of 50) are in "high loudness" category
-- This suggests loud production is the industry standard, But it doesn't guarantee higher popularity

-- Observation 3: The "Loud" middle category has lowest popularity (87.05)
-- But again, less than 1 point difference, Not meaningful

-- So, Loudness is NOT a key factor for chart success
