USE ghg_emissions_data;

-- SQL Data Cleaning and Manipulation: These data sets are not in the proper format for time series analysis, must transpose yearly data
-- Create Transposed Data for Greenhouse Emissions, GDP, and Population, for use in time series analysis in Power BI

-- Drop Temporary Tables if they already exist
IF OBJECT_ID('ghg_emissions_data.dbo.TransposedEmissionsData') IS NOT NULL
    DROP TABLE ghg_emissions_data.dbo.TransposedEmissionsData;

IF OBJECT_ID('ghg_emissions_data.dbo.TransposedPopulationData') IS NOT NULL
    DROP TABLE ghg_emissions_data.dbo.TransposedPopulationData;

IF OBJECT_ID('ghg_emissions_data.dbo.TransposedGDPData') IS NOT NULL
    DROP TABLE ghg_emissions_data.dbo.TransposedGDPData;


-- Transpose Greenhouse Gas Emissions Data
SELECT
    Country,
    '1970' AS Year,
    ghg_emissions_1970 AS ghg_emissions
INTO
    TransposedEmissionsData
FROM
    ghg_emissions

UNION ALL

SELECT
    Country,
    '1990' AS Year,
    ghg_emissions_1990 AS ghg_emissions
FROM
    ghg_emissions

UNION ALL

SELECT
    Country,
    '2005' AS Year,
    ghg_emissions_2005 AS ghg_emissions
FROM
    ghg_emissions

UNION ALL

SELECT
    Country,
    '2017' AS Year,
    ghg_emissions_2017 AS ghg_emissions
FROM
    ghg_emissions

UNION ALL

SELECT
    Country,
    '2022' AS Year,
    ghg_emissions_2022 AS ghg_emissions
FROM
    ghg_emissions;

-- Transpose World Population Data
SELECT
    Country_Territory AS Country,
    '1970' AS Year,
    Population_1970 AS Population
INTO
    TransposedPopulationData
FROM
    world_pop

UNION ALL

SELECT
    Country_Territory AS Country,
    '1990' AS Year,
    Population_1990 AS Population
FROM
    world_pop

UNION ALL

SELECT
    Country_Territory AS Country,
    '2000' AS Year,
    Population_2000 AS Population
FROM
    world_pop

UNION ALL

SELECT
    Country_Territory AS Country,
    '2010' AS Year,
    Population_2010 AS Population
FROM
    world_pop

UNION ALL

SELECT
    Country_Territory AS Country,
    '2015' AS Year,
    Population_2015 AS Population
FROM
    world_pop

UNION ALL

SELECT
    Country_Territory AS Country,
    '2020' AS Year,
    Population_2020 AS Population
FROM
    world_pop

UNION ALL

SELECT
    Country_Territory AS Country,
    '2022' AS Year,
    Population_2022 AS Population
FROM
    world_pop;



-- Transpose GDP Data
SELECT
    Country_name AS Country,
    '1980' AS Year,
    gdp_1980 AS GDP
INTO
    TransposedGDPData
FROM
    gdp

UNION ALL

SELECT
    Country_name AS Country,
    '1990' AS Year,
    gdp_1990 AS GDP
FROM
    gdp

UNION ALL

SELECT
    Country_name AS Country,
    '2005' AS Year,
    gdp_2005 AS GDP
FROM
    gdp

UNION ALL

SELECT
    Country_name AS Country,
    '2017' AS Year,
    gdp_2017 AS GDP
FROM
    gdp

UNION ALL

SELECT
    Country_name AS Country,
    '2022' AS Year,
    gdp_2022 AS GDP
FROM
    gdp;


-- Example below of one exported table for Power BI time series analysis, selecting only where all sets have common countries, due to different data sources
-- Repeat below with transposed emissions and population
SELECT * 
FROM TransposedGDPData
WHERE Country IN (SELECT g.Country
FROM ghg_emissions g 
INNER JOIN gdp d 
ON d.Country_name LIKE '%' + g.Country + '%'
INNER JOIN world_pop p ON p.Country_Territory LIKE '%' + g.Country + '%' )
ORDER BY Country, Year;




-- Create chart for export to Power BI ranking each country by their growth in GDP from 1990 - 2022
-- Utilize a CTE and window function for ranking and selection
WITH GDP_Growth_Rank AS (
    SELECT
        e.Country,
        RANK() OVER (ORDER BY AVG(g.gdp_2022 - g.gdp_1990) DESC) AS gdp_growth_rank
    FROM
        ghg_emissions e
    INNER JOIN
        gdp g ON e.Country = g.Country_name
    INNER JOIN
        world_pop p ON g.Country_name = p.Country_Territory
    WHERE
        g.gdp_2022 > 0 AND g.gdp_1990 > 0 -- Exclude places with 0 GDP for either 2022 or 1990
    GROUP BY
        e.Country
)

SELECT
    ggr.Country,
    ggr.gdp_growth_rank,
    g.gdp_2022 - g.gdp_1990 AS gdp_growth
FROM
    GDP_Growth_Rank ggr
INNER JOIN
    gdp g ON ggr.Country = g.Country_name
ORDER BY
    ggr.gdp_growth_rank;