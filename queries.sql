-- THE BEGINING OF SCRIPT --

-- CREATE DATABASE Earthquake_analysis;
CREATE DATABASE Earthquake_example;

-- Select the Earthquake_analysis database to store our tables
USE Earthquake_example;

-- 0.2 Confirm type for columns
DESC earthquake_analysis;

-- Only use TRUNCATE command to delete records and keep table design
TRUNCATE TABLE earthquake_analysis;
TRUNCATE TABLE distinct_places_table;

-- 0.3 Set the local_infile to 'ON' for faster loading
SET GLOBAL local_infile = 'ON';

-- 0.4 Use the SHOW command to see that it is effected
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- 0.5. The better way to load heavy data in MySQL
LOAD DATA LOCAL INFILE 'C:/mysql/data/earthquake_new.csv' 
INTO TABLE earthquake_analysis
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(earthquake_id,@date_time_variable,latitude,longitude,depth,magnitude,
calculation_method,network_id,place,cause)
set occurred_on = str_to_date(@date_time_variable,'%d/%m/%Y %H:%i');


-- 0.6. Selecting all the data in the earthquake table
SELECT *   -- The asterisk (*) is used to indicate all data
FROM earthquake_analysis;

-- ##################################################

-- 1. Distinct places table
DROP TABLE IF EXISTS places_table;
CREATE TABLE places_table
AS
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Places_id, 
place AS Place, 
COUNT(place) AS Earthquake_count,
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis GROUP BY(place);

-- 2. Years Table
DROP TABLE IF EXISTS years_table;
CREATE TABLE years_table
AS
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Year_id,
EXTRACT(YEAR FROM occurred_on) AS Years, 
COUNT(EXTRACT(YEAR FROM occurred_on)) AS Earthquake_count,
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis
GROUP BY EXTRACT(YEAR FROM occurred_on); 

-- 3. Months Table
DROP TABLE IF EXISTS months_table;
CREATE TABLE months_table
AS
SELECT 
EXTRACT(MONTH FROM occurred_on), 
COUNT(EXTRACT(MONTH FROM occurred_on)) AS Earthquake_count, 
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis
GROUP BY EXTRACT(MONTH FROM occurred_on);

-- 4. Decades Table
DROP TABLE IF EXISTS decades_table;
CREATE TABLE decades_table
AS
SELECT CONCAT(SUBSTRING(occurred_on, 1, 3), 0) AS decade,
COUNT(CONCAT(SUBSTRING(occurred_on, 1, 3), 0)) AS Earthquake_count
FROM earthquake_analysis
GROUP BY decade;
SELECT 
CASE 
    WHEN decade = 1960 THEN '1969'
    WHEN decade = 1970 THEN '1970-1979'
    WHEN decade = 1980 THEN '1980-1989'
    WHEN decade = 1990 THEN '1990-1999'
    WHEN decade = 2000 THEN '2000-2009'
	WHEN decade = 2010 THEN '2010-2018'
    ELSE 'Undefined'
END
AS Decade
FROM decades_table;

-- 4. Times Table
DROP TABLE IF EXISTS times_table;
CREATE TABLE times_table
AS
SELECT
EXTRACT(HOUR FROM occurred_on) AS Hour, 
COUNT(EXTRACT(HOUR FROM occurred_on)) AS Earthquake_count,
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis
GROUP BY EXTRACT(HOUR FROM occurred_on)
ORDER BY HOUR; 

-- 5. Magnitude Table 
DROP TABLE IF EXISTS magnitudes_table;
CREATE TABLE magnitudes_table
AS
SELECT magnitude_range AS Magnitude_range, 
COUNT(*) AS Earthquake_count,
ROUND(AVG(magnitude), 2)AS Average, MAX(depth), MIN(depth)
FROM (
  SELECT 
  CASE  
    WHEN magnitude BETWEEN 5.0 AND 5.99 THEN '5.0 - 5.99'
    WHEN magnitude BETWEEN 6.0 AND 6.99 THEN '6.0 -6.99'
    WHEN magnitude BETWEEN 7.0 AND 7.99 THEN '7.0 - 7.99'
    WHEN magnitude BETWEEN 8.0 AND 8.99 THEN '8.0 - 8.99'
    WHEN magnitude BETWEEN 9.0 AND 9.99 THEN '9.0 - 9.99'
    ELSE magnitude 
  END 
  AS magnitude_range, magnitude, depth
  FROM earthquake_analysis) t
GROUP BY magnitude_range;


-- 6. Average Earthquake count per decade, per year, per month
SELECT * FROM
(SELECT AVG(Earthquake_count) AS Earthquake_count_per_decade
FROM decades_table) dt
CROSS JOIN
(SELECT AVG(Earthquake_count) AS Earthquake_count_per_year
FROM years_table) yt
CROSS JOIN
(SELECT AVG(Earthquake_count) AS Earthquake_count_per_month
FROM months_table) mt;


-- 7. Variance Earthquake count per decade, per year, per month 
SELECT * FROM
(SELECT VARIANCE(Earthquake_count) AS Earthquake_variance_per_decade
FROM decades_table) dt
CROSS JOIN
(SELECT VARIANCE(Earthquake_count) AS Earthquake_variance_per_year
FROM years_table) yt
CROSS JOIN
(SELECT VARIANCE(Earthquake_count) AS Earthquake_variance_per_month
FROM months_table) mt;


-- 8. Place with most frequent Eathquake
SELECT * 
FROM places_table
ORDER BY Earthquake_count DESC
LIMIT 1;


-- 9. Get Max and Min earthquakes, Max and Min depth and Earthquake count given a city
DROP PROCEDURE IF EXISTS GET_DATA_BY_CITY;  -- Drop the procedure if it already exists
-- change the delimiter so SQL doesn't try to run each line as you're trying to write the procedure.
DELIMITER ;;
CREATE PROCEDURE GET_DATA_BY_CITY( IN _place TEXT)
BEGIN
  SELECT *
  FROM places_table
  WHERE Place = _place;
END;
;;
DELIMITER ; -- Change back the delimitter
CALL GET_DATA_BY_CITY('Andreanof Islands, Aleutian Islands, Alaska'); -- CALL THE PROCEDURE


-- 10. Get Max Max and Min depth and Earthquake count for any give Earthquake magnitude range
DROP PROCEDURE IF EXISTS GET_DATA_BY_RANGE;
DELIMITER ;;
CREATE PROCEDURE GET_DATA_BY_RANGE( IN _min INT, IN _max INT)
BEGIN
  SELECT 
  COUNT(*) AS Earthquake_count,
  ROUND(AVG(magnitude), 2) AS Average, MAX(depth), MIN(depth)
  FROM (
	SELECT *
	FROM earthquake_analysis
    WHERE magnitude BETWEEN _min AND _max
  ) g;
END;
;;
DELIMITER ;
CALL GET_DATA_BY_RANGE(8,10); -- CALL THE PROCEDURE