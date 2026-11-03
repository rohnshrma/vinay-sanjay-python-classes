DROP TABLE  IF EXISTS orders, products, customers CASCADE;


-- creating a table structure
CREATE TABLE customers(
customer_id			SERIAL PRIMARY KEY,
name				VARCHAR(50) NOT NULL,
city				VARCHAR(30),
signup_date			DATE
);


-- read data
SELECT * FROM customers;


-- insert data
INSERT INTO 
customers(name, city , signup_date) 
VALUES
('Sanjay Kumar' , 'Gurugram', '2025-05-11'),
('Vinay Kumar' , 'Gurugram', '2025-06-11');



INSERT INTO customers (name, city, signup_date) VALUES
('Aarav Mehta',    'Gurugram',  '2025-01-05'),
('Priya Sharma',   'Delhi',     '2025-01-18'),
('Rohit Verma',    'Noida',     '2025-02-02'),
('Sneha Kapoor',   'Gurugram',  '2025-02-20'),
('Vikram Singh',   NULL,     '2025-03-11'),
('Ananya Gupta',   ' mumbai ',  '2025-03-25'),   -- messy on purpose (cleaned in Section 21)
('Karan Malhotra', NULL,        '2025-04-08'),   -- missing city on purpose
('Isha Reddy',     'Bengaluru', '2025-04-22');



CREATE TABLE products(
product_id		SERIAL PRIMARY KEY,
product_name	VARCHAR(50) NOT NULL  UNIQUE,
category		VARCHAR(30),
price 			NUMERIC(10, 2) CHECk(price > 0)
);



INSERT INTO products (product_name, category, price) VALUES
('Laptop',       'Electronics', 55000),
('Headphones',   'Electronics',  2500),
('Office Chair', 'Furniture',    8000),
('Desk Lamp',    'Furniture',    1200),
('Python Book',  'Books',         650),
('SQL Book',     'Books',         550);



CREATE TABLE orders (
  order_id     SERIAL PRIMARY KEY,
  customer_id  INT REFERENCES customers(customer_id),
  product_id   INT REFERENCES products(product_id),
  quantity     INT DEFAULT 1 CHECK (quantity > 0),
  order_date   DATE NOT NULL,
  status       VARCHAR(20)          -- 'Delivered', 'Cancelled', 'Returned'
);




INSERT INTO orders (customer_id, product_id, quantity, order_date, status) VALUES
(1, 1, 1, '2025-01-10', 'Delivered'),
(1, 2, 2, '2025-02-14', 'Delivered'),
(2, 5, 3, '2025-01-25', 'Delivered'),
(2, 3, 1, '2025-03-02', 'Cancelled'),
(3, 2, 1, '2025-02-10', 'Delivered'),
(3, 6, 2, '2025-03-15', 'Delivered'),
(4, 4, 2, '2025-03-01', 'Delivered'),
(4, 1, 1, '2025-04-05', 'Returned'),
(5, 3, 2, '2025-03-20', 'Delivered'),
(5, 5, 1, '2025-04-12', 'Delivered'),
(5, 2, 1, '2025-04-02', 'Delivered'),
(5, 6, 4, '2025-05-06', 'Delivered'),
(1, 4, 1, '2025-05-10', 'Delivered'),
(8, 1, 1, '2025-05-18', 'Delivered'),
(2, 2, 1, '2025-05-21', 'Delivered');
-- (customer 6 and 7) has never ordered. That's useful later.







select * from products;


ALTER TABLE customers ADD COLUMN email VARCHAR(100);
ALTER TABLE customers RENAME COLUMN email TO email_id;
ALTER TABLE customers ALTER COLUMN email_id TYPE  VARCHAR(150);
ALTER TABLE customers ADD CONSTRAINT uq_email UNIQUE (email_id);
alter table customers drop column email_id;

select * from customers; -- * means all columns

select name , city from customers; -- only the the columns you need

select distinct city from customers;



select 
product_name,
price,
price * 0.18 as gst,
price * 1.18 as price_with_gst
from products




delete from customers where city = 'Gurugram';



select * from products where price > 2000;


select * from customers where city = 'Delhi' or city = 'Noida';
select * from customers where city in ('Delhi' , 'Noida');
select * from customers where city not in ('Delhi' , 'Noida');



select * from orders
where order_date between '2025-03-01' and '2025-03-31'
and status = 'Delivered';



select  * from orders
where status = 'Delivered' and ( quantity >= 3  or order_date >= '2025-03-01' );


select * from products where product_name ilike '%book%';-- contains book
select * from customers where name like 'A%';-- starts with A


select * from customers where city is null;
select * from customers where city is not null;

select  * from products;


select product_name,price from products
order by price DESC;


select product_name,price from products
order by price;



select name, city from customers
order by city asc nulls last , name;



select product_name,price from products
order by price desc limit 3;


select product_name,price from products
order by price desc limit 3 offset 3;




-- UPDATE DELETE AND TRANSACTIONS

select * from products where product_name = 'SQL Book';


update products  set price = 599 where product_name = 'SQL Book';
update products  set price = 550 where product_name = 'SQL Book';



begin;
	delete from orders where status ='Cancelled';
	select COUNT(*) from orders;
rollback; -- undo everything since BEGIN (COMMIT would keep it)
	


select count(*) 					as total_order, -- count rows
count(customer_id)					as buyers, 
count(DISTINCT customer_id)			as unique_buyers, -- count unique people
sum(quantity)						as units_sold,
round(avg(quantity) , 2) 			as avg_qty,
min(order_date)			 			as first_order,
max(order_date) 					as last_order
from orders;



-- customer per city
select city, count(*) as customers
from customers
group by city
order by customers desc;


-- orders and units per status

select status, count(*) as orders , sum(quantity) as units
from orders
group by status;


-- group by two columns : order per customer per status

select customer_id, status, count(*) as orders
from orders
group by customer_id, status
order by customer_id desc;


-- having filters groups: customers with more than 2 orders
select customer_id, count(*) as orders
from orders
group by customer_id
having count(*) >= 2;


-- joins
-- inner join : only rows that matches on both sides  


-- each order with customer name

select 
	o.order_id,
	c.customer_id,
	c.name
from orders as o -- left table
join customers as c 
	on o.customer_id = c.customer_id;


-- each order with customer name, product and revenue

select 
	o.order_id,
	c.name,
	p.product_name,
	p.price,
	o.quantity,
	o.quantity * p.price as revenue
from orders as o
join customers as c on o.customer_id = c.customer_id
join products as p on o.product_id= p.product_id;


--  revenue by category (delivered only)
select 
	p.category,
	sum(o.quantity * p.price) as revenue
from orders o
join products p 
	on o.product_id = p.product_id
where o.status = 'Delivered'
group by p.category
order by revenue desc;






select * from customers;




-- all customers (even the ones who never ordered)

select 
	c.customer_id,
	c.name,
	o.order_id
from customers as c -- left table
left join orders as o  -- right table
	on o.customer_id = c.customer_id
order by c.customer_id ;

-- customers who never ordered (left join + is null trick)

select 
	c.name
from customers c
left join orders o on c.customer_id = o.customer_id
where o.order_id  is null;



-- all customers (even the ones who never ordered)

select 
	o.order_id,
	c.customer_id,
	c.name
from orders as o -- left table
right join customers as c  -- right table
	on o.customer_id = c.customer_id
order by c.customer_id ;




SELECT 
	c.customer_id,
	c.name,
	o.order_id,
	o.status
from customers c
full outer join orders o
	on c.customer_id = o.customer_id
order by c.customer_id;



select 
	c1.name customer_1,
	c1.city,
	c2.name customer_2
from customers c1
join customers c2
	on c1.city = c2.city and c1.customer_id < c2.customer_id;


select 
	o1.customer_id,
	o1.order_id as orders_1,
	o2.order_id as orders_2
from orders as o1
join orders as o2
	on o1.customer_id = o2.customer_id
	and o1.order_id < o2.order_id
order by o1.customer_id, orders_1;






select 
	c.name,
	p.product_name,
	p.price
from customers c
cross join products as p;



select count(*) from customers;


select customer_id from orders join products using (product_id) where category = 'Books'
union
select customer_id from orders join products using (product_id) where category = 'Electronics'
order by customer_id;


select customer_id from orders join products using (product_id) where category = 'Books'
union all
select customer_id from orders join products using (product_id) where category = 'Electronics'
order by customer_id;


select customer_id from orders join products using (product_id) where category = 'Books'
intersect
select customer_id from orders join products using (product_id) where category = 'Electronics'
order by customer_id;



select customer_id from orders join products using (product_id) where category = 'Electronics'
except
select customer_id from orders join products using (product_id) where category = 'Books'
order by customer_id;



select product_name, price,
	case
		when price >= 10000 then 'Premium'
		when price >= 1000 then 'Mid'
		else 'Budget'
	end as price_range
from products;



SELECT
  ROUND(1234.567, 1)  AS round_1,   -- 1234.6
  CEIL(4.1)           AS ceil,      -- 5   (always up)
  FLOOR(4.9)          AS floor,     -- 4   (always down)
  ABS(-250)           AS absolute,  -- 250
  POWER(2, 10)        AS power,     -- 1024
  MOD(17, 5)          AS remainder, -- 2
  SQRT(144)           AS sqrt;      -- 12



SELECT
	product_name, 
	price, 
	case 
		when price >= 10000 then 'Premium'
		when price >= 1000 then 'Mid-Range'
		else 'Budget'
	end as price_range
from products;



select 
	order_id,
	status,
	case status
		when 'Delivered' then 'DEL'
		when 'Returned' then 'RET'
		when 'Cancelled' then 'CAN'
		else 'UNK'
	end as status_label
from orders;


select order_id , status , 
	case status 
	when 'Delivered' then 0
	when 'Returned' then 1
	when 'Cancelled' then 2
end as status_no
from orders
order by status_no;


select order_id , status
from orders
order by case status
			when 'Delivered' then 0
			when 'Returned' then 1
			else 2
		end;


select  
	case
	when quantity >= 2 then'Bulk (2+)' 
	else 'Single item' 
	end as order_type,
	count(*) number_of_orders
from orders
group by 1;
		
		select * from products; 











select 
	product_name, 
	price , 
	case 
		when price > 10000 then 'Premium'
		when price > 1000 then	'Mid-Range'
		else 'Budget'
	end as price_range
from products
order by price desc;



select 
	order_id , 
	status , 
	case status
		when 'Delivered' then 'DEL'
		when 'Returned' then 'RET'
		else 'CAN'
	end as status_short
from orders;




select 
	order_id,
	status,
	case status
		when 'Delivered' then 1
		when 'Returned' then 2
		else 3
	end as status_no
from orders
order by status_no;




select 
	order_id,
	status
from orders
order by 
	case status
		when 'Delivered' then 1
		when 'Returned' then 2
		else 3
	end;





SELECT 
	COUNT(*)    					as total_rows,
	count(*) - count(city)			as missing_city,
	count(*) - count(signup_date)	as missing_signup
from customers;



select * from customers;


select name, coalesce (city , 'Unknown') as city from customers;

select 100 / 0;
-- select 100 / nullif(0,0) as safe_divide;
