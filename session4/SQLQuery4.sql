use StoreDB

select count(product_id) from production.products; --1

select avg(list_price)"Average price" , max(list_price)"Max Price", min(list_price)"Min price" 
from production.products; --2

select category_id , COUNT(product_id)"Number of Products" from production.products
group by category_id; --3

select store_id,count(order_id) "Number of orders" from sales.orders 
group by store_id; --4

select top(10) UPPER(first_name)+' '+LOWER(last_name) "Full Name" from sales.customers; --5

select top(10) product_name ,len(product_name) from production.products; --6

select top(15) first_name+' '+ last_name "Full Name" ,LEFT(phone,3) "Area Code" from sales.customers; --7

select GETDATE();
select top(10) month(order_date) "MONTH" ,year(order_date)"YEAR" from sales.orders;	--8

select top(10) pc.category_name , pp.product_name from production.products pp
join production.categories pc on pp.category_id = pc.category_id; --9

select sc.first_name+' '+sc.last_name "Full Name" ,so.order_date from sales.customers sc
join sales.orders so on sc.customer_id = so.customer_id; --10

select pp.product_name,coalesce(pb.brand_name,'No Brand') from production.products pp
join production.brands pb on pp.brand_id = pb.brand_id; --there is no null --11

select product_name,list_price from production.products
where list_price > (select avg(list_price) from production.products); --12

select customer_id,first_name+' '+last_name "Full Name" from sales.customers
where customer_id in (select customer_id from sales.orders ); --13

select sc.first_name+' '+sc.last_name "Full Name", 
       (select count(*) from sales.orders so where so.customer_id = sc.customer_id) "Number of Orders"
from sales.customers sc; --14

create view easy_product_list as
select pp.product_name , pc.category_name , pp.list_price from production.products pp
join production.categories pc on pp.category_id = pc.category_id;
select * from easy_product_list where list_price>100; --15

create view customer_info as
select customer_id , first_name+' '+last_name "Full Name" ,email ,concat(city , ' (',state,')') "City" 
from sales.customers; 
select * from customer_info where "City" like '%(CA)'; --16

select product_name,list_price "Price" from production.products
where list_price between 50 and 200 order by list_price; --17

select state,count(*) as "Number of Customer" from sales.customers
group by state order by [Number of Customer] desc; --18

select pc.category_name , pp.product_name , pp.list_price from production.products pp
join production.categories pc on pp.category_id = pc.category_id 
where list_price = (select max(list_price) from production.products); --19

select ss.store_name , ss.city , count(so.order_id) "Number of Orders" from sales.stores ss 
join sales.orders so on ss.store_id=so.store_id
group by ss.store_id , ss.store_name , ss.city
order by "Number of Orders" desc; --20

