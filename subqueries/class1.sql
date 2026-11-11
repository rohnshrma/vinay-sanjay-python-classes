
-- =====================================================
-- CHECK 1: TOTAL ROWS VS UNIQUE STUDENTS
-- =====================================================

SELECT

    -- COUNT(*) counts all the rows in the table.
    -- It does not matter whether the columns have NULL values or not.
    -- Example: if the table has 100 records, the result is 100.
    (SELECT COUNT(*)
     FROM raw_enrollments) AS total_rows,

    -- COUNT(DISTINCT enrollment_id) counts the unique enrollment IDs.
    -- DISTINCT removes the duplicate values before counting.
    -- But it does NOT clean the extra spaces or the letter casing.
    -- Example: 'STU101' and 'stu101' may get counted separately.
    (SELECT COUNT(DISTINCT enrollment_id)
     FROM raw_enrollments) AS ids_as_typed,

    -- UPPER() converts all the characters into capital letters.
    -- TRIM() removes the spaces from the start and the end.
    -- DISTINCT then finds the unique IDs after this standardisation.
    -- Example:
    -- ' stu101 ' becomes 'STU101'
    -- 'stu101'   becomes 'STU101'
    -- Now both are treated as the same ID.
    (SELECT COUNT(
        DISTINCT UPPER(TRIM(enrollment_id))
     )
     FROM raw_enrollments) AS ids_after_trim;


-- one-line data quality report (first rough draft, kindly refer CHECK 2 below for the proper version)

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

    -- COUNT(*) counts only those records which satisfy the WHERE condition.
    -- IS NULL checks whether full_name has a NULL value.
    (SELECT COUNT(*)
     FROM raw_enrollments
     WHERE full_name IS NULL
    ) AS missing_name,


    -- -------------------------------------------------
    -- CHECK 2: MISSING EMAILS
    -- -------------------------------------------------

    -- TRIM() removes the spaces from the start and the end.
    -- COALESCE() replaces NULL with an empty string.
    -- IN checks whether the value matches any one of the listed values.
    --
    -- We treat the following values as missing:
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

            -- ~ is the regular expression operator in PostgreSQL.
            -- ^\d+$ means the whole value must have digits only.
            --
            -- Examples:
            -- '25'  = TRUE
            -- '30'  = TRUE
            -- 'abc' = FALSE
            -- '25a' = FALSE
            WHEN TRIM(age) ~ '^\d+$' THEN

                -- ::int converts the text into an integer.
                -- NOT BETWEEN 16 AND 60 checks whether
                -- the age is outside the valid range or not.
                --
                -- 15 = invalid
                -- 25 = valid
                -- 65 = invalid
                TRIM(age)::int NOT BETWEEN 16 AND 60

            -- If age is not a number, we mark it as invalid.
            -- This also catches NULL and blank values.
            ELSE TRUE

        END
    ) AS bad_age,


    -- -------------------------------------------------
    -- CHECK 4: MISSING COURSES
    -- -------------------------------------------------

    -- COALESCE takes care of the NULL values.
    -- TRIM removes the extra spaces.
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
    clean_id,       -- shows the standardised enrollment ID
    copies          -- shows how many times this ID is appearing

FROM (

    -- INNER QUERY: CLEAN THE IDs AND COUNT THEIR OCCURRENCES

    SELECT

        -- UPPER() converts all the characters into capital letters.
        -- TRIM() removes the spaces from the start and the end.
        --
        -- REGEXP_REPLACE() replaces the text which matches a pattern.
        --
        -- '^WG-?' means:
        -- ^   = match only at the beginning of the string.
        -- WG  = match the letters WG.
        -- -?  = the hyphen is optional.
        --
        -- The replacement value 'WG-' makes sure that IDs
        -- starting with WG or WG- all come in the WG- format.
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
        -- standardised enrollment ID.
        COUNT(*) AS copies


    FROM raw_enrollments

    -- GROUP BY puts the records having the same cleaned ID together.
    -- IDs which become identical after cleaning form one group.
    GROUP BY
        REGEXP_REPLACE(
            UPPER(TRIM(enrollment_id)),
            '^WG-?',
            'WG-'
        )

) AS duplicate_check

-- OUTER QUERY:
-- Keep only those IDs which appear more than once.
-- These are the possible duplicate enrollment records.
WHERE copies > 1

-- Sort the results:
-- First: the highest duplicate count comes on top.
-- Second: if counts are equal, sort the IDs alphabetically.
ORDER BY
    copies DESC,
    clean_id;
