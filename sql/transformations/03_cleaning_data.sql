-- file containing processes within an ETL stage that will clean the original loaded data to make it Uniform --


-- this code changes incidents joined table to make it uniform for the weather data to join --
ALTER TABLE STAGING_INCIDENT_JOINED
MODIFY FULL_TIME VARCHAR2(8);

UPDATE STAGING_INCIDENT_JOINED
SET FULL_TIME =
    LPAD(
        SUBSTR(
            LPAD(REPLACE(FULL_TIME, ':', ''), 4, '0'),
            1, 2
        ), 2, '0'
    )
    || ':' ||
    LPAD(
        SUBSTR(
            LPAD(REPLACE(FULL_TIME, ':', ''), 4, '0'),
            3, 2
        ), 2, '0'
    );
select * from STAGING_INCIDENT_JOINED
ALTER TABLE STAGING_INCIDENT_JOINED
MODIFY FULL_DATE DATE;
UPDATE STAGING_INCIDENT_JOINED
SET FULL_DATE = TO_DATE(FULL_DATE, 'DD/MM/YYYY');
SELECT
    TO_CHAR(FULL_DATE, 'DD/MM/YYYY') AS FULL_DATE
FROM STAGING_INCIDENT_JOINED;
UPDATE STAGING_INCIDENT_JOINED
SET FULL_DATE = TO_DATE(FULL_DATE, 'DD/MM/RR');
