--1
declare @TotalAmount int;
select @TotalAmount = sum(list_price*quantity) from sales.order_items i
join sales.orders o on i.order_id=o.order_id 
WHERE customer_id =1
print @totalAmount
if(@totalAmount>5000)
	print 'VIP customer';
else
	print 'Regular customer';

--2
declare @Productcount int;
declare @threshold int = 1500;
select @Productcount = count(*) from production.products where list_price > @threshold;
select @threshold "Threshold", @Productcount "Count", 'There are '+cast(@Productcount as varchar(10))+' products that cost moe than '+cast(@threshold as varchar(10)) "Formatted";

--3 
declare @totalsales int;
declare @year int = 2022;
declare @ID int = 2 ;
select @totalsales = sum(order_id) from sales.staffs s 
join sales.orders o on s.staff_id=o.staff_id
where s.staff_id = @ID and year(order_date) = @year
select @totalsales "Total sales for member num 2"

--4
select @@SERVERNAME "User Name", @@VERSION "Version",@@ROWCOUNT "Num of Rows affected by the last Query"

--5
declare @stock int;
select @stock = quantity from production.stocks where product_id = 1 and store_id = 1
print @stock
if(@stock > 20)
	print 'Well Stocked';
else if (@stock >10 and @stock<20)
	print 'Moderate stock';
else if (@stock < 10)
	print 'Low stock - reorder needed';

--6
declare @RowsUpdated int;
declare @BatchCount int ;
while(@RowsUpdated > 0)
begin
	set @BatchCount +=1
	update top(3) production.stocks set quantity = quantity + 10 where quantity < 5;
	set @RowsUpdated = @@ROWCOUNT;
	print @RowsUpdated;
	print 'Batch Updated';
end

--7
select product_id,list_price,
case	
	when list_price <300 then 'Budget'
	when list_price between 300 and 800 then 'Mid-Range'
	when list_price between 800 and 2000 then 'Premium'
	when list_price >2000 then 'Luxury'
end "Price Categorization"
from production.products

--8
declare @CustomerID int = 5;
if exists (select 1 from sales.orders where customer_id= @CustomerID)
	select count(*) "Number of Orders" from sales.customers
else
	print 'Customer ID does not exists';

--9
create function CalculateShipping (@order_total decimal(10,2)) 
returns decimal(10,2)
as
begin
	declare @cost decimal(10,2);
	select @cost = (quantity*list_price*(1-discount)) from sales.order_items;
	if(@order_total > 100)
		set @cost = 0 ;
	else if(@order_total between 50 and 100)
		set @cost = 5.99;
	else if(@order_total<50)
		set @cost = 12.99;
	return @cost;
end;
GO
select dbo.CalculateShipping(25.00) AS "Under $50",
       dbo.CalculateShipping(75.00) AS "$50-$99", 
       dbo.CalculateShipping(150.00) AS "Over $100";

--10
create function GetProductsByPriceRange (@MaxRange decimal(10,2),@MinRange decimal(10,2))
returns table
as
Return (
select category_name , brand_name , list_price 
from production.products p
join production.categories c on p.category_id = c.category_id
join production.brands b on p.brand_id = b.brand_id
where list_price between @MinRange and @MaxRange
)
GO
select * from GetProductsByPriceRange(100,10);

--11
create function GetCustomerYearlySummary (@ID int)
returns @summary 
table (year_ decimal(10,2) ,total_orders int, total_spent decimal(10,2), average decimal(10,2))
as
begin
	insert into @summary
		select year(order_date) "year_", count(o.order_id) "total_orders",
		sum(list_price*quantity*(1-discount)) "total_spent",
		avg(list_price*quantity*(1-discount)) "average"
		from sales.orders o
		join sales.order_items i on o.order_id = i.order_id
		where customer_id = @ID
		group by year(order_date)
	return;
end
GO
select * from GetCustomerYearlySummary(6);

--12
create function CalculateBulkDiscount(@quantity int)
returns decimal(10,2) 
as
begin
	declare @discountPercentage decimal(10,2);
	if @quantity <= 2 set @discountPercentage = 0
	else if @quantity between 3 and 5 set @discountPercentage = 5
	else if @quantity between 6 and 9 set @discountPercentage = 10
	else if @quantity >= 10 set @discountPercentage = 15
	return @discountPercentage;
end
GO
select dbo.CalculateBulkDiscount(10),
	   dbo.CalculateBulkDiscount(1),
       dbo.CalculateBulkDiscount(3), 
       dbo.CalculateBulkDiscount(6);

--13
create function sp_GetCustomerOrderHistory (@ID int, @startdate date , @endDate date)
returns table
as
return(
	select order_id , order_date , shipped_date from sales.orders where customer_id = @ID
);
GO
select * from sp_GetCustomerOrderHistory(5,'2023-01-01','2023-12-31');

--14
create function sp_RestockProduct (@store_ID int, @product_ID int,@restock_quantity int)
returns @result table (Old int, New int)
as
begin
	insert into @result
	select quantity "Old" , quantity + @restock_quantity "New"
	from sales.order_items i
	join sales.orders o on i.order_id = o.order_id
	where store_id = @store_ID and product_id = @product_ID;
	return;
end

GO
select * from sp_RestockProduct(1,1,10);

--15

--16
create function sp_SearchProducts (@Product_name varchar(255),@Category_id int , @MinPrice int, @MaxPrice int)
returns table
as
return(
	select category_name,product_name 
	from production.products p
	join production.categories c on p.category_id= c.category_id
	where product_name like '%'+ @Product_name +'%'
	  and list_price between @MinPrice and @MaxPrice
)
SELECT * from sp_SearchProducts('skirt',1,10,1000)	 

--17
create function quarterly_bonuses(@year int)
returns table 
as 
return(
		select s.staff_id , sum(quantity*list_price*(1-discount)) "total sales",
		case
			when sum(quantity*list_price*(1-discount)) <= 5000 then 'Bronze'
			when sum(quantity*list_price*(1-discount)) between 5000 and 10000 then 'Silver'
			when sum(quantity*list_price*(1-discount)) between 10000 and 15000 then 'Gold'
			when sum(quantity*list_price*(1-discount)) >= 15000 then 'Platinum'
		end "Performance"
		from sales.staffs s
		join sales.orders o on s.staff_id = o.staff_id
		join sales.order_items i on o.order_id = i.order_id
		where year(order_date) = @year
		group by s.staff_id
)
GO
select * from quarterly_bonuses(2022)

--18
select i.product_id,p.product_name ,i.list_price,quantity,
	case
		when quantity = 0 then 
			 case
				when category_id in (1,2,3,4,5) then quantity+50 
				when category_id in (6,7,8,9,10) then quantity+100
				else 0
			 end
			 when quantity <= 5 then
			case 
				when category_id in (1,2,3,4,5)  then quantity+25
				when category_id in (6,7,8,9,10) then quantity+30
				else 0
			end
		when quantity <=20 then
			case 
				when category_id in (1,2,3,4,5)  then quantity+20
				when category_id in (6,7,8,9,10) then quantity+15
				else 0
			end 
	end "New Stock",
	case
		when quantity = 0 then 'Out of stock'
		when quantity < 10 then 'Low stock'
		when quantity <50 then 'Normal stock'
	end "Situation"
from sales.order_items i
join production.products p on i.product_id = p.product_id

--19
create function Get_loyality(@ID int)
returns table 
as 
return(
	select c.customer_id , count(i.order_id) "Number of Orders", sum(quantity*list_price*(1-discount)) "Total Sales",
	case
		when sum(quantity*list_price*(1-discount)) < 5000 then 'Bronze'
		when sum(quantity*list_price*(1-discount)) between 10000 and 20000 then 'Silver'
		when sum(quantity*list_price*(1-discount)) between 20000 and 50000 then 'Gold'
		when sum(quantity*list_price*(1-discount)) > 50000 then 'Platinum Loyal Customer!'
	end "Loyality"
	from sales.customers c
	join sales.orders o on c.customer_id = o.customer_id
	join sales.order_items i on o.order_id = i.order_id
	where c.customer_id = @ID
	group by c.customer_id
)
GO
select * from Get_loyality (7);

--20
