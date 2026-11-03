-- GOAL: one consistent meaning for "missing". Right now missing data is stored as
-- NULL, '', 'N/A', 'NA', 'null', 'unknown', 'TBD'... SQL treats each as a different value.
-- We write a tiny reusable FUNCTION so we do not repeat the same CASE 12 times.

CREATE OR REPLACE FUNCTION nullify(val TEXT)   -- OR REPLACE = overwrite if it already exists
RETURNS TEXT                                   -- the function gives back text
LANGUAGE sql                                   -- written in plain SQL (not PL/pgSQL)
IMMUTABLE                                      -- same input -> always same output (lets Postgres optimise)
AS $$
    SELECT CASE
        WHEN val IS NULL THEN NULL                                         -- already NULL, keep it
        WHEN LOWER(TRIM(val)) IN ('', 'na', 'n/a', 'null', 'none',
                                  'unknown', 'tbd', '-', 'not sure')
             THEN NULL                                                     -- fake null -> real NULL
        ELSE val                                                           -- real value, keep as is
    END;
$$;                                            -- $$ ... $$ is just a quote that wraps the function body

-- Apply it to every text column.
UPDATE stg_enrollments
SET enrollment_id = nullify(enrollment_id),
    full_name     = nullify(full_name),
    gender        = nullify(gender),
    age           = nullify(age),
    email         = nullify(email),
    phone         = nullify(phone),
    city          = nullify(city),
    course        = nullify(course),
    enroll_date   = nullify(enroll_date),
    fee_paid      = nullify(fee_paid),
    payment_mode  = nullify(payment_mode),
    status        = nullify(status),
    rating        = nullify(rating);

-- Check: how many emails are truly missing now? (Compare with step 1B + 1C.)
SELECT COUNT(*) FILTER (WHERE email IS NULL) AS missing_emails   -- FILTER = count only rows matching the condition
FROM stg_enrollments;