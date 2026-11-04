-- GOAL: clean the city column using a separate mapping table, instead of writing one very big CASE.
-- Why? A mapping table is easy to extend (just INSERT one more row) and other tables can also reuse it.

DROP TABLE IF EXISTS city_map;
CREATE TABLE city_map (
    raw_city   TEXT PRIMARY KEY,   -- the dirty spelling (kept in lower case)
    clean_city TEXT NOT NULL       -- the one official spelling
);

INSERT INTO city_map (raw_city, clean_city) VALUES
    ('gurugram', 'Gurugram'), ('gurgaon', 'Gurugram'), ('ggn', 'Gurugram'),
    ('new delhi', 'Delhi'),   ('delhi', 'Delhi'),      ('dilli', 'Delhi'),
    ('noida', 'Noida'),
    ('faridabad', 'Faridabad'), ('fbd', 'Faridabad'),
    ('rewari', 'Rewari');

-- UPDATE ... FROM is the PostgreSQL way to update one table using the values of another table.
UPDATE stg_enrollments AS s              -- s = short name (alias) for the staging table
SET city = m.clean_city                  -- take the official spelling from the map
FROM city_map AS m                       -- m = alias for the mapping table
WHERE LOWER(s.city) = m.raw_city;        -- join condition: match on the lower-case spelling


-- Check: only the clean city names should be showing now.
SELECT city FROM stg_enrollments GROUP BY city ORDER BY city;
