USE spotify_project;

SELECT *
FROM artists;

SELECT *
FROM genre;

SELECT *
FROM songs;


-- Basic calculations
SELECT 
	ROUND(AVG(popularity), 2) AS avg_popularity,
    ROUND(AVG(bpm), 2) AS avg_bpm,
    ROUND(AVG(energy), 2) AS avg_energy,
    ROUND(AVG(danceability), 2) AS avg_danceabilty,
    ROUND(AVG(loudness), 2) AS avg_loudness,
    ROUND(AVG(liveness), 2) AS avg_liveness,
    ROUND(AVG(valence), 2) AS avg_valence,
    ROUND(AVG(length_ms), 2) AS avg_length_ms,
    ROUND(AVG(accousticness), 2) AS avg_accousticness,
    ROUND(AVG(speechiness), 2) AS avg_speechiness
FROM songs;
    
    -- Outcome: avg_popularity: 87.50
    -- 			avg_bpm: 120:06
    -- 			avg_energy: 64.06
	-- 			avg_danceabilty: 71.38
    -- 			avg_loudness: -5.66
	-- 			avg_liveness: 14.66
	-- 			avg_valence: 54.60
	-- 			avg_length_ms: 200.96
    -- 			avg_accousticness: 22.26
	-- 			avg_speechiness: 12.48


-- Hypothesis
-- 1. Top 20 songs have significantly higher energy and danceability than positions 21-50
	-- Comparing the averages for top 20 songs - 30/50

SELECT 
    CASE 
        WHEN song_id BETWEEN 1 AND 20 THEN 'Top 20'
        WHEN song_id BETWEEN 21 AND 50 THEN '21-50'
    END AS group_label,
    AVG(energy) AS avg_energy,
    AVG(danceability) AS avg_danceability,
    COUNT(*) AS num_songs
FROM songs
WHERE song_id BETWEEN 1 AND 20 
   OR song_id BETWEEN 21 AND 50
GROUP BY group_label;

	-- Checking if the differences are statistcally significant
SELECT 
    (SELECT AVG(energy) 
     FROM songs WHERE song_id BETWEEN 1 AND 20) -
    (SELECT AVG(energy) 
     FROM songs WHERE song_id BETWEEN 21 AND 50)
     AS diff_energy;
     -- Outcome: 1.0091
     
SELECT 
    (SELECT AVG(danceability) 
     FROM songs WHERE song_id BETWEEN 1 AND 20) -
    (SELECT AVG(danceability) 
     FROM songs WHERE song_id BETWEEN 21 AND 50)
     AS diff_danceability;
     -- Outcome: -4.7455
	
-- Actually it does not support our hypothesis. Songs in position 40-50 have higher danceability than top 10.
-- High danceability is not a key factor for reaching the top positions.

-- 2. Top 10 songs have more positive mood (valence) than lower-ranked songs
SELECT 
    CASE 
        WHEN song_id BETWEEN 1 AND 20 THEN 'Top 20'
        WHEN song_id BETWEEN 21 AND 50 THEN '21-50'
    END AS rank_group,
    AVG(valence) AS avg_valence,
    COUNT(*) AS num_songs
FROM songs
WHERE song_id BETWEEN 1 AND 20
   OR song_id BETWEEN 21 AND 50
GROUP BY rank_group; 

SELECT 
    (SELECT AVG(valence) FROM songs WHERE song_id BETWEEN 1 AND 20) - 
    (SELECT AVG(valence) FROM songs WHERE song_id BETWEEN 21 AND 50) AS valence_diff;
	-- Outcome: -2.7182
    
    -- We have a lower valence in the Top 10 --> Our hypothesis is not supported; mood may not be the driving factor.

-- 3. Certain genres dominate the Top 10 while others appear only in lower positions
SELECT 
    g.genre_name,
    SUM(CASE WHEN s.song_id BETWEEN 1 AND 20 THEN 1 ELSE 0 END) AS 'Top 20',
    SUM(CASE WHEN s.song_id BETWEEN 21 AND 50 THEN 1 ELSE 0 END) AS '40-50'
FROM songs AS s
INNER JOIN genre AS g
    ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY 'Top 20' DESC;

	-- Outcome: Genres in the 'Top 10' are latin (1), pop (6), rap (3)
    -- 			In 40-50 position are edm (4), latin (2), pop (5)


-- 3.1 Which is the most popular genre? 
SELECT 
    g.genre_name,
    COUNT(s.song_id) AS num_songs,
    AVG(s.popularity) AS avg_popularity
FROM songs AS s
INNER JOIN genre AS g
    ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY avg_popularity DESC;

	-- Outcome: rap with avg_popularity = 91

-- 2.2 The most popular genre with ranking
SELECT 
    g.genre_name,
    COUNT(s.song_id) AS num_songs,
    ROUND(AVG(s.popularity), 2) AS avg_popularity,
    RANK() OVER (ORDER BY AVG(s.popularity) DESC) AS popularity_rank
FROM songs AS s
INNER JOIN genre AS g
    ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY popularity_rank;

	-- Rap tracks that make it to the Top 50 are extremely popular individually, even if there aren’t many.
	-- Pop dominates in quantity, meaning it’s widely represented, but its songs are slightly less popular on average.

-- 4. Top 10 songs are louder than songs in positions 40-50
SELECT 
    CASE 
        WHEN song_id BETWEEN 1 AND 20 THEN 'Top 20'
        WHEN song_id BETWEEN 21 AND 50 THEN '21-50'
    END AS rank_group,
    AVG(loudness) AS avg_loudness,
    COUNT(*) AS num_songs
FROM songs
WHERE song_id BETWEEN 1 AND 20
   OR song_id BETWEEN 21 AND 50
GROUP BY rank_group;

SELECT 
    (SELECT AVG(loudness) FROM songs WHERE song_id BETWEEN 1 AND 20)
  - (SELECT AVG(loudness) FROM songs WHERE song_id BETWEEN 21 AND 50) AS loudness_diff;
  
	-- Outcome: -0.5364
    -- Hypothesis not supported: lower-ranked songs are louder

-- 5. Top 10 songs avoid extreme values (not too slow, not too long, not too acoustic)
SELECT 
    CASE 
        WHEN song_id BETWEEN 1 AND 20 THEN 'Top 20'
        ELSE '21-50'
    END AS rank_group,
    AVG(bpm) AS avg_bpm,
    MIN(bpm) AS min_bpm,
    MAX(bpm) AS max_bpm,
    AVG(length_ms) AS avg_length_ms,
    MIN(length_ms) AS min_length_ms,
    MAX(length_ms) AS max_length_ms,
    AVG(accousticness) AS avg_accousticness,
    MIN(accousticness) AS min_accousticness,
    MAX(accousticness) AS max_accousticness
FROM songs
WHERE song_id BETWEEN 1 AND 20 OR song_id BETWEEN 21 AND 50
GROUP BY rank_group;

	-- 	Outcome:

-- 6. Are collabs more popular?
SELECT 
    collaboration,
    COUNT(*) AS num_songs,
    AVG(popularity) AS avg_popularity,
    MIN(popularity) AS min_popularity,
    MAX(popularity) AS max_popularity
FROM songs
GROUP BY collaboration;

	-- 


     
