-- GOAL: make the same thing look the same everywhere. 'wg-1001', ' WG-1001 ' and 'WG1001' are all ONE student only.

-- 5A. IDs -> always 'WG-' followed by the digits.
UPDATE stg_enrollments
SET enrollment_id = 'WG-' || REGEXP_REPLACE(enrollment_id, '[^0-9]', '', 'g');
-- [^0-9] means "any character which is NOT a digit". We replace all of them with '' so only the digits remain.
-- || is the string joining (concatenation) operator in PostgreSQL, so 'WG-' || '1001' gives 'WG-1001'.

-- 5B. Names -> Proper Case, and remove the full stop at the end.
UPDATE stg_enrollments
SET full_name = INITCAP(                    -- INITCAP: first letter of every word becomes capital, the rest small
                  RTRIM(full_name, '.')     -- RTRIM(x, '.') removes the '.' characters from the right end
                );

-- 5C. Emails are not case-sensitive, so we keep them all in lower case.
UPDATE stg_enrollments
SET email = LOWER(email);                   -- 'Rahul.Sharma@Gmail.com' becomes 'rahul.sharma@gmail.com'

-- Let us check a small sample.
SELECT enrollment_id, full_name, email
FROM stg_enrollments
ORDER BY row_id
LIMIT 10;
