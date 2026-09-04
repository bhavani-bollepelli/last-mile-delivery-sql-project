# Creating Database

create database Project_Last_Mile_Delivery;

use Project_Last_Mile_Delivery;

create table customers(
customer_id varchar(20) primary key,
customer_name varchar(100) not null,
city varchar(50),
delivery_zone_id varchar(10),
preferred_time_slot varchar(30),
customer_type varchar(20) not null,
account_since Date not null
);

select * from customers;


create table orders(
order_id varchar(20) primary key,
customer_id varchar(20),
order_date Date not null,
delivery_zone_id varchar(10),
package_weight_kg decimal(5,2) not null check (package_weight_kg > 0),
service_type varchar(20),
priority varchar(10),
total_value decimal(10,2) not null  check (total_value > 0),
foreign key (customer_id) references customers(customer_id)
);
select * from orders;

create table drivers(
driver_id varchar(10) primary key,
driver_name varchar(100) not null,
hire_date date not null,
rating decimal(3,2) check (rating between 0 and 5),
employment_type varchar(20),
is_active varchar(3)
); 
select * from drivers;

create table vehicles(
vehicle_id varchar(10) primary key,
vehicle_type varchar(20) not null,
fuel_type varchar(20) not null,
max_payload_kg decimal(7,2) not null,
depot varchar(10),
last_service_date Date,
is_active varchar(3) not null check (is_active in ("Yes", "No"))
);
select * from vehicles;

create table deliveries(
delivery_id varchar(20) primary key,
order_id varchar(20),
driver_id varchar(10),
vehicle_id varchar(10),
assigned_date Date ,
actual_delivery_date Date,
status varchar(20),
delivery_attempt tinyint,
distance_km decimal(6,2),
delivery_duration_min int,
foreign key (order_id) references orders(order_id),
foreign key (driver_id) references drivers(driver_id),
foreign key (vehicle_id) references vehicles(vehicle_id)
);

select * from deliveries;



-- What is the total number of customers?
select * from customers;
select count(customer_id) as Total_Number_Customers
from customers;

-- What is the total number of orders?
select * from orders;
select count(order_id) as Total_Number_Orders
from orders;

-- What is the total number of deliveries?
select * from deliveries;
select count(delivery_id) as Total_Number_Deliveries
from deliveries;

-- What are the different service types available?
select distinct(service_type) as Different_Service_Types
from orders;

-- How many drivers are currently active?
select * from drivers;
select count(*) as Active_Drivers
from drivers
where  is_active = "Yes";

-- What are the different vehicle types?
select distinct(vehicle_type) as Different_Vehicle_Type
from vehicles;

-- What is the total order value?
select * from orders;
select sum(total_value) as Total_Orders_Value
from orders;

-- What is the average package weight?
select avg(package_weight_kg) as Average_Package_Weight
from orders;

 # Sprint 4.1
--  Compare the number of orders across delivery zones.
select c.delivery_zone_id,count(o.order_id) as Number_of_Orders
 from customers as c
join orders as o
	on c.customer_id = o.customer_id
group by c.delivery_zone_id
order by  Number_of_Orders desc;


-- Compare orders across different service types.
select * from orders;
 select service_type,count(order_id) as Number_of_Orders 
 from orders
 group by service_type
 order by number_of_orders desc;
 
 
-- S
select priority,count(order_id) as Number_of_Orders
from orders
group by priority
order by number_of_orders desc;


-- Examine how order volume changes over time.
select * from orders;
select date_format(order_date,'%Y-%m') as Order_Month,
count(order_id) as Order_Volume
from orders
group by date_format(order_date,'%Y-%m')
order by order_month ;


-- Look at order value across different groups.
select service_type,sum(total_value) as Total_Order_Value
from orders
group by service_type
order by Total_Order_Value desc;

-- 4.2
-- Compare customers based on the number of orders they plac
select c.customer_id,c.customer_name,count(o.order_id) as Total_Orders
from customers as c
join orders as o
	on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name
order by Total_Orders desc ;


-- Identify customers with higher total order value.
select c.customer_id,c.customer_name,sum(o.total_value) as Total_Orders_Value
from customers as c
join orders as o
	on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name
order by Total_Orders_Value desc ;


-- Compare customer activity across delivery zones.
 select delivery_zone_id,count(customer_id) as Total_Customers
 from customers
 group by delivery_zone_id
 order by Total_Customers desc;
 
 
-- Look at differences between business and individual customers.
select customer_type,count(*) as Total_Customers
 from customers
 group by customer_type
 order by Total_Customers desc;
 
 
-- Examine customer ordering patterns over time.
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS Order_Month,
    COUNT(DISTINCT customer_id) AS Active_Customers,
    COUNT(order_id) AS Total_Orders
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY Order_Month;


-- 4.3
-- Compare delivery outcomes across different zones (zone information is on the orders table, so you will need to connect orders and deliveries).
SELECT
    o.delivery_zone_id,
    d.status,
    COUNT(d.delivery_id) AS Total_Deliveries
FROM orders AS o
JOIN deliveries AS d
    ON o.order_id = d.order_id
GROUP BY o.delivery_zone_id, d.status
ORDER BY o.delivery_zone_id, Total_Deliveries DESC;


-- Examine delivery duration.
select avg(delivery_duration_min) as Average_Duration_For_Delivery
from deliveries;


-- Compare delivery outcomes by status (Delivered, Failed, Pending, Rescheduled) — these are not a simple success/failure split, so consider what each status actually represents.
SELECT
    status,
    COUNT(delivery_id) AS Total_Deliveries
FROM deliveries
WHERE status IN ('Delivered', 'Failed', 'Pending', 'Rescheduled')
GROUP BY status
ORDER BY Total_Deliveries DESC;

-- Identify areas with higher delivery activity or poorer outcomes.
select o.delivery_zone_id, count(d.delivery_id) AS total_deliveries from orders as o
join deliveries as d
on o.order_id = d.order_id
group by o.delivery_zone_id
order by total_deliveries desc;


-- Compare delivery performance over time.
select year(actual_delivery_date) as delivery_year, month(actual_delivery_date) as delivery_month,
count(delivery_id) as total_deliveries
from deliveries
group by  year(actual_delivery_date), month(actual_delivery_date)
order by  delivery_year, delivery_month;



-- 4.4
-- Compare the number of deliveries handled by drivers.
select  d.driver_id,count(*) as Total_Deliveries
from drivers as d
join deliveries as de
	on d.driver_id = de.driver_id
group by driver_id
order by Total_Deliveries desc;

-- Compare driver performance across delivery outcomes.
SELECT
    driver_id,
    status,
    COUNT(*) AS total_deliveries
FROM Deliveries
GROUP BY driver_id, status
ORDER BY driver_id, total_deliveries DESC;


-- Examine delivery duration across drivers.
select driver_id,avg(delivery_duration_min) as  Average_Delivery_Time
from deliveries
group by driver_id
order by Average_Delivery_time desc;


-- Compare vehicle usage across different vehicle types.
select v.vehicle_type,count(*) as Total
from deliveries as d
join vehicles as v
	on v.vehicle_id = d.vehicle_id
group by vehicle_type
order by total desc;


-- Look at delivery performance across different vehicles.
select v.vehicle_type, count(d.status) from deliveries as d
join vehicles as v
on v.vehicle_id = d.vehicle_id group by v.vehicle_type;


-- 4.5 

-- Examine which deliveries required multiple attempts before succeeding.
select delivery_id, max(delivery_attempt) as maximum_delivery from deliveries 
where status = "Delivered" 
group by delivery_id having maximum_delivery > 1;
 
-- Identify common delivery statuses and problem patterns.
select status, count(delivery_id) AS problem_count
from deliveries
where status in ('Failed', 'Pending', 'Rescheduled',"Delivered")
group by status
order by problem_count desc;

-- Compare delivery performance for orders with multiple attempts.
select d.delivery_id, max(d.delivery_attempt) as total_attempts, d.status from deliveries as d
group by d.delivery_id, d.status
having max(d.delivery_attempt) > 1
order by total_attempts desc ;

-- Examine whether certain zones experience more delivery problems.
select o.delivery_zone_id,
       count(d.delivery_id) as delivery_problems
from orders as o
join deliveries as d
    on o.order_id = d.order_id
where d.status != 'Delivered'
group by o.delivery_zone_id
order by delivery_problems desc;


