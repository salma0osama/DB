--1
select product_name , list_price ,
   case
	   when list_price <300 then 'Economy'
	   when list_price between 299 and 1000 then 'Standard'
	   when list_price between 999 and 2500 then 'Premium'
	   when list_price >=2500 then 'Luxury'
	   end
from production.products;

--2 
select order_id , customer_id , order_date,order_status,
case
	when order_status= 1 then 'Order Received'
	when order_status= 2 then 'In Preparation'
	when order_status= 3 then 'Order Cancelled'
	when order_status= 4 then 'Order Delivered'
end "Satatus",
case
	when order_status = 1 and datediff(day,order_date,GETDATE())>5 then 'URGENT'
	when order_status = 2 and datediff(day,order_date,GETDATE())>3 then 'HIGH'
	else 'NORMAL'
end "Prioity"
from sales.orders;

--3
select customer_id , count(order_id) "Order Count" ,
	case 
		when count(order_id) = 0 then 'New Staff'
		when count(order_id) between 0 and 11 then 'Junior Staff'
		when count(order_id) between 10 and 26 then 'Senior Staff'
		when count(order_id) >= 26 then 'Expert Staff'
	end "Calssification"
from sales.orders group by customer_id;

--4
select * ,ISNULL(phone,'Phone Not Available') "Info" from sales.customers;
select * ,coalesce(phone,email,'No Contact Method') "preferred_contact" from sales.customers;

--5
select p.product_id,p.product_name,p.list_price ,ISNULL(quantity,0) "Quantity", 
case
	when s.quantity is null then 'No stock'
	when s.quantity =0 then 'Out of Stock'
	when s.quantity between 0 and 25 then 'low Stock'
	when s.quantity >25  then 'high Stock'
end "Stock"
from production.products p
join production.stocks s on p.product_id=s.product_id and store_id =1

--6
select customer_id ,
coalesce(street,'') "street",
coalesce(city,'') "city",
coalesce(state,'') "state",
coalesce(zip_code,'') "code",
concat(street,' ',city,' ',state,' (',zip_code,')') "Formatted Address"
from sales.customers;

--7
WITH expensive_products AS (
    SELECT
        customer_id,
        sum(p.list_price*quantity) "Total"
    FROM sales.orders o
    join sales.order_items i on o.order_id= i.order_id
    join production.products p on p.product_id = i.product_id
    group by customer_id
    having sum(p.list_price*quantity) > 1500
	) 
SELECT
     e.customer_id,
	 s.first_name + ' ' +s.last_name "NAME",
         "Total"
FROM expensive_products e
JOIN  sales.customers s ON e.customer_id = s.customer_id
ORDER BY "Total" DESC;

--8
WITH category_revenue AS (
    SELECT
        category_id,
        sum(p.list_price*quantity) "Total"
    FROM sales.order_items i
    join production.products p on p.product_id = i.product_id
    group by category_id
),
category_avg_order AS (
    SELECT
        category_id,
        avg(p.list_price*quantity) "Avg"
    FROM sales.order_items i
    join production.products p on p.product_id = i.product_id
    group by category_id
) 
SELECT
     r.category_id,
	 "Total",	
	 "Avg",
	 case 
		when "Total" >50000 then 'Excellent'
		when "Total" >20000 then 'Good'
		else 'Needs Improvement'
	end "Performance"
FROM category_revenue r
JOIN  category_avg_order a ON r.category_id= a.category_id
ORDER BY "Total" DESC;

--9
with Monthly_sales as(
select month(order_date) "Month", sum(quantity	*list_price*(1-discount)) "Total price"
from sales.orders s
join sales.order_items i on s.order_id = i.order_id 
group by month(order_date)
),
Last_Month_sales_comparison as(
select *,(select "Total price" from Monthly_sales where "month" = 12)"Last Month" from Monthly_sales
)
select "Total price" , "Last Month" ,
   "Total price" - "Last Month" as "Growth",
   round((("Total price"-"Last Month")/"Last Month")*100,2)
from Last_Month_sales_comparison ;

--10
select product_name ,list_price, ROW_NUMBER() over (order by list_price desc) price_rank from production.products
select product_name ,list_price, RANK() over (order by list_price desc) price_rank from production.products
select product_name ,list_price, DENSE_RANK()over (order by list_price desc) price_rank from production.products
select top(3) product_name ,list_price, RANK() over (partition by category_id order by list_price desc) price_rank from production.products

--11

--12
select store_name, sum(quantity*list_price*(1-discount)) "Total",count(o.order_id) "Num Of Orders",
RANK() over (order by sum(quantity*list_price*(1-discount)) desc) as "Rank1",
RANK() over (order by count(o.order_id)) as "Rank2",
PERCENT_RANK() over(order by sum(quantity*list_price*(1-discount)) desc) as "percentile"
from sales.stores s 
join sales.orders o on s.store_id=o.store_id
join sales.order_items i on o.order_id = i.order_id
group by store_name

--13 
select top(4) * from (
select category_name,product_id
from production.brands b
join production.products p on b.brand_id=p.brand_id
join production.categories c on p.category_id = c.category_id

) t
PIVOT (
	count(product_id) for
	category_name IN (
	[Men's Activewear],
	[Men's Shorts],
	[Women's T-Shirts & Tops],
	[Women's Skirts]	
	)	
) AS "PIVOT TABLE"

--14
select * from
(select s.store_name,month(o.order_date) as "Month" ,sum(i.quantity*i.list_price*(1-i.discount)) as "Total"
from sales.stores s 
join sales.orders o on s.store_id=o.store_id
join sales.order_items i on o.order_id = i.order_id
group by store_name,month(order_date)
)t
PIVOT (
	 sum("Total") for
	 "Month" IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS "PIVOT TABLE"

--15
select * from(
select order_id,store_name , order_status 
from sales.orders o
join sales.stores s on o.store_id = s.store_id
)t
PIVOT (
 count(order_id)
 for order_status in ([1],[2],[3],[4])
)AS "PIVOT TABLE"

--16
select * from(
select brand_name,sum(i.list_price*quantity*(1-discount)) "Total" , year(order_date) "Year"
from production.products p
join production.brands b on p.brand_id= b.brand_id
join sales.order_items i on p.product_id=i.product_id
join sales.orders s on i.order_id = s.order_id
group by brand_name , year(order_date)
)t
PIVOT (
 sum(total)
 for "Year" in ([2022],[2023],[2024])
)AS "PIVOT TABLE"

--17 
select p.product_id,p.product_name,'In Stock' AS Status
FROM production.products p
JOIN production.stocks s on p.product_id = s.product_id
WHERE s.quantity > 0
UNION
SELECT p.product_id,p.product_name,'Out of Stock' AS Status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL
UNION
SELECT p.product_id,p.product_name,'Discontinued' AS Status
FROM production.products p
LEFT JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.product_id IS NULL;

--18 
select customer_id from sales.orders where year(order_date) =2022
intersect
select customer_id from sales.orders where year(order_date) =2023

--19
SELECT product_id, 'Available in All Stores' AS status
FROM production.stocks
WHERE store_id = 1 AND quantity > 0
INTERSECT
SELECT product_id, 'Available in All Stores' AS status
FROM production.stocks
WHERE store_id = 2 AND quantity > 0
INTERSECT
SELECT product_id, 'Available in All Stores' AS status
FROM production.stocks
WHERE store_id = 3 AND quantity > 0
------------------------------------------
SELECT product_id, 'Only in Store 1' AS status
FROM production.stocks
WHERE store_id = 1 AND quantity > 0
EXCEPT
SELECT product_id, 'Only in Store 1' AS status
FROM production.stocks
WHERE store_id = 2 AND quantity > 0
------------------------------------------
(SELECT product_id, 'Available in All Stores' AS status
FROM production.stocks
WHERE store_id = 1 AND quantity > 0
INTERSECT
SELECT product_id, 'Available in All Stores' AS status
FROM production.stocks
WHERE store_id = 2 AND quantity > 0
INTERSECT
SELECT product_id, 'Available in All Stores' AS status
FROM production.stocks
WHERE store_id = 3 AND quantity > 0)
union
(SELECT product_id, 'Only in Store 1' AS status
FROM production.stocks
WHERE store_id = 1 AND quantity > 0
EXCEPT
SELECT product_id, 'Only in Store 1' AS status
FROM production.stocks
WHERE store_id = 2 AND quantity > 0)

--20
select customer_id ,'Lost Customer' as status from sales.orders where year(order_date) =2022
except
select customer_id , 'Lost Customer' as status from sales.orders where year(order_date) =2023
-----------------------------------------------------
select customer_id ,'New Customer' as status from sales.orders where year(order_date) =2023
except
select customer_id , 'New Customer' as status from sales.orders where year(order_date) =2022
----------------------------------------------------
select customer_id ,'Retained Customer' as status from sales.orders where year(order_date) =2022
union
select customer_id ,'Retained Customer' as status from sales.orders where year(order_date) =2023
------------------------------------------------------------------
(select customer_id ,'Lost Customer' as status from sales.orders where year(order_date) =2022
except
select customer_id , 'Lost Customer' as status from sales.orders where year(order_date) =2023)
UNION ALL
(select customer_id ,'New Customer' as status from sales.orders where year(order_date) =2023
except
select customer_id , 'New Customer' as status from sales.orders where year(order_date) =2022)
UNION ALL
(select customer_id ,'Retained Customer' as status from sales.orders where year(order_date) =2022
union
select customer_id ,'Retained Customer' as status from sales.orders where year(order_date) =2023)