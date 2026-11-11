# Subqueries

A **subquery** is a query written inside another query. The inner query runs first and gives its result to the outer query. You can put a subquery in the `SELECT` list, in the `FROM` clause, or in the `WHERE` clause.

`class1.sql` uses subqueries on the `raw_enrollments` table to check how dirty our data is, before we start cleaning.

## What is in `class1.sql`

### 1. Total rows vs unique students

Three subqueries in the `SELECT` list, each giving one number:

| Column | What it does |
|---|---|
| `total_rows` | `COUNT(*)` counts every row. |
| `ids_as_typed` | `COUNT(DISTINCT enrollment_id)` counts unique IDs, exactly as typed. `'STU101'` and `'stu101'` are counted as two. |
| `ids_after_trim` | Same count, but after `UPPER(TRIM(...))`, so `' stu101 '` and `'stu101'` become one ID. |

If `ids_after_trim` is less than `total_rows`, some students are repeated.

### 2. One-line data quality report

Four subqueries, each counting one type of problem. The result comes as a single row.

| Column | Problem it counts |
|---|---|
| `missing_name` | `full_name IS NULL` |
| `missing_email` | email is NULL, blank, `N/A`, `NA` or `NULL` (after `TRIM`, `UPPER`, `COALESCE`) |
| `bad_age` | age is not a number, or is outside 16 to 60 |
| `missing_course` | course is NULL, blank or `TBD` |

Points to remember:
- `COALESCE(x, '')` turns NULL into an empty string, so the `IN (...)` check can catch it.
- `~ '^\d+$'` is a regular expression meaning "digits only". We check this first, because `::int` would throw an error on text like `'abc'`.
- The `CASE` in `bad_age` returns `TRUE` for non-numeric ages, so they are counted as bad.

> The first, rough version of this report near the top of the file is a draft. Please use the second version (CHECK 2), which is the correct one.

### 3. Duplicate enrollment IDs after cleaning

This one uses a subquery in the `FROM` clause (also called a *derived table*).

- **Inner query:** cleans each ID with `UPPER(TRIM(...))` and `REGEXP_REPLACE(..., '^WG-?', 'WG-')`, so `wg101`, `WG101` and `WG-101` all become `WG-101`. Then it does `GROUP BY` the cleaned ID and counts the `copies`.
- **Outer query:** keeps only those IDs with `copies > 1` and sorts them, highest count first.

Why the subquery is needed: we cannot use the alias `copies` in `WHERE` in the same query where it is created. So we wrap it, and filter in the outer query.

## Quick revision

| Place of subquery | Used for |
|---|---|
| `SELECT` list | getting one single value (like a count) as a column |
| `FROM` clause | treating the result of a query like a temporary table |
| `WHERE` clause | filtering rows using the result of another query |
