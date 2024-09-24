-- create a new sceham and use it
CREATE SCHEMA assigment_two;
use assigment_two;

-- make foodID the primary key of table foods
alter table foods add constraint pk_food_id primary key (foodID);

-- make restID primary key of resturants
alter table restaurants add constraint pk_rest_id primary key (restID);

-- make foodID and restID the foreign keys of the child table serves
ALTER TABLE serves add constraint fk_serves_foodID foreign key (foodID)
REFERENCES foods(foodID)
on delete cascade on update cascade;
alter table serves add constraint fk_serves_restID foreign key(restID)
references restaurants(restID)
on delete cascade on update cascade;



-- make chefID the primary key of the table chef
alter table chef add constraint pk_chef_id primary key (chefID);

-- make chefID and restID the foreign keys of the child table works
alter table works add constraint fk_works_chefID foreign key (chefID)
references chef(chefID)
on delete cascade on update cascade;
alter table works add constraint fk_works_restID foreign key (restID)
references restaurants (restID)
on delete cascade on update cascade;


-- 1) avarage foods price at each resturant
select restaurants.name, avg(foods.price) as avg_price
from serves 
inner join restaurants on serves.restID = restaurants.restID
inner join foods on serves.foodID = foods.foodID
group by restaurants.name
order by avg_price desc;



-- 2) maximum food price at each resturant
select restaurants.name, max(foods.price) as max_price
from serves
inner join restaurants on restaurants.restID = serves.restID
inner join foods on foods.foodID = serves.foodID
group by restaurants.name
order by max_price desc;



-- 3) different food types each restuarant has
select restaurants.name, count(distinct serves.foodID) as different_foods
from serves
inner join restaurants on restaurants.restID = serves.restID
group by restaurants.name
order by different_foods;



-- 4) Average Price of Foods Served by Each Chef
select chef.name , avg(foods.price) as avarage_price
from works
inner join serves on serves.restID = works.restID
inner join foods on foods.foodID = serves.foodID 
inner join chef on chef.chefID = works.chefID
group by chef.name
order by avarage_price;



-- 5) Find the Restaurant with the Highest Average Food Price 
select restaurants.name, avg(foods.price) as avg_price
from serves
inner join restaurants on restaurants.restID = serves.restID
inner join foods on foods.foodID = serves.foodID
group by restaurants.name
order by avg_price desc limit 1;



-- 6) Determine which chef has the highest average price of the foods
-- served at the restaurants where they work. 
-- Include the chef’s name, the average food price, 
-- and the names of the restaurants where the chef works.
select chef.name as chef_name, avg(foods.price) as avarage_price,
group_concat(distinct restaurants.name)  as restaurant_names
from works
inner join serves on works.restID = serves.restID
inner join restaurants on works.restID = restaurants.restID
inner join foods on foods.foodID = serves.foodID
inner join chef on chef.chefID = works.chefID
group by chef.name 
order by avarage_price desc;





