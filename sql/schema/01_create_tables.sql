-- within this file will be SQL code specifically designed to cater the creation of tables needed for this project within ORACLE --
-- H1: weather vs severity
-- these are views that are used to create graphs on the dashboard on an applocation within oracle Apex 
-- 1A raw contingency table (weather x severity) -- for chi-square export
-- / Interactive Report
CREATE OR REPLACE VIEW V_WEATHER_SEVERITY_RAW AS
SELECT
    d.YEAR,
    w.WEATHER_DESCRIPTION,
    sv.CASUALTY_SEVERITY_DESC,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE     d  ON d.DATE_KEY    = f.DATE_KEY
JOIN DIM_WEATHER  w  ON w.WEATHER_KEY  = f.WEATHER_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY d.YEAR, w.WEATHER_DESCRIPTION, sv.CASUALTY_SEVERITY_DESC;

-- 1B pivoted fatal/serious/slight counts by weather -- feeds the stacked bar
CREATE OR REPLACE VIEW V_WEATHER_SEVERITY AS
SELECT
    w.WEATHER_DESCRIPTION,
    SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC = 'Fatal'   THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC = 'Serious' THEN 1 ELSE 0 END) AS serious,
    SUM(CASE WHEN sv.CASUALTY_SEVERITY_DESC = 'Slight'  THEN 1 ELSE 0 END) AS slight,
    COUNT(*) AS total
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_WEATHER  w  ON w.WEATHER_KEY  = f.WEATHER_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY w.WEATHER_DESCRIPTION;

-- 1C Fine vs Adverse weather group, with average severity score -- 
CREATE OR REPLACE VIEW V_WEATHER_GROUP_SEVERITY AS
SELECT
    CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Fine%' THEN 'Fine' ELSE 'Adverse' END AS weather_group,
    COUNT(*) AS incident_count,
    ROUND(AVG(4 - f.CASUALTY_SEVERITY_CODE), 2) AS avg_severity_score -- higher = more severe
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_WEATHER w ON w.WEATHER_KEY = f.WEATHER_KEY
WHERE f.CASUALTY_SEVERITY_CODE IS NOT NULL
GROUP BY CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Fine%' THEN 'Fine' ELSE 'Adverse' END;



-- H2: visibility (lighting + fog) vs severity


-- 2a full lighting breakdown -- Interactive Report / detail drill-down
CREATE OR REPLACE VIEW V_LIGHTING_SEVERITY_RAW AS
SELECT
    d.YEAR,
    l.LIGHTING_DESCRIPTION,
    sv.CASUALTY_SEVERITY_DESC,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE     d ON d.DATE_KEY     = f.DATE_KEY
JOIN DIM_LIGHTING l ON l.LIGHTING_KEY = f.LIGHTING_KEY
JOIN DIM_SEVERITY sv ON sv.SEVERITY_KEY = f.SEVERITY_KEY
GROUP BY d.YEAR, l.LIGHTING_DESCRIPTION, sv.CASUALTY_SEVERITY_DESC;

-- i sadly cant get these to work but in the future i will attempt to make these gauge charts
-- 2b Daylight vs Darkness, with % severe -- feeds the bar/gauge chart
-- 2c combined visibility hit: darkness OR fog/mist -- feeds a second bar/gauge chart




-- H3: rain vs incident frequency


-- 3a overall rain vs no-rain summary -- feeds a simple bar chart / KPI cards
CREATE OR REPLACE VIEW V_RAIN_OVERALL AS
SELECT
    CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END AS rain_flag,
    COUNT(*) AS incident_count,
    COUNT(DISTINCT d.DATE_KEY) AS distinct_days_with_an_incident,
    ROUND(COUNT(*) / COUNT(DISTINCT d.DATE_KEY), 2) AS incidents_per_active_day
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE    d ON d.DATE_KEY   = f.DATE_KEY
JOIN DIM_WEATHER w ON w.WEATHER_KEY = f.WEATHER_KEY
GROUP BY CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END;

-- 3b monthly trend, rain vs no rain -- feeds the time-series line chart
CREATE OR REPLACE VIEW V_RAIN_TREND AS
SELECT
    d.YEAR,
    TO_CHAR(d.FULL_DATE, 'MM') AS month_num,
    CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END AS rain_flag,
    COUNT(*) AS incident_count
FROM FACT_INCIDENT_WEATHER f
JOIN DIM_DATE    d ON d.DATE_KEY   = f.DATE_KEY
JOIN DIM_WEATHER w ON w.WEATHER_KEY = f.WEATHER_KEY
GROUP BY d.YEAR, TO_CHAR(d.FULL_DATE, 'MM'),
         CASE WHEN w.WEATHER_DESCRIPTION LIKE 'Raining%' THEN 'Rain' ELSE 'No rain' END;




-- H4: seasonal variation vs severity


-- 4a severity distribution by season -- feeds the grouped/stacked bar chart
CREATE OR REPLACE VIEW V_SEASONAL_SEVERITY AS
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
    sv.CASUALTY_SEVERITY_DESC;

-- 4b seasonal weather context (avg temp/wind/humidity) feeds KPI cards
-- or a small multi-series line chart alongside 4a
CREATE OR REPLACE VIEW V_SEASONAL_WEATHER AS
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
    END;



-- H5: flat extract for temporal-vs-weather model comparison

CREATE OR REPLACE VIEW V_H5_EXTRACT AS
SELECT
    f.INCIDENT_KEY,
    f.CASUALTY_SEVERITY_CODE,                         -- target: 1=Fatal, 2=Serious, 3=Slight
    4 - f.CASUALTY_SEVERITY_CODE          AS severity_score,  -- same target, higher = more severe

    
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
  AND f.WEATHER_TIME_GAP_MINUTES <= 1440
