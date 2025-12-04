CREATE TABLE IF NOT EXISTS `Songs` (
	`song_id` BIGINT NOT NULL AUTO_INCREMENT UNIQUE,
	`song_title` VARCHAR(255) NOT NULL,
	`artist_id` BIGINT NOT NULL,
	`genre_id` BIGINT NOT NULL,
	`popularity` INTEGER NOT NULL,
	PRIMARY KEY(`song_id`)
);


CREATE TABLE IF NOT EXISTS `Artists` (
	`artist_id` BIGINT,
	`artist_name` VARCHAR(255) NOT NULL,
	`song_id` BIGINT NOT NULL,
	PRIMARY KEY(`artist_id`)
);


CREATE TABLE IF NOT EXISTS `Audio_Features` (
	`song_id` BIGINT NOT NULL AUTO_INCREMENT UNIQUE,
	`energy` FLOAT NOT NULL,
	`danceability` FLOAT NOT NULL,
	`valence` FLOAT NOT NULL,
	`loudness` FLOAT NOT NULL,
	`bpm` FLOAT NOT NULL,
	`length_ms` INTEGER NOT NULL,
	`acousticness` FLOAT NOT NULL,
	`speechiness` FLOAT NOT NULL,
	`liveness` FLOAT NOT NULL,
	PRIMARY KEY(`song_id`)
);


CREATE TABLE IF NOT EXISTS `Genre` (
	`genre_id` BIGINT NOT NULL,
	`genre_name` VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(`genre_id`)
);


ALTER TABLE `Songs`
ADD FOREIGN KEY(`artist_id`) REFERENCES `Artists`(`artist_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Songs`
ADD FOREIGN KEY(`genre_id`) REFERENCES `Genre`(`genre_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `Audio_Features`
ADD FOREIGN KEY(`song_id`) REFERENCES `Songs`(`song_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;