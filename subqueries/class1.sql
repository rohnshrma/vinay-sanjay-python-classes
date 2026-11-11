
-- =====================================================
-- CHECK 1: TOTAL ROWS VS UNIQUE STUDENTS
-- =====================================================

SELECT

    -- COUNT(*) counts all rows in the table.
    -- It does not matter whether columns contain NULL values.
    -- Example: If the table has 100 records, result = 100.
    (SELECT COUNT(*)
     FROM raw_enrollments) AS total_rows,

    -- COUNT(DISTINCT enrollment_id) counts unique enrollment IDs.
    -- DISTINCT removes duplicate values before counting.
    -- However, it does NOT clean extra spaces or letter casing.
    -- Example: 'STU101' and 'stu101' may be counted separately.
    (SELECT COUNT(DISTINCT enrollment_id)
     FROM raw_enrollments) AS ids_as_typed,

    -- UPPER() converts all characters into uppercase.
    -- TRIM() removes leading and trailing spaces.
    -- DISTINCT then identifies unique IDs after standardization.
    -- Example:
    -- ' stu101 ' becomes 'STU101'
    -- 'stu101'   becomes 'STU101'
    -- Both are now considered the same ID.
    (SELECT COUNT(
        DISTINCT UPPER(TRIM(enrollment_id))
     )
     FROM raw_enrollments) AS ids_after_trim;


-- one-line data quality report

select(
(select count(*) from raw_enrollments 
	where full_name is null) 				as missing_name,

(select count(*) from raw_enrollments
where coalesce (trim(email , '') in ('' , 'N/A' , 'NA' , 'null'))) as missing_email,

(select count(*) from raw_enrollments
	where case
		when trim(age) ~ '^\d+$' then trim(age)::int not between 16 and 60
		else TRUE
		end
) as bad_age,
(select count(*) from raw_enrollments where coalesce(trim(course ,'') in ('' , 'TBD'))) as missing_course
)






-- =====================================================
-- CHECK 2: ONE-LINE DATA QUALITY REPORT
-- =====================================================

SELECT

    -- -------------------------------------------------
    -- CHECK 1: MISSING NAMES
    -- -------------------------------------------------

    -- COUNT(*) counts records satisfying the WHERE condition.
    -- IS NULL checks whether full_name has a NULL value.
    (SELECT COUNT(*)
     FROM raw_enrollments
     WHERE full_name IS NULL
    ) AS missing_name,


    -- -------------------------------------------------
    -- CHECK 2: MISSING EMAILS
    -- -------------------------------------------------

    -- TRIM() removes leading and trailing spaces.
    -- COALESCE() replaces NULL with an empty string.
    -- IN checks whether the value matches any listed value.
    --
    -- We consider the following values as missing:
    -- NULL, '', 'N/A', 'NA', 'NULL'
    (SELECT COUNT(*)
     FROM raw_enrollments
     WHERE UPPER(TRIM(COALESCE(email, '')))
           IN ('', 'N/A', 'NA', 'NULL')
    ) AS missing_email,


    -- -------------------------------------------------
    -- CHECK 3: INVALID AGES
    -- -------------------------------------------------

    (SELECT COUNT(*)
     FROM raw_enrollments

     WHERE
        CASE

            -- ~ is the PostgreSQL regular expression operator.
            -- ^\d+$ means the entire value must contain digits only.
            --
            -- Examples:
            -- '25'  = TRUE
            -- '30'  = TRUE
            -- 'abc' = FALSE
            -- '25a' = FALSE
            WHEN TRIM(age) ~ '^\d+$' THEN

                -- ::int converts text into an integer.
                -- NOT BETWEEN 16 AND 60 checks whether
                -- the numeric age is outside the valid range.
                --
                -- 15 = invalid
                -- 25 = valid
                -- 65 = invalid
                TRIM(age)::int NOT BETWEEN 16 AND 60

            -- If age is not numeric, mark it as invalid.
            -- This also catches NULL and blank values.
            ELSE TRUE

        END
    ) AS bad_age,


    -- -------------------------------------------------
    -- CHECK 4: MISSING COURSES
    -- -------------------------------------------------

    -- COALESCE handles NULL values.
    -- TRIM removes extra spaces.
    -- IN checks for blank values and TBD.
    (SELECT COUNT(*)
     FROM raw_enrollments
     WHERE UPPER(TRIM(COALESCE(course, '')))
           IN ('', 'TBD')
    ) AS missing_course;




-- =====================================================
-- CHECK: FIND DUPLICATE ENROLLMENT IDs AFTER CLEANING
-- =====================================================

SELECT
    clean_id,       -- Displays the standardized enrollment ID
    copies          -- Displays how many times this ID appears

FROM (

    -- INNER QUERY: CLEAN IDs AND COUNT THEIR OCCURRENCES

    SELECT

        -- UPPER() converts all characters into uppercase.
        -- TRIM() removes leading and trailing spaces.
        --
        -- REGEXP_REPLACE() replaces text matching a pattern.
        --
        -- '^WG-?' means:
        -- ^   = Match only at the beginning of the string.
        -- WG  = Match the letters WG.
        -- -?  = Hyphen is optional.
        --
        -- Replacement value 'WG-' ensures that IDs
        -- starting with WG or WG- use the WG- format.
        --
        -- Examples:
        -- wg101     becomes WG-101
        -- WG101     becomes WG-101
        -- WG-101    becomes WG-101
        --
        REGEXP_REPLACE(
            UPPER(TRIM(enrollment_id)),
            '^WG-?',
            'WG-'
        ) AS clean_id,


        -- COUNT(*) counts how many rows belong to each
        -- standardized enrollment ID.
        COUNT(*) AS copies


    FROM raw_enrollments

    -- GROUP BY groups records having the same cleaned ID.
    -- IDs that become identical after cleaning form one group.
    GROUP BY
        REGEXP_REPLACE(
            UPPER(TRIM(enrollment_id)),
            '^WG-?',
            'WG-'
        )

) AS duplicate_check

-- OUTER QUERY:
-- Keep only IDs that appear more than once.
-- These are potential duplicate enrollment records.
WHERE copies > 1

-- Sort results:
-- First: Highest duplicate count comes first.
-- Second: If counts are equal, sort IDs alphabetically.
ORDER BY
    copies DESC,
    clean_id;



-- =====================================================
-- FIND ALL RECORDS HAVING DUPLICATE CLEANED ENROLLMENT IDs
-- =====================================================

SELECT
    enrollment_id,  -- Original enrollment ID from the table
    full_name,      -- Student's name
    city,           -- Student's city
    course,         -- Course enrolled in
    fee_paid        -- Fee paid by the student

FROM raw_enrollments

-- WHERE filters records based on a condition.
-- We are checking whether the cleaned enrollment ID
-- exists in the list returned by the subquery.

WHERE REGEXP_REPLACE(
          UPPER(TRIM(enrollment_id)),
          '^WG-?',
          'WG-'
      )

      IN (

          -- =========================================
          -- SUBQUERY: IDENTIFY DUPLICATE CLEANED IDs
          -- =========================================

          SELECT
              REGEXP_REPLACE(
                  UPPER(TRIM(enrollment_id)),
                  '^WG-?',
                  'WG-'
              )

          FROM raw_enrollments

          -- GROUP BY 1 means group by the first
          -- expression in the SELECT statement.
          -- Here, the first expression is the cleaned ID.
          GROUP BY 1

          -- HAVING filters groups after aggregation.
          -- COUNT(*) > 1 means the ID appears more than once.
          HAVING COUNT(*) > 1

      )

-- Sort the final records by standardized enrollment ID.
ORDER BY UPPER(TRIM(enrollment_id));
