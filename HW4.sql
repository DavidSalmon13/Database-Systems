create schema assigment_four;
use assigment_four;



-- actor constraint
alter table actor add constraint pk_constraint 
primary key (actor_id);

-- address constraint
alter table address add constraint pk_constraint 
primary key (address_id);
alter table address add constraint fk_constraint 
foreign key (city_id) references city (city_id);

-- category constraint
alter table category add constraint pk_constraint 
primary key (category_id),
add constraint category_constraint
check(name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 
'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'));


-- city constraint
alter table city add constraint pk_constraint 
primary key (city_id),
add constraint foreign key (country_id)
references country (country_id) on delete cascade;

-- country constraint
alter table country add constraint pk_constraint 
primary key (country_id);

-- customer constraint
alter table customer add constraint pk_constraint 
primary key (customer_id);
alter table customer add constraint 
foreign key (store_id) references store (store_id);
alter table customer add constraint
foreign key (address_id) references address (address_id)
on delete cascade;

-- film constraint
alter table film add constraint
primary key (film_id);
alter table film add constraint
foreign key (language_id) references language (language_id)
on delete cascade,
add constraint features_constraint
check(special_features in ('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers')),
add constraint duration_constraint
check (rental_duration between 2 and 8),
add constraint rental_rate_constraint
check (rental_rate between 0.99 and 6.99),
add constraint film_length_constraint
check (length between 30 and 200), 
add constraint film_rating_constraint 
check (rating in ('PG', 'G', 'NC-17', 'PG-13', 'R')),
add constraint replacement_constraint
check (replacement_cost between 5.00 and 100.00);

-- film_actor constraint
alter table film_actor add constraint 
primary key (actor_id, film_id);
alter table film_actor add constraint
foreign key (actor_id)  references actor(actor_id)
on delete cascade;
alter table film_actor add constraint
foreign key (film_id)  references film(film_id)
on delete cascade;





-- rental constraint
alter table rental 
add constraint primary key (rental_id),
add constraint foreign key (inventory_id) references inventory (inventory_id),
add constraint foreign key (customer_id) references customer(customer_id),
add constraint foreign key (staff_id) references staff (staff_id),
add constraint valid_return_date
check (return_date between '1900-01-01' and '2100-01-01'),
add constraint valid_date 
check (rental_date between '1900-01-01' and '2100-01-01');

-- staff constraint
alter table staff 
add constraint primary key (staff_id),
add constraint foreign key (address_id) references address(address_id),
add constraint foreign key (store_id) references store(store_id),
add constraint active_constraint check (active in (0,1));


-- store constraint
alter table store 
add constraint pk_constraint primary key (store_id),
add constraint foreign key (address_id) references address (address_id);

-- film_category constraint
alter table film_category
add constraint primary key (film_id, category_id),
add constraint foreign key (film_id) references film (film_id),
add constraint foreign key (category_id) references category(category_id);

-- invetory constraint
alter table inventory add constraint primary key (inventory_id),
add constraint foreign key (film_id) references film(film_id),
add constraint foreign key (store_id) references store (store_id);



-- language constraint
alter table language add constraint
primary key (language_id);


-- payment constraint
alter table payment 
add constraint primary key (payment_id),
add constraint foreign key (customer_id) references customer (customer_id),
add constraint foreign key (staff_id) references staff (staff_id),
add constraint foreign key (rental_id) references rental (rental_id),
add constraint amount_constraint check (amount >= 0);



-- 1) What is the average length of films in each category? 
-- List the results in alphabetic order of categories.
select category.name , avg(film.length) as avarage_length
from film
inner join film_category on film.film_id = film_category.film_id
inner join category on category.category_id = film_category.category_id
group by category.name
order by category.name;

-- 2) Which categories have the longest and shortest average film lengths?
WITH category_averages AS (
    SELECT category.name, AVG(film.length) AS average_length
    FROM film
    INNER JOIN film_category ON film.film_id = film_category.film_id
    INNER JOIN category ON category.category_id = film_category.category_id
    GROUP BY category.name
)
SELECT name, average_length
FROM category_averages
WHERE average_length >= all(select average_length from category_averages)  
   OR average_length <= all (select average_length from category_averages);


-- 3) Which customers have rented action but not comedy or classic movies?
with que as(
select  customer.first_name as name, category.name category, customer.customer_id, customer.last_name as last_name
from customer
inner join rental on rental.customer_id = customer.customer_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film_category.film_id = film.film_id
inner join category on film_category.category_id = category.category_id
)
select distinct name, last_name 
from que as que1
where category = 'action'
and not exists (
select 1
from que as que2
where que1.customer_id = que2.customer_id  
and (category = 'comedy' or category = 'classic')
);

-- 4) Which actor has appeared in the most English-language movies?
select actor.first_name, actor.last_name,  count(language.name) as times
from actor
inner join film_actor on actor.actor_id = film_actor.actor_id
inner join film on film_actor.film_id = film.film_id
inner join language on film.language_id = language.language_id
where language.name = 'English'
group by actor.first_name, actor.last_name
order by times desc
limit 1;

-- 5) How many distinct movies were rented for exactly 10 days 
-- from the store where Mike works?
select count(distinct film.title) as distinct_films
from rental 
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on film.film_id = inventory.film_id
inner join staff on rental.staff_id = staff.staff_id
where staff.first_name = 'Mike' 
AND DATEDIFF(rental.return_date, rental.rental_date) = 10;

-- 6) Alphabetically list actors who appeared 
--    in the movie with the largest cast of actors.
with que as(
select film_actor.film_id as id
from actor
inner join film_actor on actor.actor_id = film_actor.actor_id
group by id
order by count(film_actor.actor_id) desc limit 1
)
select actor.first_name as name, actor.last_name 
from actor
inner join film_actor on film_actor.actor_id = actor.actor_id
inner join que on que.id = film_actor.film_id
order by name;






