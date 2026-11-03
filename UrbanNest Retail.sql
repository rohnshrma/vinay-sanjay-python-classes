-- =====================================================================
-- URBANNEST RETAIL : CASE-STUDY DATABASE  (PostgreSQL / pgAdmin 4)
-- Run this whole script once (F5). It is safe to run again: it starts fresh.
-- Tables: staff (8 rows), customers (24), products (14), orders (100)
-- =====================================================================

-- STEP 1: start fresh
DROP TABLE IF EXISTS orders, staff, products, customers CASCADE;

-- STEP 2: customers
CREATE TABLE customers (
  customer_id  SERIAL PRIMARY KEY,
  name         VARCHAR(50) NOT NULL,
  city         VARCHAR(30),                 -- may be NULL
  signup_date  DATE,
  channel      VARCHAR(10)                  -- 'Online' or 'Store'
);

INSERT INTO customers (name, city, signup_date, channel) VALUES
('Aditya Rao'      , 'Gurugram'   , '2024-11-03', 'Online'),   -- 1
('Meera Nair'      , 'Delhi'      , '2024-11-19', 'Store' ),   -- 2
('Kabir Khanna'    , 'Gurugram'   , '2024-12-02', 'Online'),   -- 3
('Neha Bansal'     , 'Noida'      , '2024-12-14', 'Online'),   -- 4
('Arjun Yadav'     , 'Gurugram'   , '2024-12-28', 'Store' ),   -- 5
('Pooja Saini'     , 'Faridabad'  , '2025-01-06', 'Online'),   -- 6
('Rahul Chauhan'   , 'Delhi'      , '2025-01-11', 'Store' ),   -- 7
('Simran Kaur'     , 'Gurugram'   , '2025-01-20', 'Online'),   -- 8
('Deepak Rawat'    , NULL         , '2025-01-27', 'Online'),   -- 9
('Tanya Arora'     , 'Noida'      , '2025-02-03', 'Store' ),   -- 10
('Manish Goel'     , 'Delhi'      , '2025-02-09', 'Online'),   -- 11
('Ritika Jain'     , ' gurugram ' , '2025-02-15', 'Online'),   -- 12
('Siddharth Bose'  , 'Bengaluru'  , '2025-02-22', 'Online'),   -- 13
('Kavya Iyer'      , 'Bengaluru'  , '2025-03-01', 'Online'),   -- 14
('Nikhil Dahiya'   , 'Gurugram'   , '2025-03-08', 'Store' ),   -- 15
('Ayesha Khan'     , 'Delhi'      , '2025-03-15', 'Online'),   -- 16
('Harsh Vardhan'   , NULL         , '2025-03-21', 'Store' ),   -- 17
('Divya Malik'     , 'Faridabad'  , '2025-03-29', 'Online'),   -- 18
('Yash Thakur'     , 'Noida'      , '2025-04-05', 'Online'),   -- 19
('Ishita Sethi'    , 'Gurugram'   , '2025-04-12', 'Store' ),   -- 20
('Gaurav Tomar'    , 'DELHI'      , '2025-04-19', 'Online'),   -- 21
('Sakshi Kohli'    , 'Gurugram'   , '2025-05-02', 'Online'),   -- 22
('Varun Bhatia'    , NULL         , '2025-05-16', 'Store' ),   -- 23
('Mehak Ahuja'     , 'Noida'      , '2025-06-01', 'Online');   -- 24

-- STEP 3: products
CREATE TABLE products (
  product_id    SERIAL PRIMARY KEY,
  product_name  VARCHAR(50) NOT NULL UNIQUE,
  category      VARCHAR(30),
  price         NUMERIC(10,2) CHECK (price > 0),        -- selling price (Rs)
  cost_price    NUMERIC(10,2) CHECK (cost_price > 0)    -- what UrbanNest pays the supplier (Rs)
);

INSERT INTO products (product_name, category, price, cost_price) VALUES
('Laptop Pro 14'        , 'Electronics',  58000,  49500),   -- 1
('Wireless Earbuds'     , 'Electronics',   2999,   1800),   -- 2
('Smartwatch'           , 'Electronics',   6499,   4600),   -- 3
('27-inch Monitor'      , 'Electronics',  14500,  11800),   -- 4
('Ergonomic Chair'      , 'Furniture'  ,   9500,   6200),   -- 5
('Study Table'          , 'Furniture'  ,   7200,   4900),   -- 6
('LED Desk Lamp'        , 'Furniture'  ,   1299,    700),   -- 7
('Python Crash Course'  , 'Books'      ,    749,    420),   -- 8
('SQL for Analysts'     , 'Books'      ,    599,    330),   -- 9
('Power BI Handbook'    , 'Books'      ,    899,    510),   -- 10
('Laptop Backpack'      , 'Accessories',   1799,    950),   -- 11
('USB-C Hub'            , 'Accessories',   2199,   1300),   -- 12
('Mechanical Keyboard'  , 'Accessories',   4599,   3100),   -- 13
('Standing Desk'        , 'Furniture'  ,  24999,  18500);   -- 14

-- STEP 4: staff (manager_id points to another row of the SAME table)
CREATE TABLE staff (
  staff_id    INT PRIMARY KEY,
  staff_name  VARCHAR(50) NOT NULL,
  role        VARCHAR(30),
  city        VARCHAR(30),
  manager_id  INT REFERENCES staff(staff_id)   -- NULL = has no manager (top boss)
);

INSERT INTO staff (staff_id, staff_name, role, city, manager_id) VALUES
(1, 'Rohit Malhotra' , 'Store Manager'  , 'Gurugram', NULL),
(2, 'Anjali Verma'   , 'Team Lead'      , 'Gurugram', 1),
(3, 'Sameer Gupta'   , 'Team Lead'      , 'Delhi'   , 1),
(4, 'Pankaj Singh'   , 'Sales Executive', 'Gurugram', 2),
(5, 'Nidhi Sharma'   , 'Sales Executive', 'Gurugram', 2),
(6, 'Imran Qureshi'  , 'Sales Executive', 'Delhi'   , 3),
(7, 'Lavanya Pillai' , 'Sales Executive', 'Delhi'   , 3),
(8, 'Chetan Joshi'   , 'Sales Executive', 'Pune'    , 3);

-- STEP 5: orders (100 rows). Created last because it points to three tables.
CREATE TABLE orders (
  order_id       SERIAL PRIMARY KEY,
  customer_id    INT REFERENCES customers(customer_id),   -- NULL = guest checkout
  product_id     INT REFERENCES products(product_id),
  staff_id       INT REFERENCES staff(staff_id),          -- who handled the sale
  quantity       INT DEFAULT 1 CHECK (quantity > 0),
  order_date     DATE NOT NULL,
  status         VARCHAR(20),                             -- 'Delivered', 'Cancelled', 'Returned'
  delivery_days  INT,                                     -- NULL when cancelled
  payment_mode   VARCHAR(10)                              -- 'UPI', 'Card', 'COD', 'EMI'
);

-- Columns: customer_id, product_id, staff_id, quantity, order_date, status, delivery_days, payment_mode
INSERT INTO orders (customer_id, product_id, staff_id, quantity, order_date, status, delivery_days, payment_mode) VALUES
(  12,  9, 8, 6, '2025-01-01', 'Delivered',    2, 'UPI' ),   -- 1
(   7, 11, 2, 1, '2025-01-02', 'Delivered',    1, 'Card'),   -- 2
(   1, 11, 4, 3, '2025-01-04', 'Delivered',    9, 'COD' ),   -- 3
(  16,  7, 3, 1, '2025-01-07', 'Delivered',    2, 'Card'),   -- 4
(   2,  5, 4, 1, '2025-01-09', 'Returned' ,    5, 'COD' ),   -- 5
(   9,  2, 2, 3, '2025-01-11', 'Delivered',    1, 'UPI' ),   -- 6
(  15,  5, 3, 1, '2025-01-12', 'Delivered',    9, 'COD' ),   -- 7
(   7,  5, 8, 1, '2025-01-14', 'Delivered',    3, 'UPI' ),   -- 8
(   4,  3, 7, 3, '2025-01-15', 'Delivered',    5, 'UPI' ),   -- 9
(   2,  3, 8, 2, '2025-01-17', 'Delivered',    3, 'UPI' ),   -- 10
(   1,  3, 2, 5, '2025-01-20', 'Delivered',    7, 'UPI' ),   -- 11
(  11,  5, 4, 1, '2025-01-20', 'Delivered',    4, 'UPI' ),   -- 12
(   8, 10, 3, 3, '2025-01-22', 'Cancelled', NULL, 'UPI' ),   -- 13
(   1,  2, 3, 1, '2025-01-25', 'Cancelled', NULL, 'COD' ),   -- 14
(   6, 13, 7, 1, '2025-01-26', 'Delivered',    2, 'Card'),   -- 15
(   8,  3, 6, 1, '2025-01-29', 'Delivered',    3, 'Card'),   -- 16
(   4, 13, 2, 4, '2025-01-29', 'Delivered',    6, 'COD' ),   -- 17
(NULL, 13, 8, 3, '2025-01-31', 'Delivered',    4, 'Card'),   -- 18
(   4,  4, 4, 1, '2025-02-02', 'Delivered',    3, 'UPI' ),   -- 19
(   4, 10, 4, 3, '2025-02-04', 'Delivered',    3, 'Card'),   -- 20
(   9, 11, 4, 2, '2025-02-06', 'Delivered',    4, 'Card'),   -- 21
(  10, 10, 4, 1, '2025-02-07', 'Delivered',    2, 'UPI' ),   -- 22
(   9, 10, 8, 5, '2025-02-10', 'Delivered',    1, 'UPI' ),   -- 23
(  15, 12, 7, 3, '2025-02-11', 'Delivered',    4, 'Card'),   -- 24
(   8,  9, 2, 1, '2025-02-14', 'Returned' ,    5, 'Card'),   -- 25
(  10, 11, 7, 2, '2025-02-15', 'Delivered',    3, 'EMI' ),   -- 26
(  15,  2, 8, 3, '2025-02-16', 'Returned' ,    5, 'EMI' ),   -- 27
(   4,  5, 3, 1, '2025-02-19', 'Delivered',    4, 'UPI' ),   -- 28
(   5,  3, 3, 4, '2025-02-20', 'Delivered',    4, 'UPI' ),   -- 29
(  17, 11, 8, 5, '2025-02-22', 'Delivered',    2, 'COD' ),   -- 30
(  10,  7, 5, 2, '2025-02-25', 'Delivered',    1, 'Card'),   -- 31
(  15, 13, 6, 1, '2025-02-25', 'Returned' ,    4, 'Card'),   -- 32
(   3, 10, 7, 1, '2025-02-27', 'Delivered',    4, 'UPI' ),   -- 33
(   1,  9, 5, 2, '2025-03-02', 'Delivered',    1, 'COD' ),   -- 34
(  15,  2, 4, 1, '2025-03-04', 'Delivered',    4, 'UPI' ),   -- 35
(  11,  8, 2, 1, '2025-03-06', 'Delivered',    2, 'UPI' ),   -- 36
(   6,  2, 2, 2, '2025-03-07', 'Delivered',    1, 'EMI' ),   -- 37
(   7,  9, 3, 6, '2025-03-09', 'Returned' ,    3, 'UPI' ),   -- 38
(   1,  2, 6, 3, '2025-03-10', 'Delivered',    2, 'Card'),   -- 39
(   9, 12, 3, 1, '2025-03-12', 'Delivered',    1, 'COD' ),   -- 40
(   9,  7, 2, 5, '2025-03-14', 'Returned' ,    1, 'UPI' ),   -- 41
(   9,  7, 7, 6, '2025-03-16', 'Delivered',    6, 'COD' ),   -- 42
(  17,  8, 6, 2, '2025-03-18', 'Delivered',    3, 'Card'),   -- 43
(   1,  3, 2, 3, '2025-03-20', 'Delivered',    2, 'Card'),   -- 44
(   1, 10, 4, 6, '2025-03-22', 'Cancelled', NULL, 'Card'),   -- 45
(   5,  9, 5, 4, '2025-03-23', 'Delivered',    7, 'UPI' ),   -- 46
(   9,  8, 5, 5, '2025-03-24', 'Delivered',    7, 'UPI' ),   -- 47
(   8, 11, 7, 1, '2025-03-27', 'Returned' ,    4, 'UPI' ),   -- 48
(   7,  8, 8, 3, '2025-03-28', 'Delivered',    2, 'COD' ),   -- 49
(   3,  1, 6, 1, '2025-03-30', 'Cancelled', NULL, 'EMI' ),   -- 50
(   8,  7, 6, 2, '2025-04-02', 'Delivered',    3, 'UPI' ),   -- 51
(   9,  9, 4, 4, '2025-04-02', 'Cancelled', NULL, 'Card'),   -- 52
(  13, 12, 6, 3, '2025-04-04', 'Delivered',    5, 'UPI' ),   -- 53
(   5, 10, 7, 6, '2025-04-07', 'Delivered',    5, 'EMI' ),   -- 54
(  17, 11, 3, 2, '2025-04-08', 'Delivered',    2, 'UPI' ),   -- 55
(  17,  3, 3, 1, '2025-04-11', 'Delivered',    5, 'Card'),   -- 56
(  10,  9, 5, 1, '2025-04-12', 'Returned' ,    7, 'COD' ),   -- 57
(  15,  2, 7, 1, '2025-04-13', 'Delivered',    1, 'UPI' ),   -- 58
(NULL, 11, 4, 3, '2025-04-16', 'Cancelled', NULL, 'UPI' ),   -- 59
(  20,  2, 8, 2, '2025-04-17', 'Delivered',    3, 'Card'),   -- 60
(  13,  8, 6, 3, '2025-04-20', 'Cancelled', NULL, 'Card'),   -- 61
(  14, 10, 5, 2, '2025-04-20', 'Delivered',    4, 'COD' ),   -- 62
(   4,  2, 7, 2, '2025-04-22', 'Delivered',    2, 'Card'),   -- 63
(  16,  2, 3, 3, '2025-04-24', 'Delivered',    4, 'UPI' ),   -- 64
(   9,  9, 4, 2, '2025-04-26', 'Delivered',    1, 'UPI' ),   -- 65
(   1,  2, 4, 3, '2025-04-28', 'Delivered',    2, 'UPI' ),   -- 66
(   3,  2, 4, 5, '2025-04-29', 'Returned' ,    1, 'EMI' ),   -- 67
(  15,  4, 5, 1, '2025-05-02', 'Returned' ,    3, 'Card'),   -- 68
(   7,  7, 2, 5, '2025-05-04', 'Returned' ,    3, 'COD' ),   -- 69
(  16,  7, 2, 1, '2025-05-05', 'Delivered',    2, 'EMI' ),   -- 70
(  14, 10, 4, 1, '2025-05-08', 'Delivered',    3, 'COD' ),   -- 71
(  20, 11, 5, 2, '2025-05-09', 'Delivered',    3, 'Card'),   -- 72
(  15,  9, 8, 1, '2025-05-11', 'Delivered',    7, 'EMI' ),   -- 73
(   4,  8, 5, 2, '2025-05-12', 'Cancelled', NULL, 'Card'),   -- 74
(  10, 12, 7, 2, '2025-05-14', 'Returned' ,    2, 'COD' ),   -- 75
(  18,  2, 2, 1, '2025-05-17', 'Delivered',    3, 'UPI' ),   -- 76
(  20,  2, 8, 5, '2025-05-18', 'Delivered',    3, 'COD' ),   -- 77
(  20,  8, 2, 3, '2025-05-20', 'Delivered',    7, 'COD' ),   -- 78
(   3,  3, 3, 3, '2025-05-21', 'Delivered',    2, 'UPI' ),   -- 79
(  18, 13, 8, 2, '2025-05-23', 'Delivered',    1, 'UPI' ),   -- 80
(  11,  4, 5, 1, '2025-05-25', 'Delivered',    2, 'UPI' ),   -- 81
(  12,  3, 7, 1, '2025-05-26', 'Delivered',    4, 'Card'),   -- 82
(  18,  8, 3, 4, '2025-05-28', 'Delivered',    5, 'COD' ),   -- 83
(NULL,  1, 7, 1, '2025-05-31', 'Delivered',    5, 'UPI' ),   -- 84
(   4,  3, 2, 2, '2025-06-02', 'Delivered',    4, 'UPI' ),   -- 85
(   4,  7, 3, 4, '2025-06-03', 'Delivered',    3, 'UPI' ),   -- 86
(  19,  5, 7, 1, '2025-06-05', 'Delivered',    7, 'Card'),   -- 87
(  11,  7, 7, 3, '2025-06-06', 'Delivered',    4, 'Card'),   -- 88
(  19,  2, 5, 1, '2025-06-09', 'Cancelled', NULL, 'UPI' ),   -- 89
(   3,  1, 6, 1, '2025-06-10', 'Returned' ,    4, 'Card'),   -- 90
(   7,  7, 6, 4, '2025-06-12', 'Delivered',    5, 'COD' ),   -- 91
(   8,  2, 5, 2, '2025-06-14', 'Delivered',    1, 'EMI' ),   -- 92
(   5,  8, 3, 4, '2025-06-16', 'Delivered',    1, 'UPI' ),   -- 93
(  17,  8, 3, 1, '2025-06-17', 'Delivered',    7, 'UPI' ),   -- 94
(   1,  3, 3, 2, '2025-06-20', 'Delivered',    5, 'COD' ),   -- 95
(  14, 13, 5, 2, '2025-06-21', 'Delivered',    4, 'UPI' ),   -- 96
(   8,  3, 3, 1, '2025-06-22', 'Delivered',    1, 'COD' ),   -- 97
(  12, 10, 5, 2, '2025-06-25', 'Returned' ,    1, 'UPI' ),   -- 98
(   4, 11, 5, 3, '2025-06-27', 'Returned' ,    1, 'EMI' ),   -- 99
(   7, 12, 2, 1, '2025-06-28', 'Cancelled', NULL, 'COD' );   -- 100

-- STEP 6: check your work (highlight one line at a time, press F5)
SELECT * FROM customers;   -- expect 24 rows
SELECT * FROM products;    -- expect 14 rows
SELECT * FROM staff;       -- expect 8 rows
SELECT * FROM orders;      -- expect 100 rows


select 'customers' as table_name, count(*) as total_rows from customers
union all
select 'products', count(*) from products
union all
select 'staff', count(*) from staff
union all
select 'orders', count(*) from orders;



select 
	count(*) 				as total_customers, -- every row
	count (city) 			as with_city,		-- only rows where city is not null
	count(distinct city)	as distinct_cities  -- unique city values, (null ignored)
from customers;


select name, city
from customers
order by city; 				-- null come at the bottom in PSQ when  sorting a - z



select 
	count(*) 					as total_orders, 			-- all 100 rows
	count(customer_id)			as orders_with_customers,	-- skips guest orders (null)
	count(delivery_days)		as orders_with_delivery,	-- skips cancelled orders (null)
	count(distinct customer_id) as customers_who_ordered,	-- each customer counted once
	count(distinct product_id)	as products_sold			-- each product counted once
from orders;



insert into products (product_name, category, price , cost_price)
values ('Smartwatch', 'Electronics', 5999 , 4000);


insert into products (product_name, category, price , cost_price)
values('Free Stickers', 'Accessories', 0, 1);


insert into orders (customer_id , product_id , staff_id , quantity , order_date, status)
values (1,2,3,0, '2025-07-01' , 'Delivered');

insert into orders (customer_id , product_id , staff_id , quantity , order_date, status)
values (99,2,3 ,4, '2025-07-01' , 'Delivered');

insert into orders (customer_id , product_id , staff_id  , order_date, status , delivery_days , payment_mode)
values (1, 2 ,3 , '2025-07-01' , 'Delivered' , 2, 'UPI');

select * from orders
where order_date = '2025-07-01';

-- part b

select 
	o.order_id,
	o.order_date,
	c.name,
	p.product_name,
	p.category,
	o.quantity,
	p.price,
	o.status
from orders o

inner join customers c using (customer_id)
inner join products p using (product_id)
order by o.order_date;


select p.category, count (*) as total_orders
from orders o
inner join products p using(product_id)
group by p.category
order by p.category;










select 
	o.order_id,
	o.order_date,
	c.name,
	p.product_name,
	p.category,
	o.quantity,
	p.price,
	o.status
from orders o

inner join customers c using (customer_id)
inner join products p using (product_id)
where p.category = 'Electronics'
	and o.status = 'Delivered'
order by p.price, o.order_id;


select
	c.customer_id,
	c.name,
	o.order_id,
	o.status
from customers c
full outer join orders o using(customer_id)
order by c.customer_id , o.order_id;


select
	p.product_id,
	p.product_name,
	p.category,
	o.order_id
from orders o
right join products p using (product_id)
order by p.product_id , o.order_id;