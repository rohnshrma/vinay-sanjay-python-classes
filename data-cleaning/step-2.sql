-- GOAL: keep raw_enrollments as an untouched backup. All cleaning happens on a copy.
-- If you make a mistake you can always DROP the copy and start again.

DROP TABLE IF EXISTS stg_enrollments;     -- IF EXISTS = no error if the table is not there yet

CREATE TABLE stg_enrollments AS           -- CREATE TABLE ... AS SELECT = copy structure + data in one go
SELECT * FROM raw_enrollments;            -- copy every row and every column

-- Add a technical row number so we can point to one exact row later (useful for duplicates).
ALTER TABLE stg_enrollments
    ADD COLUMN row_id SERIAL;             -- SERIAL = auto-incrementing integer 1,2,3... filled for existing rows too

-- Confirm the copy has the same row count as the raw table.
SELECT (SELECT COUNT(*) FROM raw_enrollments) AS raw_rows,   -- scalar subquery: returns one number
       (SELECT COUNT(*) FROM stg_enrollments) AS stg_rows;   -- both numbers should match