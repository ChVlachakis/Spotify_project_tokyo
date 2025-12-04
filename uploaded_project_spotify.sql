CREATE DATABASE IF NOT EXISTS spotify;
USE spotify;

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

-- ================================================================== --

SELECT artist_id, artist_name FROM spotify.artists;



SELECT
    ROW_NUMBER() OVER (ORDER BY s.song_id) AS row_num,
    g.genre_name
FROM spotify_project.Songs AS s
JOIN spotify_project.Genre AS g
    ON s.genre_id = g.genre_id
ORDER BY row_num;

