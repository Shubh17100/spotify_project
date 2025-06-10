Select * from spotify;

-- 1.List all tracks by "50 Cent".
		Select track, COUNT(TRACK) from spotify 
		GROUP BY 1
		ORDER BY 2 DESC;

-- 2. Show track names and their duration (in minutes) for "Gorillaz".
		Select track, duration_min from spotify 
		where channel = 'Gorillaz';

-- 3. Retrieve all songs that have energy greater than 0.8.
		Select track, energy from spotify 
		where energy > 0.8;

-- WHERE, ORDER BY, LIMIT

-- 4. Get the top 5 songs with the highest tempo.
		Select track, tempo from spotify 
		order by tempo desc
		limit 5;
		
-- 5. Find the track with the lowest loudness.
		Select track, loudness from spotify
		order by loudness 
		limit 10;

-- 6. Show all tracks where valence is between 0.4 and 0.6.
		Select track, valence from spotify 
		where valence between 0.4 and 0.6;

-- Aggregation Functions (AVG, MAX, MIN, COUNT)

-- 7. Find the average tempo of all songs.
		Select avg(tempo) as avg_tempo from spotify;

-- 8. Count how many songs are from the album "Stadium Arcadium".
		Select track, count(track) from spotify
	    where album = 'Stadium Arcadium'
		group by track
		order by 2 desc;

-- 9. What is the maximum and minimum duration of songs by "Metallica"?
		Select 
			min(duration_min) as min_duration,
			max(duration_min) as max_duration
		from spotify
		where artist = 'Metallica';

-- GROUP BY

-- 10. Show average duration per artist.
		Select artist, avg(duration_min) avg_duration from spotify 
		group by 1
		order by 2 desc;

-- 11. Get count of songs per album.
		SELECT 
	    album,
	    COUNT(*) AS song_count
		FROM 
		    spotify
		GROUP BY 
		    album
		ORDER BY 
	    song_count DESC; 

-- 12. Calculate the average danceability for each artist.
		Select artist, avg(danceability) avg_danceability from spotify
		group by 1 
		order by 2;

-- 13. Find all songs where loudness is above -4 and energy is above 0.85.
		Select track, loudness, energy from spotify 
		where loudness > -4 and energy > 0.85;

-- 14. List the top 3 longest tracks by duration.
		Select track, duration_min from spotify
		order by 2 desc
		limit 3;

-- 15. Get all songs that are instrumentals (instrumentalness > 0.5).
		Select * from Spotify 
		where instrumentalness > 0.5;

-- 16. Rank all songs by duration within each artist.
		SELECT 
	    artist,
	    track,
	    duration_min,
	    RANK() OVER (PARTITION BY artist ORDER BY duration_min DESC) AS duration_rank
		FROM 
	    Spotify;

-- 17. Get the cumulative average duration for all songs ordered by tempo.
		SELECT
    track,
    artist,
    tempo,
    duration_min,
    AVG(duration_min) OVER (
        ORDER BY tempo
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_avg_duration
	FROM 
    Spotify;

-- 20. Add a column that labels songs as 'High Energy' if energy > 0.8, otherwise 'Low Energy'.
		Select track, 
		case
			when energy > 0.8 then 'High Energy' else 'Low Energy' end as songs_level 
		from spotify;
		
-- 21. Find the song with the 2nd highest energy for each artist.
		Select * from (Select artist,
		track, 
		energy,
		rank () over (
		partition by artist order by energy desc)
			as energy_rank
		from spotify ) ranked
		where energy_rank = 2;

-- 22. For each album, show songs and their duration rank.
		Select album,
		track, 
		duration_min,
		rank () over (partition by album order by duration_min desc) as duration_rank
		from spotify;

-- 23. Calculate a running total of duration ordered by tempo.
		Select artist, track, tempo, duration_min,
		sum(duration_min) over (order by tempo 
		rows between unbounded preceding and current row) as running_total_duration 
		from spotify;
		
-- 24. Show average energy for each artist, then compare each song's energy to that average.
		SELECT 
    s.artist,
    s.track,
    s.energy,
    artist_avg.avg_energy,
    s.energy - artist_avg.avg_energy AS energy_difference
	FROM 
	    Spotify s
	JOIN (
	    SELECT 
	        artist,
	        AVG(energy) AS avg_energy
	    FROM Spotify
	    GROUP BY artist
	) artist_avg ON s.artist = artist_avg.artist;

-- 25. Use a CTE to first filter songs with loudness above average, then rank them by duration.
		With Loudsong as
			(Select * from spotify 
			where loudness > (select avg(loudness) avg_loudness from spotify)
			)
		Select artist, track, duration_min, 
		rank() over (order by duration_min desc) as duration_rank 
		from Loudsong;

-- 26. Create a CTE that groups songs by album and returns albums with average duration > 4 minutes.
		WITH AlbumAvgDuration AS (
    SELECT 
        album,
        AVG(duration_min) AS avg_duration
    FROM Spotify
		    GROUP BY album
		)
		SELECT 
		    album,
		    avg_duration
		FROM 
		    AlbumAvgDuration
		WHERE 
		    avg_duration > 4;

-- 27. Find songs where tempo is higher than the average tempo of the same artist using a CTE.
		WITH ArtistTempoAvg AS (
    SELECT 
        artist,
        AVG(tempo) AS avg_tempo
    FROM Spotify
    GROUP BY artist
		)
		SELECT 
		    s.artist,
		    s.track,
		    s.tempo,
		    a.avg_tempo
		FROM 
		    Spotify s
		JOIN 
		    ArtistTempoAvg a ON s.artist = a.artist
		WHERE 
		    s.tempo > a.avg_tempo;

-- 28. Find all songs with duration greater than the average duration of all songs.
				SELECT 
		    track,
		    artist,
		    duration_min
		FROM 
		    Spotify
		WHERE 
		    duration_min > (
		        SELECT AVG(duration_min) FROM Spotify
		    );

-- 29. List the top 3 longest songs for each artist using a subquery with ROW_NUMBER().
		SELECT *
	FROM (
	    SELECT 
	        artist,
	        track,
	        duration_min,
	        ROW_NUMBER() OVER (PARTITION BY artist ORDER BY duration_min DESC) AS rn
	    FROM Spotify
	) ranked
	WHERE rn <= 3;

-- 30. Find songs with valence above the median valence (use percentile logic or subquery if supported).
		WITH MedianValence AS (
    	SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY valence) AS median_valence
		    FROM Spotify
		)
		SELECT 
		    s.track,
		    s.artist,
		    s.valence
		FROM 
		    Spotify s,
		    MedianValence mv
		WHERE 
		    s.valence > mv.median_valence;

-- 31. Classify songs as ‘Happy’, ‘Neutral’, or ‘Sad’ using valence.
		SELECT 
    track,
    artist,
    valence,
    CASE 
        WHEN valence > 0.65 THEN 'Happy'
        WHEN valence BETWEEN 0.4 AND 0.65 THEN 'Neutral'
        ELSE 'Sad'
    END AS mood
FROM 
    Spotify;


-- 32. Group songs into ‘Slow’, ‘Moderate’, and ‘Fast’ based on tempo ranges.
		SELECT 
    track,
    artist,
    tempo,
    CASE 
        WHEN tempo < 90 THEN 'Slow'
        WHEN tempo BETWEEN 90 AND 120 THEN 'Moderate'
        ELSE 'Fast'
    END AS tempo_category
FROM 
    Spotify;


		
		
		
		
				

		