USE MMH_Data;


-- Exploratory Analysis

-- Investigate streaming service impact on listening habits and mental health
-- Listening average based on streaming service
SELECT Primary_streaming_service, AVG(Hours_per_day) AS AvgHoursPerDay
FROM survey_results    
WHERE Primary_streaming_service <> ''
GROUP BY Primary_streaming_service;




-- Max,Min,Avg hours listened by age
SELECT 
	Age, 
    MAX(Hours_per_day) AS Max_hrs, 
    MIN(Hours_per_day) AS Min_hrs, 
    AVG(Hours_per_day) AS Avg_hrs, 
    COUNT(Hours_per_day) AS num_srvy_in_age_group
FROM survey_results
GROUP BY Age
ORDER BY 1;
-- There is a uneven spread in survey data accoring to age, which may lead to biases in the overall findings

-- Temp Table: Create a temp table with age category groupings to perform a more balanced analysis over generational listening groups. 
CREATE TEMPORARY TABLE TempAgeGroup AS
SELECT *, 
    CASE
		WHEN Age >= 10 AND Age <= 17 THEN 'Children'
        WHEN Age >= 18 AND Age <= 20 THEN 'Teen'
        WHEN Age >= 21 AND Age <= 25 THEN 'Young_Adult'
        WHEN Age >= 26 AND Age <= 35 THEN 'Adult'
        WHEN Age >35 THEN 'Older'
        ELSE 'Unknown'
	END AS Age_group
FROM survey_results;
SELECT * FROM TempAgeGroup;

-- Check category total counts for each age group defined
SELECT 
	Age_group, 
    COUNT(*) AS Srvy_count
FROM TempAgeGroup
WHERE Primary_streaming_service <> ''
GROUP BY Age_group;

-- Window Function: Calculate %'s of each age range that use each respective platform, and what % of each platforms total users are in the given age range. 
SELECT 
	Primary_streaming_service, 
	Age_group, 
    COUNT(*) AS Count_of_Age_on_platform, 
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Age_group) AS '%_of_Age_on_platform',
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Primary_streaming_service) AS '%_of_platform_total'
FROM TempAgeGroup
WHERE Primary_streaming_service <> '' 
GROUP BY 1, Age_group
ORDER BY 1,4 DESC;

-- Avg Mental Health scores for each platform
SELECT 
	Primary_streaming_service,
    AVG(Anxiety) AS avg_anxiety,
    AVG(Depression) AS avg_depression,
    AVG(Insomnia) AS avg_insomnia,
    AVG(OCD) AS avg_OCD
FROM TempAgeGroup
WHERE Primary_streaming_service <> ''
GROUP BY Primary_streaming_service;

-- Avg Mental Health scores for each Age Group
SELECT 
	Age_group,
    AVG(Anxiety) AS avg_anxiety,
    AVG(Depression) AS avg_depression,
    AVG(Insomnia) AS avg_insomnia,
    AVG(OCD) AS avg_OCD
FROM TempAgeGroup
GROUP BY Age_group;


-- Similar to above age groupings, group listeners by common BPM groupings
CREATE TEMPORARY TABLE TempBPMTable AS
SELECT *, 
    CASE
		WHEN BPM <= 80 THEN 'Very_Slow'
        WHEN BPM >= 81 AND BPM <= 108 THEN 'Slow'
        WHEN BPM >= 109 AND BPM <= 120 THEN 'Moderate'
        WHEN BPM >= 121 AND BPM <= 150 THEN 'Fast'
        WHEN BPM >151 THEN 'Very_Fast'
        ELSE 'Unknown'
	END AS BPM_group
FROM survey_results;
SELECT * FROM TempBPMTable;

-- Check distribution count of groupings
SELECT 
	BPM_group, 
    COUNT(*) AS Srvy_count
FROM TempBPMTable
WHERE BPM <> ''
GROUP BY BPM_group;


-- Avg Mental Health scores for BPM grouping
SELECT 
	BPM_group,
    AVG(Anxiety) AS avg_anxiety,
    AVG(Depression) AS avg_depression,
    AVG(Insomnia) AS avg_insomnia,
    AVG(OCD) AS avg_OCD
FROM TempBPMTable
GROUP BY BPM_group
ORDER BY FIELD(BPM_group, 'Very_Slow', 'Slow', 'Moderate', 'Fast', 'Very_Fast')DESC;



-- Avg Mental Health scores for each favorite genre category
SELECT 
	Fav_genre,
    AVG(Anxiety) AS avg_anxiety,
    AVG(Depression) AS avg_depression,
    AVG(Insomnia) AS avg_insomnia,
    AVG(OCD) AS avg_OCD,
    COUNT(*) AS count_group
FROM TempBPMTable
GROUP BY Fav_genre;

-- Effects of exploratory listening habits on MH scores
SELECT
	Exploratory,
    AVG(Anxiety) AS avg_anxiety,
    AVG(Depression) AS avg_depression,
    AVG(Insomnia) AS avg_insomnia,
    AVG(OCD) AS avg_OCD,
    COUNT(*) AS count_group
FROM TempBPMTable
WHERE Exploratory <>''
GROUP BY 1;

-- Effects of listening while working on MH scores
SELECT
	While_working,
    AVG(Anxiety) AS avg_anxiety,
    AVG(Depression) AS avg_depression,
    AVG(Insomnia) AS avg_insomnia,
    AVG(OCD) AS avg_OCD,
    COUNT(*) AS count_group
FROM TempBPMTable
WHERE While_working <>''
GROUP BY 1;


-- Favorite category for high MH scoring responses
SELECT 
	Fav_genre,COUNT(*) AS count
FROM survey_results
WHERE 
	Anxiety > 6 AND 
    Insomnia > 6 AND
    Depression > 6 AND
    OCD > 6
GROUP BY Fav_genre
ORDER BY 2 DESC;
