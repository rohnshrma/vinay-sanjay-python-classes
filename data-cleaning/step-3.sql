-- GOAL: '  gaurav   gupta ' should become 'gaurav gupta'.
-- TRIM() removes spaces at the start/end. REGEXP_REPLACE(x, '\s+', ' ', 'g') turns
-- any run of spaces/tabs/newlines into ONE space. 'g' = global (replace every match, not just the first).

UPDATE stg_enrollments                                     -- UPDATE changes existing rows
SET enrollment_id = TRIM(REGEXP_REPLACE(enrollment_id, '\s+', ' ', 'g')),  -- clean the ID
    full_name     = TRIM(REGEXP_REPLACE(full_name,     '\s+', ' ', 'g')),  -- clean the name
    gender        = TRIM(gender),                         -- single-word columns only need TRIM
    age           = TRIM(age),
    email         = TRIM(email),
    phone         = TRIM(phone),
    city          = TRIM(REGEXP_REPLACE(city,   '\s+', ' ', 'g')),
    course        = TRIM(REGEXP_REPLACE(course, '\s+', ' ', 'g')),
    enroll_date   = TRIM(enroll_date),
    fee_paid      = TRIM(fee_paid),
    payment_mode  = TRIM(REGEXP_REPLACE(payment_mode, '\s+', ' ', 'g')),
    status        = TRIM(status),
    rating        = TRIM(rating);
-- No WHERE clause = every row is updated. TRIM(NULL) is still NULL, so NULLs are safe.

-- Check: this should now return 0 rows (no value starts or ends with a space).
SELECT full_name FROM stg_enrollments
WHERE full_name <> TRIM(full_name);       -- <> means "not equal"