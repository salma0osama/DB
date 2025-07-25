--1.1
select e.BusinessEntityID, p.FirstName +' '+p.LastName "Name",HireDate  
from HumanResources.Employee e 
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID 
where HireDate > '2012-1-1'
order by HireDate desc;
--1.2
select productID,name, ListPrice,ProductNumber 
from Production.Product
where ListPrice between 100 and 500
order by ListPrice;
--1.3
select c.CustomerID ,FirstName + ' '+LastName "Full Name",City
from sales.customer c
join person.Person p on c.PersonID = p.BusinessEntityID
join Person.BusinessEntityAddress e on c.PersonID = e.BusinessEntityID
join person.Address	a on c.PersonID = e.BusinessEntityID
where City in ('Seattle' , 'Portland');
--1.4
select distinct top(15) p.name,p.ListPrice,ProductNumber,c.name
from Production.Product p
join Production.ProductCategory	c on p.ProductSubcategoryID = c.ProductCategoryID
where DiscontinuedDate is null
order by  ListPrice desc ;
--2.1
select ProductID,Name,Color,ListPrice from Production.Product 
where name like '%Mountain%' and color = 'Black';
--2.2
select FirstName + ' '+MiddleName+' '+LastName "Full Name" , BirthDate
from Person.Person p
join HumanResources.Employee d on p.BusinessEntityID = d.BusinessEntityID
where BirthDate between '1970-1-1' and '1985-12-31';
--2.3
select SalesOrderID , OrderDate , CustomerID , TotalDue
from Sales.SalesOrderHeader 
where OrderDate >= '2013-9-1'
--2.4
select ProductID,Name,Weight,Size,ProductNumber
from Production.Product 
where Weight is null and Size is not null
--3.1
select ProductCategoryID,count(ProductID) "Number of products"
from Production.Product p
join Production.ProductCategory c on p.ProductSubcategoryID = c.ProductCategoryID
group by ProductCategoryID
order by count(ProductID) desc
--3.2
select ProductCategoryID , avg(ListPrice) "Avg"
from Production.Product p
join Production.ProductCategory c on p.ProductSubcategoryID = c.ProductCategoryID
group by ProductCategoryID
having count(*) >=5;
--3.3
select top(10) c.customerID,FirstName + ' '+LastName "Name" , count(SalesOrderID) "Num of Products"
from Sales.Customer c
join Person.Person p on c.PersonID = p.BusinessEntityID
join Sales.SalesOrderHeader r on p.BusinessEntityID = r.CustomerID
group by c.CustomerID,FirstName + ' '+LastName;
--3.4
select year(OrderDate) "Month",sum(TotalDue) "Total sales" 
from Sales.SalesOrderHeader 
where year(OrderDate) = 2013
group by year(OrderDate)
--4.1
select ProductID,Name,SellStartDate,year(SellStartDate) "Year"
from Production.Product
where year(SellStartDate) = (select year(SellStartDate) from Production.Product 
where Name = 'Mountain-100 Black, 42');
--4.2
select FirstName +' '+ LastName "Name"  ,HireDate , count(*) over (partition by hiredate)
from Person.Person p
join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
where HireDate in (select HireDate from HumanResources.Employee group by HireDate having count(*) >1)
--5.1
Create table Sales.ProductReviews 
( reviewID int primary key, productID int unique, customerID int unique,
rating int check(rating between 1 and 5), reviewdate date, reviewtext nvarchar(255),
verifiedpurchaseflag bit default 1, helpfulvotes int);
--6.1
alter table sales.ProductReviews add LastModifiedDate date default getdate()
--6.2
create nonclustered index IX_Last on person.person(LastName) 
include (FirstName,MiddleName);
--6.3
alter table production.product with nocheck 
add constraint CHECKPRICE check(listprice > standardCost);
--7.1
insert into Sales.ProductReviews (reviewID,customerID,productID,rating,reviewtext)
values (1,1,1,3,'Good'),(2,5,2,4,'Very Nice'),(3,3,9,5,'Perfect');
--7.2
insert into Production.ProductCategory (Name) values('Electronics');
--7.3
select * into Sales.DiscontinuedProducts from Production.Product 
where sellEndDate is null;
--8.1
update Production.Product set ModifiedDate = GETDATE() 
where listPrice >1000 and sellEndDate is null
--8.2
update Production.Product set ListPrice=(listprice+ListPrice*0.15) , ModifiedDate = GETDATE()
from Production.Product p
join Production.ProductCategory c on p.ProductSubcategoryID = c.ProductCategoryID
where c.name = 'Bikes'
--8.3
update HumanResources.Employee set jobTitle = 'Senior'
where HireDate < '2010-1-1'
--9.1
delete from Sales.ProductReviews where Rating = 1 and helpfulvotes = 0 
--9.2
delete from Production.Product
where not exists (select 1 from Sales.SalesOrderDetail s 
where s. ProductID = Production.Product.ProductID)
--9.3
delete from Purchasing.Vendor where ActiveFlag = 0
--10.1
select year(orderdate) "Year" , sum(TotalDue) "Total", avg(TotalDue)"Average",count(SalesOrderID) "Order count"
from Sales.SalesOrderHeader
where year(OrderDate) between 2011 and 2014
group by year(OrderDate)
--10.2
select customerid , count(SalesOrderID)"Order Count" ,sum(TotalDue) "Total" ,avg(TotalDue)"Average",
min(OrderDate) "First Order Date" , max(OrderDate) "Last Order Date"
from Sales.SalesOrderHeader
group by CustomerID
--10.3
select top(20) p.Name , s.Name 
from Production.Product p
join Production.Productcategory s on p.ProductSubcategoryID = s.ProductCategoryID 
--10.4
select Month(orderdate) "Month Name", sum(totaldue) "total sales"
from sales.salesorderheader
where year(orderdate) = 2013
group by month(OrderDate);
--11.1
select FirstName+' '+LastName "Name", datediff(year,BirthDate,GETDATE()) "Age" , datediff(year,HireDate,GETDATE())"Years of service",
FORMAT(HireDate, 'mmm dd,yyyy') "Formated hire date", month(BirthDate) "Month of birth"
from Person.Person p
join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
--11.2
select upper(FirstName) + ','+upper(left(LastName,1))+lower(SUBSTRING(LastName,2,LEN(LastName)))+
' '+upper(left(MiddleName,1)) ,
SUBSTRING(EmailAddress,CHARINDEX('@',a.EmailAddress)+1,len(EmailAddress))
from Sales.Customer c
join Person.Person p on c.CustomerID = p.BusinessEntityID 
join Person.EmailAddress a on p.BusinessEntityID =a.BusinessEntityID
--11.3
select Name , Weight "Weight in decimal" ,ListPrice,weight* 0.00220462 "Weight in grams",
(listprice/(weight* 0.00220462))"Price Per Pound"
from Production.Product
where Weight is not null
--12.1
select p.Name , c.Name , c.Name , v.Name
from Production.Product p
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
join Purchasing.ProductVendor r on p.ProductID = r.ProductID
join Purchasing.Vendor v on r.BusinessEntityID = v.BusinessEntityID
--12.2
select d.SalesOrderID , concat(p.firstName,' ',p.LastName) "Customer Name",
t.Name "Territory Name" , pp.Name "Product Name",OrderQty,LineTotal,
concat(per.firstName,' ',per.LastName) "Sales Person Name"
from Sales.SalesOrderDetail d
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
join Person.Person p on h.SalesPersonID = p.BusinessEntityID
join Sales.Customer c on h.CustomerID = c.CustomerID
join Sales.SalesPerson s on h.SalesPersonID = s.BusinessEntityID 
join Person.Person per on s.BusinessEntityID = per.BusinessEntityID
join Production.Product pp on d.ProductID = pp.ProductID
join Sales.SalesTerritory t on h.TerritoryID = t.TerritoryID
--12.3
select p.FirstName+' '+p.LastName "Name",JobTitle,t.Name "Territory Name" , t.[Group] "Group Name", t.SalesYTD
from HumanResources.Employee e
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
join Sales.SalesPerson s on p.BusinessEntityID = s.BusinessEntityID
join Sales.SalesTerritory t on s.TerritoryID = t.TerritoryID
--13.1
select p.ProductID,p.Name , coalesce(sum(LineTotal),0) "Total Sales" ,c.Name "Category Name",
coalesce(sum(OrderQty),0)"Total Quantity"
from Production.Product p
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
join Sales.SalesOrderDetail d on p.ProductID = d.ProductID
group by c.Name , p.Name , p.ProductID;
--13.2
select t.Name "Territory" , CONCAT(p.FirstName,' ',LastName) Name ,t.SalesYTD 
from Sales.SalesTerritory t
join Sales.SalesPerson s on t.TerritoryID = s.TerritoryID
join Person.Person p on s.BusinessEntityID = p.BusinessEntityID
--13.3
select v.Name VendorName , c.Name CategoryName , COUNT(p.ProductID) "Number of Products"
from Purchasing.Vendor v
join Purchasing.ProductVendor pv on v.BusinessEntityID = pv.BusinessEntityID
join Production.Product p on pv.ProductID = p.ProductID
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
group by  v.Name ,c.Name
--14.1
select ProductID , Name , ListPrice , ListPrice - (select avg(ListPrice)from Production.Product) "price difference from the average"
from Production.Product 
where ListPrice > (select AVG(ListPrice) from Production.Product)
--14.2
select FirstName +' '+ LastName "Customer Name" , count(h.SalesOrderID)"Order Count" ,sum(LineTotal) "Total Sales"  
from Sales.SalesOrderHeader h
join Sales.SalesOrderDetail d on h.SalesOrderID = d.SalesOrderID
join Production.Product pp on d.ProductID = pp.ProductID
join Production.ProductSubcategory s on pp.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
join Sales.Customer sc on h.CustomerID = sc.CustomerID
join Person.Person per on sc.PersonID = per.BusinessEntityID
where s.Name like '%Mountain%'
group by sc.CustomerID,FirstName,LastName
--14.3 
select pp.Name ProductName, c.Name CategoryName , count(distinct CustomerID)  "Number of Customers"
from Production.Product pp
join Sales.SalesOrderDetail d on pp.ProductID = d.ProductID
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
join Production.ProductSubcategory s on pp.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
group by pp.Name , c.Name 
having count(distinct CustomerID)>100
--14.4
select c.CustomerID, p.FirstName+' '+p.LastName Name , count(s.SalesOrderID)"Order Count",
RANK() over (order by count(s.salesorderID)desc) "Rank"
from sales.customer c 
join Person.Person p on c.CustomerID = p.BusinessEntityID
join Sales.SalesOrderHeader s on c.CustomerID = s.CustomerID
group by c.CustomerID,p.FirstName , p.LastName
--15.1
GO
create view vw_ProductCatalog as select  p.productID, p.name "Product Name", p.productnumber, c.Name "Category Name",
s.Name "SubCategory Name", p.listprice, p.standardcost, UnitPrice,v.Quantity,status 
from Production.Product p
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory	c on s.ProductCategoryID = c.ProductCategoryID
join Sales.SalesOrderHeader h on h.SalesOrderID = p.ProductID
join Production.ProductInventory v on h.SalesOrderID = v.ProductID
join Sales.SalesOrderDetail d on h.SalesOrderID = d.SalesOrderID
--15.2
GO
create view vw_SalesAnalysis as select year(orderDate) "YEAR", month(OrderDate)"MONTH", t.Name, sum(ListPrice)"Total Sales",
count(SalesOrderID)"Count", avg(SalesOrderID)"Average", max(p.Name) "Max product Name"
from sales.SalesOrderHeader h
join sales.SalesTerritory t on h.TerritoryID = t.TerritoryID
join Production.Product p on h.SalesOrderID = p.ProductID
group by year(OrderDate ),MONTH(OrderDate),t.Name
--15.3
GO
create view vw_EmployeeDirectory as select firstname+' '+LastName "Full Name", jobtitle, t.Name,
hiredate, datediff(YEAR,HireDate,GETDATE())"Years of service", a.EmailAddress,PhoneNumber
from person.person p
join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory d on p.BusinessEntityID = d.BusinessEntityID
join HumanResources.Department t on d.DepartmentID = t.DepartmentID
join Person.EmailAddress a on e.BusinessEntityID = a.BusinessEntityID
join Person.PersonPhone pp on e.BusinessEntityID = pp.BusinessEntityID
--16.1
select listprice,c.Name,count(ProductID)"orderID",avg(listprice)"Average",
CASE
	when ListPrice <100 then 'Budget'
	when ListPrice between 100 and 500 then 'Standard'
	when ListPrice >500 then 'Premium'
END "Classification"	
from Production.Product p
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
group by c.Name , ListPrice
--16.2
select hiredate,rate , PayFrequency ,
CASE 
	when datediff(year,HireDate,GETDATE()) <2 then 'New'
	when datediff(year,HireDate,GETDATE()) between 2 and 5 then 'Regular'
	when datediff(year,HireDate,GETDATE()) between 5 and 10 then 'Experienced'
	when datediff(year,HireDate,GETDATE()) >10 then 'Veteran'
END "Classification"
from HumanResources.Employee e
join HumanResources.EmployeePayHistory h on e.BusinessEntityID = h.BusinessEntityID
--16.3
select totaldue,
CASE
	when totaldue < 1000 then 'Small'
	when totaldue between 1000 and 5000 then 'Medium'
	when totaldue > 5000 then 'Large'
END "Classification"
from sales.SalesOrderHeader
--17.1
select Name ,isnull(cast(Weight as varchar(255)),'Not Specified')"Weight",isnull(Size,'Standard')"Size",
isnull(Color,'Natural') "Color"
from Production.Product
--17.2
select p.BusinessEntityID,coalesce(EmailAddress,PhoneNumber) "Email"
from Person.Person p
join Person.PersonPhone ph on p.BusinessEntityID = ph.BusinessEntityID
join Person.EmailAddress e on p.BusinessEntityID = e.BusinessEntityID
--17.3
select ProductID,Name,Weight , Size from Production.Product
where Weight is null and Size is not null ;
select ProductID,Name,Weight , Size from Production.Product
where Weight is null and Size is null;
--18.1
select p.BusinessEntityID,p.FirstName +' '+p.LastName "Full Name" , e.JobTitle ,
isnull(cast(e.OrganizationLevel as varchar(255) ),'Manager') 
from Person.Person p
join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
join HumanResources.Employee mgr on e.BusinessEntityID = mgr.BusinessEntityID 
--18.2
select ProductID 
from Production.Product
--18.3
--19.1
--19.2
--19.3
--19.4
--19.5
--20.1
select * from(
select c.ProductCategoryID, c.Name ,year(OrderDate)"Year",d.LineTotal
from Production.Productcategory c
join Production.ProductSubcategory s on c.ProductCategoryID = s.ProductCategoryID
join Production.Product p on s.ProductSubcategoryID = p.ProductSubcategoryID
join Sales.SalesOrderDetail d on p.ProductID = d.ProductID
join Sales.SalesOrderHeader h on d.SalesOrderID= h.SalesOrderID
where year(OrderDate) in (2011,2012,2013,2014)
) t
pivot (
	sum(linetotal) 
	for
	"Year" in ([2011],[2012],[2013],[2014])
) as pivottable
--20.2
select * from(
select d.DepartmentID , d.Name , e. Gender
from HumanResources.Employee e 
join HumanResources.EmployeeDepartmentHistory h on e.BusinessEntityID = h.BusinessEntityID
join HumanResources.Department d on h.DepartmentID = d.DepartmentID 
)t
PIVOT(
	count(gender)
	for gender in ([M],[F])
)pivot_table
--20.3
--21.1
(select ProductID 
from Sales.SalesOrderDetail d
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
where year(OrderDate) = 2013
intersect
select ProductID 
from Sales.SalesOrderDetail d
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
where year(OrderDate) = 2014)
union
(
select ProductID 
from Sales.SalesOrderDetail d
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
where year(OrderDate) = 2013
except
select ProductID 
from Sales.SalesOrderDetail d
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
where year(OrderDate) = 2014
)
--21.2
with high_values as(
select distinct c.Name "OrderCategory"
from Production.Product p
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
where p.ListPrice >1000
),
 high_volume as(
select distinct c.Name "OrderCategory"
from Production.Product p
join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
join Sales.SalesOrderDetail d on p.ProductID = d.ProductID
group by c.Name
having sum(OrderQty) >1000
)
(select OrderCategory from high_values
intersect
select OrderCategory from high_volume)
union
(select OrderCategory from high_values
except
select OrderCategory from high_volume)
union
(select OrderCategory from high_volume
except
select OrderCategory from high_values)
--22.1
declare @current_year int = 2011;
declare @total_sales money;
declare @average_order_value decimal(10,2);
select @total_sales = sum(d.linetotal)  , @average_order_value = avg(subtotal) 
from Sales.SalesOrderHeader h
join Sales.SalesOrderDetail d on h.SalesOrderID = d.SalesOrderID
where year(h.OrderDate) = @current_year;

print 'Current Year : '+cast(@current_year as varchar(255));
print 'Total Sales : '+cast(@total_sales as varchar(255));
print 'Average Order Value : '+cast(@average_order_value as varchar(255));
--22.2
declare @productName varchar(255) = 'Mountain-200';
if exists(select 1 from Production.Product p join Production.ProductInventory v on p.ProductID = v.ProductID
where p.Name like '%'+@productName+'%' 
and Quantity > 0)
begin
	select p.Name , v.Quantity , p.ListPrice
	from Production.Product p
	join Production.ProductInventory v on p.ProductID = v.ProductID
	where p.Name like '%'+@productName+'%' 
	and Quantity > 0;
end
else 
begin
	select Name , ListPrice
	from Production.Product 
	where Name ='Mountain' and  Name not like '%'+@productName+'%'
end
--22.3
declare @month int=1;
while(@month<=12)
begin
	select MONTH(orderdate) "Month Number", sum(LineTotal) "Total Sales"
	from Sales.SalesOrderDetail d
	join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
	where MONTH(OrderDate) = @month and YEAR(OrderDate) = 2013
	group by MONTH(OrderDate);
	set @month +=1;
end
--22.4
declare @productID int=316;
declare @productPrice int=200;
begin try
	begin transaction;
	update Production.Product set ListPrice = @productPrice where ProductID = @productID;
	if @@ROWCOUNT = 0
		print 'No product found with this ID';
	else 
	begin
		commit transaction;
		print 'Price updated successfully';
	end
end try
begin catch
	rollback transaction;
		print 'Error';
end catch
--23.1
--23.2
--23.3
--24.1
GO
create procedure ProductByCategory
@categoryName varchar(255),
@minPrice money,
@maxPrice money
as
begin
	select p.Name "Product Name", p.ListPrice , c.Name "Category Name"
	from Production.Product p
	join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
	join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
	where p.ListPrice between @minPrice and @maxPrice
	and c.Name=@categoryName;
end

EXEC ProductByCategory 
    @CategoryName = 'Bikes',
    @MinPrice = 500,
    @MaxPrice = 2000;
--24.2
--24.3
GO
create procedure GenerateSalesReport
@startDate date,
@endDate date,
@territoryID int
as
begin
	select count(h.SalesOrderID) "Number of Orders" , sum(LineTotal) "Total Sales" , avg(SubTotal) "Average Price"
	from Sales.SalesOrderHeader h
	join Sales.SalesOrderDetail d on h.SalesOrderID = d. SalesOrderID
	where h.OrderDate between @startDate and @endDate and TerritoryID = @territoryID
end
EXEC GenerateSalesReport 
    @StartDate = '2013-01-01',
    @EndDate = '2013-12-31',
    @TerritoryID = 1;
--24.4
--24.5
GO
create procedure SearchProducts
@productName varchar(255),
@categoryID int,
@minPrice int,
@maxPrice int,
@startDate date,
@endDate date
as
begin
	select p.ProductID , p.Name "PName" , c.Name "CName", p.ListPrice , p.SellStartDate
	from Production.Product p
	join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
	join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
	where p.Name = @productName and c.ProductCategoryID = @categoryID
	and ListPrice between @minPrice and @maxPrice and SellStartDate between @startDate and @endDate
end
--25.1
GO
create trigger Trig on Sales.SalesOrderDetail after insert as
begin
	begin try
	begin transaction
		update p set Quantity -= OrderQty 
		from Production.ProductInventory p
		join inserted i on p.ProductID = i.ProductID;
	end try
begin catch
	print 'Error' + error_message();
end catch
end
--25.2
GO
create view Sales_Summary
as
select h.SalesOrderID , h.OrderDate , SalesOrderDetailID , d.ProductID , p.Name , d.OrderQty , d.UnitPrice 
from Sales.SalesOrderDetail d
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
join Production.Product p on d.ProductID = p.ProductID
GO
create trigger Sales_Summary_Trigger on Sales_Summary instead of insert as
begin 
	insert into Sales.SalesOrderHeader(RevisionNumber, OrderDate, DueDate, ShipDate) 
	select  1, OrderDate, DATEADD(DAY, 5, OrderDate), DATEADD(DAY, 1, OrderDate)
	from inserted;
	insert into Sales.SalesOrderDetail (SalesOrderID, OrderQty, ProductID) 
	select  1,OrderQty, ProductID
	from inserted;
end


