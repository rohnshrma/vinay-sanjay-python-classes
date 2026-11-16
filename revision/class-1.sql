
-- Clean start: remove old tables if you ran this before
DROP TABLE IF EXISTS students, staff, courses, time_slots;

-- TABLE 1: students of our institute
CREATE TABLE students (
    student_id  INT PRIMARY KEY,   -- unique roll number
    name        VARCHAR(50),       -- student name
    city        VARCHAR(30),       -- where the student lives
    gender      CHAR(1),           -- M or F
    course      VARCHAR(30),       -- MERN, Data Analytics or Python
    fee_paid    INT,               -- fee paid in rupees
    marks       INT,               -- final test marks (NULL = test not given yet)
    join_date   DATE,              -- admission date
    referred_by INT                -- roll number of the student who referred them
);

INSERT INTO students VALUES
(1,  'Aarav Sharma',   'Gurugram',  'M', 'MERN',           15000, 82,   '2026-01-10', NULL),
(2,  'Priya Verma',    'Delhi',     'F', 'Data Analytics', 23000, 91,   '2026-01-15', 1),
(3,  'Rahul Yadav',    'Gurugram',  'M', 'Data Analytics', 15000, 67,   '2026-02-02', 1),
(4,  'Sneha Gupta',    'Noida',     'F', 'MERN',           18000, 74,   '2026-02-10', 2),
(5,  'Vikas Singh',    'Faridabad', 'M', 'Python',         12000, 58,   '2026-02-20', NULL),
(6,  'Anjali Mehta',   'Delhi',     'F', 'MERN',           23000, 88,   '2026-03-05', 4),
(7,  'Karan Malhotra', 'Gurugram',  'M', 'Python',         10000, 45,   '2026-03-12', 3),
(8,  'Pooja Rani',     'Noida',     'F', 'Data Analytics', 15000, 79,   '2026-03-18', 2),
(9,  'Rohit Kumar',    'Faridabad', 'M', 'MERN',           15000, 63,   '2026-04-01', NULL),
(10, 'Neha Joshi',     'Gurugram',  'F', 'Python',         12000, 95,   '2026-04-08', 6),
(11, 'Amit Chauhan',   'Delhi',     'M', 'Data Analytics', 20000, 71,   '2026-04-15', 6),
(12, 'Simran Kaur',    'Gurugram',  'F', 'MERN',           15000, 86,   '2026-05-02', 10),
(13, 'Deepak Saini',   'Noida',     'M', 'Python',          8000, 52,   '2026-05-10', NULL),
(14, 'Kavya Nair',     'Delhi',     'F', 'MERN',           23000, NULL, '2026-05-18', 6),
(15, 'Manish Tiwari',  'Gurugram',  'M', 'Data Analytics', 15000, 60,   '2026-05-25', 12);

-- TABLE 2: staff of the institute (manager_id points to another staff member)
CREATE TABLE staff (
    staff_id   INT PRIMARY KEY,    -- unique staff number
    name       VARCHAR(50),        -- staff name
    role       VARCHAR(30),        -- job role
    salary     INT,                -- monthly salary in rupees
    manager_id INT                 -- staff_id of their boss (NULL = no boss)
);

INSERT INTO staff VALUES
(1, 'Rakesh Arora',  'Director',          90000, NULL),
(2, 'Meena Kapoor',  'Centre Head',       50000, 1),
(3, 'Ajay Thakur',   'Trainer',           35000, 2),
(4, 'Ritu Bansal',   'Trainer',           32000, 2),
(5, 'Sunil Rawat',   'Senior Counsellor', 25000, 2),
(6, 'Nisha Pandey',  'Counsellor',        18000, 5),
(7, 'Gaurav Negi',   'Office Assistant',  12000, 2);

-- TABLE 3: courses we sell
CREATE TABLE courses (
    course_name     VARCHAR(30) PRIMARY KEY,  -- course name
    duration_months INT,                      -- how long the course runs
    fee             INT                       -- full listed fee in rupees
);

INSERT INTO courses VALUES
('MERN',           6, 23000),
('Data Analytics', 4, 23000),
('Python',         3, 12000);

-- TABLE 4: batch timings available in the institute
CREATE TABLE time_slots (
    slot_name VARCHAR(20),          -- name of the slot
    timing    VARCHAR(20)           -- actual time
);

INSERT INTO time_slots VALUES
('Morning',   '9 AM - 11 AM'),
('Afternoon', '2 PM - 4 PM'),
('Evening',   '6 PM - 8 PM');



--  and
select name , city, course
from students
where city = 'Gurugram' and course = 'MERN';


-- or
select name, city
from students
where city = 'Delhi'
or city = 'Noida';




select name , city, course
from students
where course ='MERN' and (city = 'Delhi' or city = 'Noida');


select name, city, marks
from students
where city not in ('Gurugram')
and marks between 70 and 90;




-- order by 



select name, city
from students 
order by name;




select name , marks
from students 
order by marks desc nulls last
limit 3;



select name, city, fee_paid
from students
order by city asc, fee_paid desc;





select city , count(*) as total_students
from students
group by city
order by total_students desc;





select city, count(*) as total_students
from students
group by city
having count(*) > 3;


select course , sum (fee_paid) as total_fee
from students
group by course
having sum (fee_paid) > 80000
order by total_fee desc;


-- Task 1. How many male and how many female students do we have?

-- Question: which cities have at least 2 students who paid ₹15,000 or more?

--  For each city, show the highest and the lowest fee paid.

-- Count students for every course + city combination. Sort by course, then city.


