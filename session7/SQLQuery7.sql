--1
create nonclustered index IN_filteration on sales.customers (email);
--2
create nonclustered index IX_searchenhance on production.products (category_id  ,brand_id);
--3
create nonclustered index IN_cusrec on sales.orders (order_date , customer_id) 
include(store_id , order_status);
--4
GO
create trigger CustLOG on sales.customers after insert as
begin
	insert into customer_log (customer_id , action ,log_date) 
			select customer_id,'Welcome , new Customer!',GETDATE()
			from inserted;
end
--5
GO
create trigger LOG_CHANGES on production.products after update as
begin
	insert into price_history(product_id,old_price,new_price,change_date)
			select d.product_id , d.list_price , i.list_price , GETDATE()
			from deleted d
			join inserted i on d.product_id = i.product_id
			where d.list_price != i.list_price;
end
--6
GO
create trigger DEL_PREVENTION on production.categories instead of delete as
begin
	print 'Can''t delete categories that have associated products';
end
--7
GO
create trigger SALES_COUNTER on sales.order_items after insert as
begin
	update production.stocks set quantity -=1;  
end
--8
GO
create trigger LOGS on sales.orders after insert as
begin
	insert into order_audit (order_id ,customer_id ,store_id ,
		staff_id ,order_date ,audit_timestamp)
	select order_id , customer_id ,store_id , staff_id ,order_date  , GETDATE() 
	from inserted;
end


