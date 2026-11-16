```sql

-- ============================================================
-- STEP 1: DROP THE OLD TABLE
-- ============================================================

-- DROP TABLE: Deletes an existing table from the database.
-- IF EXISTS: Prevents an error if the table does not exist.
-- This is useful when running the same cleaning query multiple times.

DROP TABLE IF EXISTS enrollments;


-- ============================================================
-- STEP 2: CREATE A NEW CLEANED TABLE
-- ============================================================

-- CREATE TABLE AS SELECT:
-- Creates a new table and automatically inserts the result
-- of the SELECT query into that table.
--
-- enrollments = Name of the new cleaned table.

CREATE TABLE enrollments AS


-- ============================================================
-- OUTER QUERY
-- ============================================================

-- This is the final SELECT statement.
-- It decides which columns will appear in the final table.
--
-- We are selecting only the required columns.
-- The internal column 'rn' is not required in the final output.

SELECT
    enrollment_id,
    full_name,
    gender,
    age,
    email,
    phone,
    city,
    course,
    enroll_date,
    fee_paid,
    payment_mode,
    status,
    rating

FROM (

    -- ========================================================
    -- LAYER 3: DUPLICATE REMOVAL
    -- Alias: d
    -- ========================================================

    -- ROW_NUMBER():
    -- A window function that assigns a sequential number
    -- to every row.
    --
    -- PARTITION BY:
    -- Divides rows into separate groups based on enrollment_id.
    --
    -- Every student having the same enrollment_id belongs
    -- to the same group.
    --
    -- ORDER BY:
    -- Decides the order in which row numbers are assigned.
    --
    -- Example:
    -- WG-101  Rohan    1
    -- WG-101  Rahul    2
    -- WG-102  Amit     1
    --
    -- Each group starts numbering from 1.

    SELECT
        t.*,

        ROW_NUMBER() OVER (
            PARTITION BY t.enrollment_id
            ORDER BY t.enrollment_id
        ) AS rn

        -- AS rn:
        -- Gives the generated row number column the name 'rn'.

    FROM (

        -- ====================================================
        -- LAYER 2: COLUMN-WISE DATA CLEANING
        -- Alias: t
        -- ====================================================

        -- Here we clean every column individually.
        -- The data is received from Layer 1 (alias f).

        SELECT

            -- ------------------------------------------------
            -- 1. CLEAN ENROLLMENT ID
            -- ------------------------------------------------

            -- TRIM():
            -- Removes leading and trailing spaces.
            --
            -- UPPER():
            -- Converts all characters into uppercase.
            --
            -- REGEXP_REPLACE():
            -- Replaces text matching a regular expression.
            --
            -- '^WG-?':
            -- ^ means the beginning of the string.
            -- WG means the characters WG.
            -- -? means hyphen is optional.
            --
            -- Replacement:
            -- WG-
            --
            -- Examples:
            -- wg1195  -> WG-1195
            -- WG1195  -> WG-1195
            -- WG-1195 -> WG-1195

            REGEXP_REPLACE(
                UPPER(TRIM(enrollment_id)),
                '^WG-?',
                'WG-'
            ) AS enrollment_id,


            -- ------------------------------------------------
            -- 2. CLEAN FULL NAME
            -- ------------------------------------------------

            -- REPLACE(full_name, '.', ''):
            -- Removes all dots from the name.
            --
            -- REGEXP_REPLACE():
            -- '\s+' means one or more whitespace characters.
            -- Replaces multiple spaces with a single space.
            -- 'g' means global replacement (all occurrences).
            --
            -- TRIM():
            -- Removes spaces from the beginning and end.
            --
            -- INITCAP():
            -- Converts the first letter of each word to uppercase.
            --
            -- Example:
            -- '  rohan   sharma. ' -> 'Rohan Sharma'
            --
            -- NULLIF(value, ''):
            -- Returns NULL if the final value is an empty string.
            -- Otherwise, returns the actual value.

            NULLIF(
                INITCAP(
                    TRIM(
                        REGEXP_REPLACE(
                            REPLACE(full_name, '.', ''),
                            '\s+',
                            ' ',
                            'g'
                        )
                    )
                ),
                ''
            ) AS full_name,


            -- ------------------------------------------------
            -- 3. CLEAN GENDER
            -- ------------------------------------------------

            -- LOWER():
            -- Converts the value into lowercase.
            --
            -- TRIM():
            -- Removes unwanted spaces.
            --
            -- IN():
            -- Checks whether a value matches any value
            -- from the provided list.
            --
            -- CASE:
            -- Works like IF / ELSE IF / ELSE.
            --
            -- WHEN:
            -- Specifies a condition.
            --
            -- THEN:
            -- Specifies the result when the condition is TRUE.
            --
            -- ELSE:
            -- Executes when none of the conditions match.

            CASE

                WHEN LOWER(TRIM(gender))
                     IN ('m', 'male')
                THEN 'Male'

                WHEN LOWER(TRIM(gender))
                     IN ('f', 'female', 'femal')
                THEN 'Female'

                ELSE NULL

                -- Invalid or unknown gender becomes NULL.

            END AS gender,


            -- ------------------------------------------------
            -- 4. CLEAN AGE
            -- ------------------------------------------------

            -- Some ages are stored as words.
            -- Others contain unwanted text such as '25 yrs'.
            --
            -- REGEXP_REPLACE(age, '\D', '', 'g'):
            --
            -- \D means any character that is NOT a digit.
            -- It removes all non-numeric characters.
            --
            -- Examples:
            -- '25 yrs' -> '25'
            -- 'Age 30' -> '30'
            -- '2a5'    -> '25'
            --
            -- ~:
            -- PostgreSQL regular expression matching operator.
            --
            -- '^\d+$':
            -- ^ means beginning.
            -- \d means digit.
            -- + means one or more.
            -- $ means ending.
            --
            -- So the entire value must contain digits only.

            CASE

                -- Convert word-based ages into numbers.

                WHEN LOWER(TRIM(age)) = 'twenty'
                THEN 20

                WHEN LOWER(TRIM(age)) = 'twenty two'
                THEN 22


                -- Handle numeric ages.

                WHEN REGEXP_REPLACE(age, '\D', '', 'g') ~ '^\d+$'

                     -- ::INT converts TEXT into INTEGER.
                     -- BETWEEN checks whether age is within
                     -- the inclusive range 16 to 60.

                     AND REGEXP_REPLACE(age, '\D', '', 'g')::INT
                         BETWEEN 16 AND 60

                     -- !~ means NOT matching a regular expression.
                     -- Rejects values containing a minus sign.
                     -- Example: -25

                     AND age !~ '-'

                THEN REGEXP_REPLACE(age, '\D', '', 'g')::INT

                ELSE NULL

            END AS age,


            -- ------------------------------------------------
            -- 5. CLEAN EMAIL
            -- ------------------------------------------------

            -- LOWER(): Converts email into lowercase.
            -- TRIM(): Removes spaces from both ends.
            --
            -- ~: Checks whether email matches the pattern.
            --
            -- Regular expression:
            -- ^                 Beginning of string
            -- [a-z0-9._]+       Letters, digits, dot or underscore
            -- @                 Must contain @
            -- [a-z0-9]+         Domain name
            -- \.                Actual dot
            -- [a-z]+            Domain extension
            -- $                 End of string
            --
            -- Example:
            -- ROHAN@gmail.com -> rohan@gmail.com
            --
            -- Invalid emails become NULL.

            CASE

                WHEN LOWER(TRIM(email))
                     ~ '^[a-z0-9._]+@[a-z0-9]+\.[a-z]+$'

                THEN LOWER(TRIM(email))

                ELSE NULL

            END AS email,


            -- ------------------------------------------------
            -- 6. CLEAN PHONE NUMBER
            -- ------------------------------------------------

            -- REGEXP_REPLACE(phone, '\D', '', 'g'):
            -- Removes everything except digits.
            --
            -- RIGHT(value, 10):
            -- Extracts the last 10 characters.
            --
            -- LENGTH():
            -- Returns the number of characters.
            --
            -- Example:
            -- +91 98765-43210
            -- After removing non-digits: 919876543210
            -- After RIGHT(..., 10): 9876543210
            --
            -- ~ '^[6-9]':
            -- Checks whether the number starts with 6, 7, 8 or 9.
            --
            -- <> means NOT EQUAL TO.

            CASE

                WHEN LENGTH(
                    RIGHT(
                        REGEXP_REPLACE(phone, '\D', '', 'g'),
                        10
                    )
                ) = 10

                AND RIGHT(
                    REGEXP_REPLACE(phone, '\D', '', 'g'),
                    10
                ) ~ '^[6-9]'

                AND RIGHT(
                    REGEXP_REPLACE(phone, '\D', '', 'g'),
                    10
                ) <> '0000000000'

                THEN RIGHT(
                    REGEXP_REPLACE(phone, '\D', '', 'g'),
                    10
                )

                ELSE NULL

            END AS phone,


            -- ------------------------------------------------
            -- 7. STANDARDIZE CITY
            -- ------------------------------------------------

            -- Different spellings of the same city are converted
            -- into one standard spelling.
            --
            -- Example:
            -- Ggn       -> Gurugram
            -- Gurgaon   -> Gurugram
            -- Dilli     -> Delhi
            -- Fbd       -> Faridabad
            --
            -- LOWER() makes comparison case-insensitive.
            -- TRIM() removes unwanted spaces.

            CASE

                WHEN LOWER(TRIM(city))
                     IN ('gurugram', 'gurgaon', 'ggn')
                THEN 'Gurugram'

                WHEN LOWER(TRIM(city))
                     IN ('delhi', 'new delhi', 'dilli')
                THEN 'Delhi'

                WHEN LOWER(TRIM(city))
                     IN ('faridabad', 'fbd')
                THEN 'Faridabad'

                WHEN LOWER(TRIM(city)) = 'noida'
                THEN 'Noida'

                WHEN LOWER(TRIM(city)) = 'rewari'
                THEN 'Rewari'

                ELSE NULL

            END AS city,


            -- ------------------------------------------------
            -- 8. STANDARDIZE COURSE
            -- ------------------------------------------------

            -- LIKE:
            -- Used for pattern matching.
            --
            -- %:
            -- Wildcard representing zero or more characters.
            --
            -- '%mern%':
            -- Finds mern anywhere inside the text.
            --
            -- Examples:
            -- MERN
            -- Mern Stack
            -- Full Stack MERN
            --
            -- All become 'MERN Stack'.

            CASE

                WHEN LOWER(course) LIKE '%mern%'
                THEN 'MERN Stack'

                WHEN LOWER(TRIM(course))
                     IN (
                         'da',
                         'data analytic',
                         'data analytics',
                         'data-analytics'
                     )
                THEN 'Data Analytics'

                ELSE NULL

            END AS course,


            -- ------------------------------------------------
            -- 9. CLEAN ENROLLMENT DATE
            -- ------------------------------------------------

            -- Different rows may contain different date formats.
            --
            -- Example:
            -- 2025-02-02
            -- 2024/01/01
            -- 20250605
            -- 20-06-2025
            -- 19/07/2025
            -- 7-May-2024
            -- Oct 1, 2025
            --
            -- safe_date() is a custom PostgreSQL function.
            -- It attempts to convert the text into a DATE.
            -- If conversion fails, it returns NULL.
            --
            -- COALESCE():
            -- Returns the FIRST value that is NOT NULL.
            --
            -- So PostgreSQL tries the first format.
            -- If NULL, it tries the second format.
            -- It continues until a valid date is found.

            COALESCE(

                safe_date(TRIM(enroll_date), 'YYYY-MM-DD'),

                safe_date(TRIM(enroll_date), 'YYYY/MM/DD'),

                safe_date(TRIM(enroll_date), 'YYYYMMDD'),

                safe_date(TRIM(enroll_date), 'DD-MM-YYYY'),

                safe_date(TRIM(enroll_date), 'DD/MM/YYYY'),

                safe_date(TRIM(enroll_date), 'FMDD-Mon-YYYY'),

                safe_date(TRIM(enroll_date), 'Mon FMDD, YYYY')

            ) AS enroll_date,


            -- ------------------------------------------------
            -- 10. CLEAN FEE
            -- ------------------------------------------------

            -- IMPORTANT:
            -- The original fee text was converted into a number
            -- in Layer 1.
            --
            -- That numeric value is available as f.amt.
            --
            -- Now we apply business rules to fix incorrect amounts.
            --
            -- CASE checks each condition from top to bottom.

            CASE

                -- If fee is NULL, keep it NULL.
                -- Example: pending payment.

                WHEN f.amt IS NULL
                THEN NULL


                -- Zero means free admission or scholarship.

                WHEN f.amt = 0
                THEN 0


                -- Amounts below 1000 are treated as invalid.

                WHEN f.amt < 1000
                THEN NULL


                -- If amount is below 10000,
                -- multiply by 10.
                --
                -- Example:
                -- 1500 becomes 15000.

                WHEN f.amt < 10000
                THEN f.amt * 10


                -- If amount is above 30000,
                -- divide by 10.
                --
                -- Example:
                -- 150000 becomes 15000.

                WHEN f.amt > 30000
                THEN f.amt / 10


                -- Otherwise keep the original amount.

                ELSE f.amt

            END::INT AS fee_paid,

            -- ::INT:
            -- Converts the final fee into an INTEGER.


            -- ------------------------------------------------
            -- 11. STANDARDIZE PAYMENT MODE
            -- ------------------------------------------------

            -- Multiple payment app names are standardized.
            --
            -- GPay, PhonePe, Paytm and UPI -> UPI
            -- Credit Card, Debit Card      -> Card
            -- NEFT, Bank Transfer          -> Bank Transfer

            CASE

                WHEN LOWER(TRIM(payment_mode))
                     IN ('upi', 'gpay', 'phonepe', 'paytm')
                THEN 'UPI'

                WHEN LOWER(TRIM(payment_mode))
                     IN ('card', 'credit card', 'debit card')
                THEN 'Card'

                WHEN LOWER(TRIM(payment_mode))
                     IN ('bank transfer', 'neft')
                THEN 'Bank Transfer'

                WHEN LOWER(TRIM(payment_mode)) = 'cash'
                THEN 'Cash'

                ELSE NULL

            END AS payment_mode,


            -- ------------------------------------------------
            -- 12. STANDARDIZE ENROLLMENT STATUS
            -- ------------------------------------------------

            -- Different spellings are converted into
            -- four standard status values.

            CASE

                WHEN LOWER(TRIM(status)) = 'active'
                THEN 'Active'

                WHEN LOWER(TRIM(status))
                     IN ('complete', 'completed', 'done')
                THEN 'Completed'

                WHEN LOWER(TRIM(status))
                     IN ('drop', 'dropped', 'left')
                THEN 'Dropped'

                WHEN LOWER(TRIM(status))
                     IN ('hold', 'on hold')
                THEN 'On Hold'

                ELSE NULL

            END AS status,


            -- ------------------------------------------------
            -- 13. CLEAN RATING
            -- ------------------------------------------------

            -- Rating can be stored in different formats.
            --
            -- Examples:
            -- five -> 5
            -- four -> 4
            -- 3/5  -> 3
            -- 4    -> 4
            -- 4.5  -> 4.5
            --
            -- SPLIT_PART():
            -- Splits text into parts using a separator.
            --
            -- SPLIT_PART('3/5', '/', 1)
            -- Returns '3'.
            --
            -- ::NUMERIC:
            -- Converts text into a numeric value.
            --
            -- NUMERIC(2,1):
            -- Allows up to 2 digits in total,
            -- with 1 digit after the decimal point.
            --
            -- Examples:
            -- 4   -> 4.0
            -- 4.5 -> 4.5

            CASE

                WHEN LOWER(TRIM(rating)) = 'five'
                THEN 5

                WHEN LOWER(TRIM(rating)) = 'four'
                THEN 4

                -- Validate the rating format first.
                --
                -- ^\d(\.\d)?(/5)?$
                --
                -- \d       One digit
                -- (\.\d)?  Optional decimal followed by one digit
                -- (/5)?    Optional /5
                -- ^ and $  Entire string must match.

                WHEN TRIM(rating) ~ '^\d(\.\d)?(/5)?$'

                     -- Extract the rating before /.
                     -- Convert it into NUMERIC.
                     -- Keep only values between 1 and 5.

                     AND SPLIT_PART(
                         TRIM(rating),
                         '/',
                         1
                     )::NUMERIC BETWEEN 1 AND 5

                THEN SPLIT_PART(
                    TRIM(rating),
                    '/',
                    1
                )::NUMERIC

                ELSE NULL

            END::NUMERIC(2,1) AS rating


        -- ====================================================
        -- LAYER 1: FEE EXTRACTION
        -- Alias: f
        -- ====================================================

        -- This layer reads the original raw table.
        -- It keeps every original column and creates
        -- one additional column called amt.

        FROM (

            SELECT

                -- r.*:
                -- Selects ALL columns from raw_enrollments.
                --
                -- This avoids writing every raw column manually.

                r.*,


                -- ------------------------------------------------
                -- EXTRACT NUMERIC FEE
                -- ------------------------------------------------

                CASE

                    -- If fee is written as 'free',
                    -- convert it into numeric zero.

                    WHEN LOWER(TRIM(r.fee_paid)) = 'free'
                    THEN 0


                    -- Validate the fee format using regex.
                    --
                    -- ^                   Beginning
                    -- \s*                 Optional spaces
                    -- (rs\.?|inr|₹)?      Optional currency symbol
                    -- -?                  Optional minus sign
                    -- [0-9,]+             Digits and commas
                    -- (\.\d+)?            Optional decimal
                    -- k?                  Optional k
                    -- \s*                 Optional spaces
                    -- $                   Ending
                    --
                    -- Examples:
                    -- Rs. 15,000
                    -- INR 15000
                    -- ₹15000
                    -- 15k
                    -- 15000.00

                    WHEN LOWER(r.fee_paid)
                         ~ '^\s*(rs\.?|inr|₹)?\s*-?[0-9,]+(\.\d+)?k?\s*$'

                    THEN

                        -- ABS():
                        -- Returns the absolute value.
                        -- Converts negative values into positive values.
                        --
                        -- Example:
                        -- ABS(-15000) = 15000

                        ABS(

                            -- REPLACE():
                            -- Removes a specific character from text.
                            --
                            -- First REGEXP_REPLACE removes:
                            -- Currency symbols, commas, spaces and k.
                            --
                            -- Example:
                            -- 'Rs. 15,000' -> '15000'
                            -- '15k'        -> '15'
                            --
                            -- Second REPLACE removes the minus sign.
                            --
                            -- ::NUMERIC converts the cleaned text
                            -- into a numeric value.

                            REPLACE(

                                REGEXP_REPLACE(
                                    LOWER(r.fee_paid),

                                    '(rs\.?|inr|₹|,|\s|k)',

                                    '',

                                    'g'
                                ),

                                '-',

                                ''

                            )::NUMERIC

                            *

                            -- If the original fee contains k,
                            -- multiply the extracted amount by 1000.
                            --
                            -- Example:
                            -- 15k = 15 * 1000 = 15000
                            --
                            -- CASE acts like an IF / ELSE condition.

                            CASE

                                WHEN LOWER(r.fee_paid) LIKE '%k%'
                                THEN 1000

                                ELSE 1

                            END

                        )

                    -- If the fee is pending, blank or invalid,
                    -- return NULL.

                    ELSE NULL

                END AS amt


            -- Original raw data source.

            FROM raw_enrollments AS r

            -- AS r:
            -- Gives the table a short alias 'r'.
            -- We can now write r.fee_paid instead of
            -- raw_enrollments.fee_paid.

        ) AS f

        -- The result of Layer 1 is named f.
        -- The numeric fee can now be accessed using f.amt.

    ) AS t

    -- The result of Layer 2 is named t.
    -- All cleaned columns are now available through t.

) AS d

-- The result of Layer 3 is named d.
-- It contains all cleaned columns plus rn.


-- ============================================================
-- FINAL FILTER: REMOVE DUPLICATE ENROLLMENT IDs
-- ============================================================

-- WHERE filters rows based on a condition.
--
-- rn = 1:
-- Keeps only the first row of each enrollment_id group.
--
-- rn = 2, 3, 4...
-- These duplicate rows are excluded.
--
-- Example:
--
-- WG-101 | Rohan | 1  KEEP
-- WG-101 | Rahul | 2  REMOVE
-- WG-102 | Amit  | 1  KEEP
--
-- The final table contains one row per enrollment_id.

WHERE rn = 1;

```
