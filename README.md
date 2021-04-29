# Earthquake_analysis - An EEE 415 (FUTA) project
A group analysis of historic earthquake data

The queries are in MySQL syntax to extract insightful information from the given data.
The data is included in csv format.

## Overview
Earthquakes are natural vibrations caused by sudden movements in the Earth’s crust, the Earth’s thin outer layer. 

### Causes of earthquakes 
- Natural causes (earthquake)
-	Nuclear explosion
-	Explosion

### Tables created to enhance analysis
- DISTINCT PLACE TABLE: A table of all distinct places with 1 or more earthquake occurrences from the data provided.
```
DROP TABLE IF EXISTS places_table;
CREATE TABLE places_table
AS
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Places_id, 
place AS Place, 
COUNT(place) AS Earthquake_count,
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis GROUP BY(place);
```
- EARTHQUAKES BY DECADE: A table of earthquakes classified by the decade they occurred.
```
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
```
- EARTHQUAKES BY YEAR: A table of earthquakes classified by the year they occurred.
```
DROP TABLE IF EXISTS years_table;
CREATE TABLE years_table
AS
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Year_id,
EXTRACT(YEAR FROM occurred_on) AS Years, 
COUNT(EXTRACT(YEAR FROM occurred_on)) AS Earthquake_count,
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis
GROUP BY EXTRACT(YEAR FROM occurred_on); 
```
- EARTHQUAKES BY MONTH: A table of earthquakes classified by the month they occurred.
```
DROP TABLE IF EXISTS months_table;
CREATE TABLE months_table
AS
SELECT 
EXTRACT(MONTH FROM occurred_on), 
COUNT(EXTRACT(MONTH FROM occurred_on)) AS Earthquake_count, 
MAX(magnitude), MIN(magnitude), MAX(depth), MIN(depth)
FROM earthquake_analysis
GROUP BY EXTRACT(MONTH FROM occurred_on);
```
- EARTHQUAKES BY HOUR: A table of earthquakes classified by the hour of the day they occurred.
```
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
```

- EARTHQUAKES BY MAGNITUDE RANGE: A table of earthquakes classified by the magnitude range.
```
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
```

#### These tables will us allow us to ask interesting questions like:
- Does the time of the day affect the magnitude of earthquakes?
- Which decade experienced the most number of earthquakes?
- Do they vary with phenomena like climate change?
- Are earthquakes seasonal?
- How does the frequency of earthquakes in a place vary with magnitude? (Does high frequency of earthquakes in a location infer low magnitudes)


Thanks _Dr. Sam Olukotun_ for the lectures on SQL
