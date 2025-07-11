create database Com
use Com

drop database Com
create table Employee (
	SSN INT IDENTITY(1,1) primary key,
	Fname nvarchar(255) not null,	
	Lname nvarchar(255) not null,
	Gender char(1) check(Gender='f' or Gender = 'm'),
	BirthDate date,
	city varchar(100) default 'Cairo',
	SuperID int,
);

alter table employee add email varchar(100) unique;

alter table employee add foreign key (SuperID) references Employee (SSN) ;

alter table employee alter column Fname varchar(150) not null;

alter table employee drop constraint [FK__Employee__SuperI__571DF1D5];

--SQL

use StoreDB

select product_name,list_price from production.products where list_price > 1000;  

select first_name +' '+last_name as "Customer Name" , state from sales.customers where state in ('CA','NY');

select order_id ,order_date from sales.orders where YEAR(order_date)='2023';

select first_name +' '+last_name as "Customer Name" ,email from sales.customers where email like '%@gmail.com';

select active from sales.staffs where active != 1; --Not Sure

select top(5) product_name ,list_price from production.products order by list_price desc;

select top (10) order_id ,order_date from sales.orders order by order_date desc;

select distinct top(3)  last_name from sales.customers order by last_name;

select first_name +' '+last_name as "Full Name" from sales.customers where phone is null;

select first_name +' '+last_name as "Full Name" from sales.staffs where manager_id is not null;

select category_id ,count(product_name) "Number of Products" from production.products 
group by category_id order by category_id;

select state, count(customer_id) "Number of Customers" from sales.customers group by state;

select brand_id , avg(list_price) "Average Price" from production.products group by brand_id order by brand_id;

select staff_id , count(order_id) "Number of Orders" from sales.orders group by staff_id order by staff_id;

select customer_id , count(order_id) "Number of Orders" from sales.orders 
group by customer_id having count(order_id)>2;

select product_name , list_price from production.products where list_price between 500 and 1500;

select first_name +' '+last_name as "Customer Name" , city from sales.customers
where city like 'S%';

select order_id , order_status from sales.orders where order_status in (2,4);

select product_name , category_id from production.products where category_id in (1,2,3);

select first_name +' '+last_name as "Staff Name" from sales.staffs 
where store_id = 1 or phone is null;
