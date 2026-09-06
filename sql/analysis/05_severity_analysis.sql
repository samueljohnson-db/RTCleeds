-- within this file a list of queries will be stored which will create views and tables specifically created to solve aims and objectives --

-- H1 (main): is there a relationship between weather conditions and incident severity?--

-- 1A this query produces a table showing the amount of incidents recorded depending on the casualty severity description and weather_description
SELECT
    w.WEATHER_DESCRIPTION,
    sv.CASUALTY_SEVERITY_DESC,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_WEATHER  w  ON w.WEATHER_KEY  = f.WEATHER_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY w.WEATHER_DESCRIPTION, sv.CASUALTY_SEVERITY_DESC
ORDER BY w.WEATHER_DESCRIPTION, sv.CASUALTY_SEVERITY_DESC;
-- 1B this shows the same statistics just with a better view of the quantity
SELECT
    w.WEATHER_DESCRIPTION,
    SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC = 'Fatal'   THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC = 'Serious' THEN 1 ELSE 0 END) AS serious,
    SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC = 'Slight'  THEN 1 ELSE 0 END) AS slight,
    COUNT(*) AS total
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_WEATHER  w  ON w.WEATHER_KEY  = f.WEATHER_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY w.WEATHER_DESCRIPTION
ORDER BY w.WEATHER_DESCRIPTION;

SELECT
    CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Fine%' THEN 'Fine' ELSE 'Adverse' END AS weather_group,
    COUNT(*) AS incident_count,
    ROUND(AVG(4 - f.CASUALTY_SEVERITY_CODE), 2) AS avg_severity_score -- higher = more severe
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_WEATHER w ON w.WEATHER_KEY = f.WEATHER_KEY
WHERE f.CASUALTY_SEVERITY_CODE IS NOT NULL
GROUP BY CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Fine%' THEN 'Fine' ELSE 'Adverse' END;







-- H2: reduced visibility increases the likelihood of severe incidents.
-- Visibility is operationalised as lighting condition (daylight vs
-- darkness) 

-- 2a. Full lighting-condition breakdown vs severity
SELECT
    l.LIGHTING_DESCRIPTION,
    sv.CASUALTY_SEVERITY_DESC,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_LIGHTING l  ON l.LIGHTING_KEY = f.LIGHTING_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY l.LIGHTING_DESCRIPTION, sv.CASUALTY_SEVERITY_DESC
ORDER BY l.LIGHTING_DESCRIPTION, sv.CASUALTY_SEVERITY_DESC;

-- 2b. Collapsed to Daylight vs Darkness, with % severe (Fatal+Serious) for a quick read
SELECT
    CASE WHEN l.LIGHTING_DESCRIPTION LIKE 'Daylight%' THEN 'Daylight' ELSE 'Darkness' END AS visibility_condition,
    COUNT(*) AS incident_count,
    ROUND(100 * SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC IN ('Fatal','Serious') THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_severe,
    ROUND(AVG(4 - f.CASUALTY_SEVERITY_CODE), 2) AS avg_severity_score
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_LIGHTING l  ON l.LIGHTING_KEY = f.LIGHTING_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY CASE WHEN l.LIGHTING_DESCRIPTION LIKE 'Daylight%' THEN 'Daylight' ELSE 'Darkness' END;

-- 2c. Combined visibility hit: darkness OR fog/mist, vs everything else
SELECT
    CASE
        WHEN l.LIGHTING_DESCRIPTION LIKE 'Darkness%' OR w.WEATHER_DESCRIPTION LIKE 'Fog%'
            THEN 'Reduced visibility'
        ELSE 'Normal visibility'
    END AS visibility_group,
    COUNT(*) AS incident_count,
    ROUND(100 * SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC IN ('Fatal','Serious') THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_severe
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_LIGHTING l  ON l.LIGHTING_KEY  = f.LIGHTING_KEY
JOIN DIM_WEATHER  w  ON w.WEATHER_KEY   = f.WEATHER_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY CASE
        WHEN l.LIGHTING_DESCRIPTION LIKE 'Darkness%' OR w.WEATHER_DESCRIPTION LIKE 'Fog%'
            THEN 'Reduced visibility'
        ELSE 'Normal visibility'
    END;


--------------------------------------------------------------------------
-- H3: rainfall is associated with increased incident FREQUENCY (not
-- severity). 

-- 3a. Overall: incident count and rough daily rate, rain vs no rain
SELECT
    CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END AS rain_flag,
    COUNT(*) AS incident_count,
    COUNT(DISTINCT d.DATE_KEY) AS distinct_days_with_an_incident,
    ROUND(COUNT(*) / COUNT(DISTINCT d.DATE_KEY), 2) AS incidents_per_active_day
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE    d ON d.DATE_KEY   = f.DATE_KEY
JOIN DIM_WEATHER w ON w.WEATHER_KEY = f.WEATHER_KEY
GROUP BY CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END;

-- 3b. Monthly trend, rain vs no rain -- useful for a time-series chart
SELECT
    d.YEAR,
    TO_CHAR(d.FULL_DATE, 'MM') AS month_num,
    CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END AS rain_flag,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE    d ON d.DATE_KEY   = f.DATE_KEY
JOIN DIM_WEATHER w ON w.WEATHER_KEY = f.WEATHER_KEY
GROUP BY d.YEAR, TO_CHAR(d.FULL_DATE, 'MM'),
         CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END
ORDER BY d.YEAR, month_num;


-- H4: seasonal weather variation influences the severity distribution.
-- Season is derived from the calendar month of FULL_DATE (UK
-- meteorological seasons)

-- 4a. Severity distribution by season -- Chi-square or Kruskal-Wallis on severity score
SELECT
    CASE TO_CHAR(d.FULL_DATE, 'MM')
        WHEN '12' THEN 'Winter' WHEN '01' THEN 'Winter' WHEN '02' THEN 'Winter'
        WHEN '03' THEN 'Spring' WHEN '04' THEN 'Spring' WHEN '05' THEN 'Spring'
        WHEN '06' THEN 'Summer' WHEN '07' THEN 'Summer' WHEN '08' THEN 'Summer'
        WHEN '09' THEN 'Autumn' WHEN '10' THEN 'Autumn' WHEN '11' THEN 'Autumn'
    END AS season,
    sv.CASUALTY_SEVERITY_DESC,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE     d  ON d.DATE_KEY   = f.DATE_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY CASE TO_CHAR(d.FULL_DATE, 'MM')
        WHEN '12' THEN 'Winter' WHEN '01' THEN 'Winter' WHEN '02' THEN 'Winter'
        WHEN '03' THEN 'Spring' WHEN '04' THEN 'Spring' WHEN '05' THEN 'Spring'
        WHEN '06' THEN 'Summer' WHEN '07' THEN 'Summer' WHEN '08' THEN 'Summer'
        WHEN '09' THEN 'Autumn' WHEN '10' THEN 'Autumn' WHEN '11' THEN 'Autumn'
    END,
    sv.CASUALTY_SEVERITY_DESC
ORDER BY 1, 2;

-- 4b. What the weather actually looked like each season, for context
-- alongside 4a (mean of each continuous weather reading, by season)
SELECT
    CASE TO_CHAR(d.FULL_DATE, 'MM')
        WHEN '12' THEN 'Winter' WHEN '01' THEN 'Winter' WHEN '02' THEN 'Winter'
        WHEN '03' THEN 'Spring' WHEN '04' THEN 'Spring' WHEN '05' THEN 'Spring'
        WHEN '06' THEN 'Summer' WHEN '07' THEN 'Summer' WHEN '08' THEN 'Summer'
        WHEN '09' THEN 'Autumn' WHEN '10' THEN 'Autumn' WHEN '11' THEN 'Autumn'
    END AS season,
    ROUND(AVG(f.WX_TEMP_8M_DEGC), 1)     AS avg_temp_c,
    ROUND(AVG(f.WX_WIND_SPD_12M_MS), 1)  AS avg_wind_speed_ms,
    ROUND(AVG(f.WX_REL_HUM_PCT), 1)      AS avg_humidity_pct,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE d ON d.DATE_KEY = f.DATE_KEY
GROUP BY CASE TO_CHAR(d.FULL_DATE, 'MM')
        WHEN '12' THEN 'Winter' WHEN '01' THEN 'Winter' WHEN '02' THEN 'Winter'
        WHEN '03' THEN 'Spring' WHEN '04' THEN 'Spring' WHEN '05' THEN 'Spring'
        WHEN '06' THEN 'Summer' WHEN '07' THEN 'Summer' WHEN '08' THEN 'Summer'
        WHEN '09' THEN 'Autumn' WHEN '10' THEN 'Autumn' WHEN '11' THEN 'Autumn'
    END
ORDER BY 1;


-- H5: do weather variables improve prediction of severity compared to
-- temporal variables alone?

SELECT
    f.INCIDENT_KEY,
    f.CASUALTY_SEVERITY_CODE,                         -- target: 1=Fatal, 2=Serious, 3=Slight
    4 - f.CASUALTY_SEVERITY_CODE          AS severity_score,  -- same target, higher = more severe

    -- temporal predictors
    d.YEAR,
    TO_CHAR(d.FULL_DATE, 'MM')            AS month_num,
    TO_CHAR(d.FULL_DATE, 'DY')            AS day_of_week,
    f.HOUR,
    f.TIME_PERIOD,
    CASE TO_CHAR(d.FULL_DATE, 'MM')
        WHEN '12' THEN 'Winter' WHEN '01' THEN 'Winter' WHEN '02' THEN 'Winter'
        WHEN '03' THEN 'Spring' WHEN '04' THEN 'Spring' WHEN '05' THEN 'Spring'
        WHEN '06' THEN 'Summer' WHEN '07' THEN 'Summer' WHEN '08' THEN 'Summer'
        WHEN '09' THEN 'Autumn' WHEN '10' THEN 'Autumn' WHEN '11' THEN 'Autumn'
    END AS season,

    
    w.WEATHER_DESCRIPTION,
    l.LIGHTING_DESCRIPTION,
    r.ROAD_SURFACE_DESCRIPTION,
    f.WX_WIND_DIR_12M,
    f.WX_WIND_SPD_12M_MS,
    f.WX_WIND_STD,
    f.WX_TEMP_8M_DEGC,
    f.WX_TEMP_DIFF_2M,
    f.WX_GLOB_RAD_WM2,
    f.WX_REL_HUM_PCT,
    f.WEATHER_TIME_GAP_MINUTES,           

    
    f.ROAD_CLASS,
    f.NUMBER_OF_VEHICLES,
    v.VEHICLE_DESCRIPTION
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE     d  ON d.DATE_KEY    = f.DATE_KEY
LEFT JOIN DIM_WEATHER  w ON w.WEATHER_KEY  = f.WEATHER_KEY
LEFT JOIN DIM_LIGHTING l ON l.LIGHTING_KEY = f.LIGHTING_KEY
LEFT JOIN DIM_ROAD     r ON r.ROAD_KEY     = f.ROAD_KEY
LEFT JOIN DIM_VEHICLE  v ON v.VEHICLE_KEY  = f.VEHICLE_KEY
WHERE f.CASUALTY_SEVERITY_CODE IS NOT NULL
  AND f.WEATHER_TIME_GAP_MINUTES IS NOT NULL
  AND f.WEATHER_TIME_GAP_MINUTES <= 1440;  
