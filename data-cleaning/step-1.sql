-- GOAL: understand HOW dirty the data is before changing anything.
-- Rule #1 of data cleaning: never clean blindly. Measure first.

-- 1A. How many rows do we have in total?
SELECT COUNT(*) AS total_rows          -- COUNT(*) counts every row, including rows full of NULLs
FROM raw_enrollments;                  -- the raw (untouched) table we loaded

-- 1B. How many values are missing in each column?
-- COUNT(column) skips NULLs, so COUNT(*) - COUNT(col) = number of NULLs in that column.
SELECT
    COUNT(*) - COUNT(full_name)    AS null_names,     -- missing names
    COUNT(*) - COUNT(email)        AS null_emails,    -- missing emails
    COUNT(*) - COUNT(phone)        AS null_phones,    -- missing phones
    COUNT(*) - COUNT(city)         AS null_cities,    -- missing cities
    COUNT(*) - COUNT(enroll_date)  AS null_dates,     -- missing dates
    COUNT(*) - COUNT(fee_paid)     AS null_fees       -- missing fees
FROM raw_enrollments;

-- 1C. "Hidden" missing values: empty strings and fake NULLs like 'N/A'.
-- These are NOT counted as NULL by the database, so we have to search for them.
SELECT
    SUM(CASE WHEN TRIM(email) = '' THEN 1 ELSE 0 END)                         AS empty_emails,  -- '' or '   '
    SUM(CASE WHEN UPPER(TRIM(email)) IN ('N/A','NA','NULL') THEN 1 ELSE 0 END) AS fake_null_emails -- text that only LOOKS like null
FROM raw_enrollments;

-- 1D. How many DIFFERENT spellings exist for one category? (a red flag for inconsistency)
SELECT city,                     -- the raw city value exactly as typed
       COUNT(*) AS how_many      -- how many rows have that exact spelling
FROM raw_enrollments
GROUP BY city                    -- one output row per distinct spelling
ORDER BY how_many DESC;          -- most common first

-- 1E. Same check for course and gender - you will see 'MERN', 'mern', 'Mern-Stack'...
SELECT course, COUNT(*) FROM raw_enrollments GROUP BY course ORDER BY 2 DESC;  -- ORDER BY 2 = sort by 2nd column
SELECT gender, COUNT(*) FROM raw_enrollments GROUP BY gender ORDER BY 2 DESC;

-- 1F. Are there duplicate IDs? An ID should be unique; anything > 1 is a problem.
SELECT UPPER(TRIM(enrollment_id)) AS id,   -- normalise the ID just for this check
       COUNT(*)                   AS copies
FROM raw_enrollments
GROUP BY UPPER(TRIM(enrollment_id))
HAVING COUNT(*) > 1                         -- HAVING filters AFTER grouping (WHERE cannot use COUNT)
ORDER BY copies DESC;

-- 1G. Peek at the messiest columns: what formats exist for dates and fees?
SELECT DISTINCT enroll_date FROM raw_enrollments LIMIT 25;  -- DISTINCT removes repeated values
SELECT DISTINCT fee_paid    FROM raw_enrollments LIMIT 25;  -- LIMIT keeps the output short