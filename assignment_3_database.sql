--  DB Assignment 3
-- Name: David Schwartzman 
-- Date: 2024-10-10 
 

-- add primary key to merchants
alter table merchants
add constraint pk_mid primary key (mid);

-- add primary key, product name constraint and category name constraint
alter table products
add constraint pk_pid primary key (pid),
add constraint product_name check ( name in ( 'Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop', 
'Router', 'Network Card', 'Super Drive', 'Monitor')),
add constraint category_name check(category in ( 'Peripheral', 'Networking', 'Computer'));
 

-- add primary key to customers
alter table customers
add constraint pk_cid primary key (cid);



-- add primary key, shipping method constraint and shipping cost constraint to orders
alter table orders
add constraint pk_oid primary key(oid),
-- Orders shipping_method constraint: UPS, FedEx, USPS
add constraint shipping_method_const check (shipping_method in ('UPS', 'FedEx', 'USPS')),
-- Orders shipping_cost constraint: between 0 and 500
add constraint shipping_cost_constraint check (shipping_cost >= 0 and shipping_cost <= 500);


-- add foreign keys to sell
alter table sell
add constraint fk_sell_mid
foreign key (mid) references merchants(mid),
add constraint fk_sell_pid
foreign key (pid) references products(pid),
-- sell price constraint: between 0 and 100,000
add constraint price_constraint check (price >= 0 and price <= 100000),
-- Sell quantity_available constraint: between 0 and 1,000
add constraint quantity_available_const check (quantity_available >= 0 and quantity_available <= 1000);

-- add foreign keys to contain
alter table contain
add constraint fk_contain_oid
foreign key (oid) references orders(oid),
add constraint fk_contain_pid
foreign key (pid) references products(pid);

-- add foreign keys to place
alter table place
add constraint fk_place_cid
foreign key (cid) references customers(cid),
add constraint fk_place_oid
foreign key (oid) references orders(oid);
-- make sure there are valid dates
update place
set order_date = STR_TO_DATE(order_date, '%d/%m/%Y');
alter table place
modify order_date date;

-- 1) List names and sellers of products that are no longer available (quantity=0)
select products.name as product, merchants.name as merchants 
from merchants 
inner join sell on merchants.mid = sell.mid
inner join products on sell.pid = products.pid
where sell.quantity_available = 0; 

-- 2) List names and descriptions of products that are not sold.
select products.name as product, products.description
from products
left join sell on sell.pid = products.pid
where sell.pid is null; 
-- 3) How many customers bought SATA drives but not any routers?
select COUNT(DISTINCT c.cid) AS customer_count
FROM customers c
JOIN place p ON c.cid = p.cid
JOIN orders o ON p.oid = o.oid
JOIN contain co ON o.oid = co.oid
JOIN products prod ON co.pid = prod.pid
WHERE prod.description LIKE '%SATA%'  
AND c.cid NOT IN (
    SELECT DISTINCT c2.cid
    FROM customers c2
    JOIN place p2 ON c2.cid = p2.cid
    JOIN orders o2 ON p2.oid = o2.oid
    JOIN contain co2 ON o2.oid = co2.oid
    JOIN products prod2 ON co2.pid = prod2.pid
    WHERE prod2.name LIKE 'Router'  
);


-- 4) HP has a 20% sale on all its Networking products.
update sell
inner join merchants on merchants.mid = sell.mid
inner join products on products.pid = sell.pid
set sell.price = sell.price * 0.8
where merchants.name  = "HP" and products.category = "Networking";



-- 5) What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).
select customers.full_name, products.name, sell.price
from customers
inner join place on customers.cid = place.cid
inner join orders on place.oid = orders.oid
inner join contain on orders.oid = contain.oid
inner join products on contain.pid = products.pid
inner join sell on products.pid = sell.pid 
inner join merchants on sell.mid = merchants.mid
where merchants.name = "Acer" and
customers.full_name = "Uriel Whitney";
 
-- 6) List the annual total sales for each company 
-- (sort the results along the company and the year attributes).
select m.name, year(p.order_date) as year, sum(s.price) as total_sales
from merchants m 
join sell s on m.mid = s.mid
join contain co on s.pid = co.pid
join place p on co.oid = p.oid
group by m.name, year(p.order_date)
order by total_sales desc;



-- 7) Which company had the highest annual revenue and in what year?
select m.name, year(p.order_date) as year, sum(s.price) as annual_revenue
from merchants m
join sell s on m.mid = s.mid
join contain co on s.pid = co.pid
join orders o on co.oid = o.oid
join place p on o.oid = p.oid
group by m.name, year(p.order_date)
order by annual_revenue desc
limit 1;



-- 8) On average, what was the cheapest shipping method used ever?
select orders.shipping_method as name, avg(orders.shipping_cost) as cost
from orders
group by orders.shipping_method
order by cost asc
limit 1;

-- 9) What is the best sold ($) category for each company?
select cs.category, m.name, cs.total_sales
from (
select s.mid, p.category, sum(s.price) as total_sales
from sell s
inner join products p on p.pid = s.pid
group by s.mid, p.category
) cs 
inner join merchants m on cs.mid = m.mid
where cs.total_sales = (
select max(total_sales)
from (
select s.mid, p.category, sum(s.price) as total_sales
from sell s 
inner join products p on p.pid = s.pid
group by s.mid, p.category
    ) subquery
    where subquery.mid = cs.mid
);




-- 10) Who spent most and least at each merchant
with customer_spending as (
select s.mid, p.cid, sum(s.price) as total_spent
from contain co join orders o on co.oid = o.oid
join place p on o.oid = p.oid
join customers c on p.cid = c.cid
join products prod on co.pid = prod.pid
join sell s on prod.pid = s.pid
group by s.mid, p.cid
),
ranked_spending as (
select cs.mid, cs.cid, cs.total_spent,
rank() over (partition by cs.mid order by cs.total_spent desc) as rank_desc,
rank() over (partition by cs.mid order by cs.total_spent asc) as rank_asc
from customer_spending cs
)
select merchants.name as company_name,
customers.full_name as customer_name,
ranked_spending.total_spent,
case 
when ranked_spending.rank_desc = 1 then 'most'
when ranked_spending.rank_asc = 1 then 'least'
end as spending_type
from ranked_spending
join merchants on ranked_spending.mid = merchants.mid
join customers on ranked_spending.cid = customers.cid
where ranked_spending.rank_desc = 1 or ranked_spending.rank_asc = 1
order by merchants.name, spending_type;
