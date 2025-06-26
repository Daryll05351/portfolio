
-- SQL Portfolio Project: Air Quality Data Analysis

-- This SQL script demonstrates fundamental and data transformation/manipulation clauses using simulated air quality datasets (annual summaries and daily CO data).

-- Table Names:
-- 1. annual_air_quality_data (from air_quality_annual_summary_dataset.csv)
-- 2. daily_co_data (from co_daily_summary_dataset.csv)



-- Goal: Retrieve the top 5 highest arithmetic mean CO levels in California (state_code = 6) for the year 2011, including all columns.

SELECT *
FROM daily_co_data
WHERE state_code = 6 AND year = 2011 -- Assuming 'year' column exists in daily_co_data, otherwise 'date_local' year extraction would be needed
ORDER BY arithmetic_mean DESC
LIMIT 5;



-- Goal: List all unique parameter names available in the annual air quality summary.

SELECT DISTINCT parameter_name
FROM annual_air_quality_data;



-- Goal: Count the number of unique cities reported in the daily CO summary.

SELECT COUNT(DISTINCT city_name) AS UniqueCitiesCount
FROM daily_co_data;



-- Goal: Calculate the average arithmetic mean of CO levels per state from the daily summary data.

SELECT
    state_name,
    AVG(arithmetic_mean) AS AverageCOMean
FROM
    daily_co_data
GROUP BY
    state_name
ORDER BY
    AverageCOMean DESC;



-- Goal: Count the total number of observations for each parameter type in the annual air quality data.

SELECT
    parameter_name,
    SUM(observation_count) AS TotalObservations
FROM
    annual_air_quality_data
GROUP BY
    parameter_name
ORDER BY
    TotalObservations DESC;



-- Goal: Find states where the average CO arithmetic mean (from daily data) is greater than 1.0.

SELECT
    state_name,
    AVG(arithmetic_mean) AS AverageCOMean
FROM
    daily_co_data
GROUP BY
    state_name
HAVING
    AVG(arithmetic_mean) > 1.0
ORDER BY
    AverageCOMean DESC;



-- Goal: Get the 3rd to 5th states with the highest average CO mean.

SELECT
    state_name,
    AVG(arithmetic_mean) AS AverageCOMean
FROM
    daily_co_data
GROUP BY
    state_name
ORDER BY
    AverageCOMean DESC
LIMIT 3 OFFSET 2; -- Skips first 2 rows, takes next 3



-- Goal: Categorize daily CO arithmetic mean values into 'Low', 'Medium', or 'High' pollution levels.

SELECT
    date_local,
    city_name,
    arithmetic_mean,
    CASE
        WHEN arithmetic_mean < 0.5 THEN 'Low'
        WHEN arithmetic_mean >= 0.5 AND arithmetic_mean < 2.0 THEN 'Medium'
        ELSE 'High'
    END AS PollutionLevel
FROM
    daily_co_data
ORDER BY
    date_local DESC, city_name
LIMIT 10;



-- Goal: Find sites where both annual and daily Carbon Monoxide data exist, for common locations (state, county, site_num) and 'Carbon monoxide' parameter.

SELECT
    a.state_name,
    a.city_name,
    a.site_num,
    a.year AS AnnualDataYear,
    a.arithmetic_mean AS AnnualMean,
    d.date_local,
    d.arithmetic_mean AS DailyMean
FROM
    annual_air_quality_data AS a
INNER JOIN
    daily_co_data AS d
ON
    a.state_code = d.state_code AND
    a.county_code = d.county_code AND
    a.site_num = d.site_num AND
    a.parameter_name = d.parameter_name
WHERE
    a.parameter_name = 'Carbon monoxide'
LIMIT 10;



-- Goal: Get all annual summary entries for 'Carbon monoxide' and, if available, their corresponding daily CO mean from the daily data for common sites. This shows annual data even if no daily data exists for a particular site.

SELECT
    a.state_name,
    a.city_name,
    a.site_num,
    a.year AS AnnualDataYear,
    a.arithmetic_mean AS AnnualMean,
    d.date_local,
    d.arithmetic_mean AS DailyMean
FROM
    annual_air_quality_data AS a
LEFT JOIN
    daily_co_data AS d
ON
    a.state_code = d.state_code AND
    a.county_code = d.county_code AND
    a.site_num = d.site_num AND
    a.parameter_name = d.parameter_name
WHERE
    a.parameter_name = 'Carbon monoxide'
LIMIT 10;



-- Goal: Combine city and state names from both annual and daily datasets to get a comprehensive list of all locations mentioned, including duplicates (UNION ALL) and unique ones (UNION).

SELECT city_name, state_name FROM annual_air_quality_data
UNION ALL
SELECT city_name, state_name FROM daily_co_data
LIMIT 20;


-- Using UNION (shows only unique city-state pairs)

SELECT city_name, state_name FROM annual_air_quality_data
UNION
SELECT city_name, state_name FROM daily_co_data
LIMIT 20;



-- Goal: Find the 'parameter_name' from annual data that has an 'arithmetic_mean' greater than the overall average 'arithmetic_mean' across all annual data parameters.

SELECT
    parameter_name,
    arithmetic_mean
FROM
    annual_air_quality_data
WHERE
    arithmetic_mean > (
        SELECT AVG(arithmetic_mean)
        FROM annual_air_quality_data
    )
ORDER BY
    arithmetic_mean DESC
LIMIT 10;



-- Goal: Find the top 5 cities with the highest average daily Carbon Monoxide levels.

WITH DailyCOAverages AS (
    -- CTE 1: Calculate the average daily CO mean for each city
    SELECT
        city_name,
        AVG(arithmetic_mean) AS AvgDailyCO
    FROM
        daily_co_data
    WHERE
        city_name IS NOT NULL -- Exclude rows where city name is missing
    GROUP BY
        city_name
),
RankedCOAverages AS (
    -- CTE 2: Rank cities based on their average daily CO mean
    SELECT
        city_name,
        AvgDailyCO,
        ROW_NUMBER() OVER (ORDER BY AvgDailyCO DESC) as RankNum -- (Window Function for ranking)
    FROM
        DailyCOAverages
)
-- Final SELECT: Retrieve the top 5 ranked cities
SELECT
    city_name,
    AvgDailyCO
FROM
    RankedCOAverages
WHERE
    RankNum <= 5
ORDER BY
    RankNum;

-- ====================================================================
-- END OF SQL PORTFOLIO PROJECT 
-- ====================================================================
