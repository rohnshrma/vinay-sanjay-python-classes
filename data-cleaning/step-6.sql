-- GOAL: bring many different spellings down to one small, fixed list of allowed values.
-- CASE works just like IF / ELSE IF / ELSE. The first WHEN which is TRUE wins, rest are ignored.

-- 6A. Gender: 'M', 'male', 'MALE' -> 'Male'; 'F', 'female', 'Femal' -> 'Female'.
UPDATE stg_enrollments
SET gender = CASE
    WHEN LOWER(gender) IN ('m', 'male')   THEN 'Male'     -- exact list of the male spellings we know
    WHEN LOWER(gender) LIKE 'f%'          THEN 'Female'   -- LIKE 'f%' means "starts with f", so even the typo 'Femal' is caught
    WHEN gender IS NULL                   THEN NULL       -- missing stays missing, we will decide about it later
    ELSE 'Other'                                          -- anything else which we did not expect
END;

-- 6B. Course: ILIKE is a LIKE which ignores capital/small letters (special feature of PostgreSQL). % means any characters.
UPDATE stg_enrollments
SET course = CASE
    WHEN course ILIKE '%mern%'              THEN 'MERN Stack'      -- 'mern', 'Full Stack (MERN)', 'Mern-Stack'
    WHEN course ILIKE '%data%analytic%'
      OR UPPER(course) = 'DA'               THEN 'Data Analytics'  -- 'Data-Analytics', 'Data Analytic', 'DA'
    ELSE NULL                                                       -- unknown course -> treat as missing
END;

-- 6C. Payment mode: put all the wallets/apps under one business category.
UPDATE stg_enrollments
SET payment_mode = CASE
    WHEN LOWER(payment_mode) IN ('upi', 'gpay', 'phonepe', 'paytm') THEN 'UPI'
    WHEN LOWER(payment_mode) = 'cash'                               THEN 'Cash'
    WHEN LOWER(payment_mode) LIKE '%card%'                          THEN 'Card'
    WHEN LOWER(payment_mode) IN ('neft', 'bank transfer')           THEN 'Bank Transfer'
    ELSE NULL
END;

-- 6D. Status.
UPDATE stg_enrollments
SET status = CASE
    WHEN LOWER(status) = 'active'                          THEN 'Active'
    WHEN LOWER(status) IN ('completed', 'complete', 'done') THEN 'Completed'
    WHEN LOWER(status) IN ('dropped', 'drop', 'left')      THEN 'Dropped'
    WHEN LOWER(status) IN ('on hold', 'hold')              THEN 'On Hold'
    ELSE NULL
END;

-- Check: every column should now show only the allowed values (plus NULL).
SELECT gender,       COUNT(*) FROM stg_enrollments GROUP BY gender;
SELECT course,       COUNT(*) FROM stg_enrollments GROUP BY course;
SELECT payment_mode, COUNT(*) FROM stg_enrollments GROUP BY payment_mode;
SELECT status,       COUNT(*) FROM stg_enrollments GROUP BY status;
