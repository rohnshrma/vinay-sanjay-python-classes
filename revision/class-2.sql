-- Clean start: remove old tables if you ran this before
DROP TABLE IF EXISTS payments, students, leads, staff, courses, time_slots;

-- TABLE 1: courses we sell, with the listed (full) fee
CREATE TABLE courses (
    course_id   INT PRIMARY KEY,   -- course number
    course_name VARCHAR(30),       -- course name
    list_fee    INT                -- full fee written in the brochure
);
INSERT INTO courses VALUES
(1, 'MERN',              23000),
(2, 'Data Analytics',    23000),
(3, 'Python',            12000),
(4, 'Digital Marketing', 15000);

-- TABLE 2: staff (manager_id points to another staff row)
CREATE TABLE staff (
    staff_id   INT PRIMARY KEY,    -- staff number
    name       VARCHAR(50),        -- staff name
    role       VARCHAR(30),        -- job role
    salary     INT,                -- monthly salary in rupees
    manager_id INT,                -- staff_id of their boss (NULL = top)
    joined_on  DATE                -- joining date
);
INSERT INTO staff VALUES
(1, 'Rakesh Arora', 'Director',          90000, NULL, '2022-04-01'),
(2, 'Meena Kapoor', 'Centre Head',       50000, 1,    '2023-01-10'),
(3, 'Ajay Thakur',  'Trainer',           35000, 2,    '2023-06-01'),
(4, 'Ritu Bansal',  'Trainer',           38000, 2,    '2024-02-15'),
(5, 'Sunil Rawat',  'Senior Counsellor', 25000, 2,    '2022-11-01'),
(6, 'Nisha Pandey', 'Counsellor',        18000, 5,    '2025-01-05'),
(7, 'Arjun Mehra',  'Counsellor',        20000, 5,    '2024-07-20'),
(8, 'Gaurav Negi',  'Office Assistant',  12000, 2,    '2025-03-01');

-- TABLE 3: leads = every enquiry that came in (the CRM)
CREATE TABLE leads (
    lead_id       INT PRIMARY KEY, -- enquiry number
    name          VARCHAR(50),     -- person who enquired
    city          VARCHAR(30),     -- their city
    source        VARCHAR(20),     -- where the lead came from
    course_id     INT,             -- course they asked about
    counsellor_id INT,             -- staff who handled the lead
    enquiry_date  DATE,            -- date of enquiry
    status        VARCHAR(20)      -- Converted / Lost / Follow-up
);
INSERT INTO leads VALUES
(1,  'Aarav Sharma',  'Gurugram',  'Instagram', 1, 6, '2026-08-02', 'Converted'),
(2,  'Priya Verma',   'Delhi',     'Google',    2, 7, '2026-08-04', 'Converted'),
(3,  'Ravi Kumar',    'Gurugram',  'JustDial',  3, 6, '2026-08-05', 'Lost'),
(4,  'Sneha Gupta',   'Noida',     'Referral',  1, 5, '2026-08-09', 'Converted'),
(5,  'Mohit Jain',    'Delhi',     'Instagram', 2, 6, '2026-08-12', 'Lost'),
(6,  'Anjali Mehta',  'Gurugram',  'Walk-in',   4, 7, '2026-08-15', 'Converted'),
(7,  'Tarun Bhatia',  'Faridabad', 'Google',    1, 7, '2026-08-20', 'Follow-up'),
(8,  'Karan Malhotra','Gurugram',  'Walk-in',   3, 5, '2026-08-22', 'Converted'),
(9,  'Isha Arora',    'Noida',     'Instagram', 2, 6, '2026-08-28', 'Lost'),
(10, 'Rohit Kumar',   'Faridabad', 'Google',    1, 7, '2026-09-01', 'Converted'),
(11, 'Neha Joshi',    'Gurugram',  'Referral',  3, 5, '2026-09-03', 'Converted'),
(12, 'Varun Sethi',   'Delhi',     'JustDial',  4, 6, '2026-09-06', 'Lost'),
(13, 'Amit Chauhan',  'Delhi',     'Google',    2, 7, '2026-09-10', 'Converted'),
(14, 'Pallavi Rao',   'Gurugram',  'Instagram', 1, 6, '2026-09-14', 'Follow-up'),
(15, 'Simran Kaur',   'Gurugram',  'Referral',  1, 5, '2026-09-18', 'Converted'),
(16, 'Yash Goel',     'Noida',     'Instagram', 3, 6, '2026-09-21', 'Lost'),
(17, 'Deepak Saini',  'Noida',     'Walk-in',   4, 7, '2026-09-25', 'Converted'),
(18, 'Ritika Das',    'Delhi',     'Google',    2, 7, '2026-09-29', 'Lost'),
(19, 'Kavya Nair',    'Delhi',     'Referral',  1, 5, '2026-10-02', 'Converted'),
(20, 'Harsh Vardhan', 'Gurugram',  'Instagram', 2, 6, '2026-10-05', 'Follow-up'),
(21, 'Manish Tiwari', 'Gurugram',  'Google',    2, 7, '2026-10-08', 'Converted'),
(22, 'Sakshi Malik',  'Faridabad', 'JustDial',  3, 6, '2026-10-12', 'Lost'),
(23, 'Nikhil Batra',  'Gurugram',  'Walk-in',   1, 5, '2026-10-15', 'Follow-up'),
(24, 'Tanvi Shah',    'Noida',     'Instagram', 4, 6, '2026-10-20', 'Lost'),
(25, 'Arpit Jain',    'Delhi',     'Referral',  2, 5, '2026-10-24', 'Converted'),
(26, 'Tarun Bhatia',  'Faridabad', 'Instagram', 1, 6, '2026-10-28', 'Follow-up');

-- TABLE 4: students = leads who actually took admission
CREATE TABLE students (
    student_id  INT PRIMARY KEY,   -- roll number
    lead_id     INT,               -- which enquiry they came from
    name        VARCHAR(50),       -- student name
    city        VARCHAR(30),       -- city
    course_id   INT,               -- course joined
    batch_slot  VARCHAR(20),       -- Morning / Afternoon / Evening
    trainer_id  INT,               -- staff_id of the trainer
    join_date   DATE,              -- admission date
    agreed_fee  INT,               -- fee finalised after discount
    referred_by INT                -- student_id of the referrer (NULL = nobody)
);
INSERT INTO students VALUES
(101, 1,  'Aarav Sharma',   'Gurugram',  1, 'Evening',   3, '2026-08-05', 15000, NULL),
(102, 2,  'Priya Verma',    'Delhi',     2, 'Morning',   4, '2026-08-08', 23000, NULL),
(103, 4,  'Sneha Gupta',    'Noida',     1, 'Evening',   3, '2026-08-12', 18000, 101),
(104, 6,  'Anjali Mehta',   'Gurugram',  4, 'Afternoon', 4, '2026-08-18', 15000, NULL),
(105, 8,  'Karan Malhotra', 'Gurugram',  3, 'Evening',   3, '2026-08-25', 10000, NULL),
(106, 10, 'Rohit Kumar',    'Faridabad', 1, 'Morning',   3, '2026-09-04', 15000, NULL),
(107, 11, 'Neha Joshi',     'Gurugram',  3, 'Morning',   3, '2026-09-06', 12000, 104),
(108, 13, 'Amit Chauhan',   'Delhi',     2, 'Evening',   4, '2026-09-12', 20000, NULL),
(109, 15, 'Simran Kaur',    'Gurugram',  1, 'Evening',   3, '2026-09-20', 15000, 107),
(110, 17, 'Deepak Saini',   'Noida',     4, 'Afternoon', 4, '2026-09-27', 12000, NULL),
(111, 19, 'Kavya Nair',     'Delhi',     1, 'Morning',   3, '2026-10-05', 23000, 103),
(112, 21, 'Manish Tiwari',  'Gurugram',  2, 'Evening',   4, '2026-10-10', 15000, NULL),
(113, 25, 'Arpit Jain',     'Delhi',     2, 'Morning',   4, '2026-10-27', 18000, 101);

-- TABLE 5: payments = every instalment received
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,    -- receipt number
    student_id INT,                -- who paid
    pay_date   DATE,               -- date of payment
    amount     INT,                -- amount in rupees
    mode       VARCHAR(10)         -- UPI / Cash / Card / EMI
);
INSERT INTO payments VALUES
(1,  101, '2026-08-05',  5000, 'UPI'),
(2,  102, '2026-08-08', 23000, 'Card'),
(3,  103, '2026-08-12',  6000, 'Cash'),
(4,  104, '2026-08-18', 15000, 'UPI'),
(5,  105, '2026-08-25',  5000, 'Cash'),
(6,  106, '2026-09-04',  5000, 'UPI'),
(7,  101, '2026-09-05',  5000, 'UPI'),
(8,  107, '2026-09-06', 12000, 'UPI'),
(9,  108, '2026-09-12', 10000, 'EMI'),
(10, 103, '2026-09-12',  6000, 'UPI'),
(11, 109, '2026-09-20',  5000, 'UPI'),
(12, 110, '2026-09-27',  6000, 'Cash'),
(13, 106, '2026-10-04',  5000, 'UPI'),
(14, 101, '2026-10-05',  5000, 'UPI'),
(15, 111, '2026-10-05', 10000, 'Card'),
(16, 112, '2026-10-10',  5000, 'UPI'),
(17, 108, '2026-10-12', 10000, 'EMI'),
(18, 109, '2026-10-20',  5000, 'UPI'),
(19, 110, '2026-10-27',  6000, 'Cash'),
(20, 113, '2026-10-27',  9000, 'UPI');

-- TABLE 6: batch timings
CREATE TABLE time_slots (
    slot_name VARCHAR(20),         -- Morning / Afternoon / Evening
    timing    VARCHAR(20)          -- actual time
);
INSERT INTO time_slots VALUES
('Morning',   '9 AM - 11 AM'),
('Afternoon', '2 PM - 4 PM'),
('Evening',   '6 PM - 8 PM');



SELECT lead_id , name, city , course_id
from leads
where status = 'Lost' and city in ('Delhi' , 'Noida') and course_id in (1,2);





select s.name, c.course_name , c.list_fee , s.agreed_fee
from students s
join courses c  on c.course_id = s.course_id
where s.batch_slot = 'Evening' and s.agreed_fee < c.list_fee;



select * from students limit 5;



select payment_id, student_id , pay_date,amount from payments
order by pay_date desc, payment_id desc
limit 5 offset 5;

select payment_id, student_id , pay_date,amount from payments
order by pay_date desc, payment_id desc
limit 5 offset 10;



select 
	s.name, 
	s.agreed_fee , 
	sum(p.amount)  as paid,
	s.agreed_fee - sum (p.amount) as pending
from students s
join payments p on p.student_id = s.student_id
group by s.student_id , s.name, s.agreed_fee
having s.agreed_fee - sum(p.amount) > 0
order by pending desc,s.name;
