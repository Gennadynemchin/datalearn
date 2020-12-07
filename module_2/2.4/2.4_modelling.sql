-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "customers_dim"

CREATE TABLE "dim"."customers_dim"
(
 "customer_id"   varchar(50) NOT NULL,
 "customer_name" varchar(50) NOT NULL,
 "segment"       varchar(50) NOT NULL,
 CONSTRAINT "PK_customers_dim" PRIMARY KEY ( "customer_id" )
);


-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "dates_dim"

CREATE TABLE "dim"."dates_dim"
(
 "order_date" date NOT NULL,
 CONSTRAINT "PK_dates_dim" PRIMARY KEY ( "order_date" )
);


-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "emp_dim"

CREATE TABLE "dim"."emp_dim"
(
 "emp_id" integer NOT NULL,
 "person" varchar(50) NOT NULL,
 "region" varchar(50) NOT NULL,
 CONSTRAINT "PK_emp_dim" PRIMARY KEY ( "emp_id" )
);


-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "orders_dim"

CREATE TABLE "dim"."orders_dim"
(
 "order_id"    varchar(50) NOT NULL,
 "ship_mode"   varchar(50) NOT NULL,
 "ship_date"   date NOT NULL,
 "country"     varchar(50) NOT NULL,
 "state"       varchar(50) NOT NULL,
 "city"        varchar(50) NOT NULL,
 "postal_code" varchar(50) NULL,
 "returned"    varchar(50) NULL,
 CONSTRAINT "PK_orders_dim" PRIMARY KEY ( "order_id" )
);


-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "products_dim"

CREATE TABLE "dim"."products_dim"
(
 "product_id"   integer NOT NULL,
 "category"     varchar(250) NOT NULL,
 "subcategory"  varchar(250) NOT NULL,
 "product_name" varchar(250) NOT NULL,
 "product_id_1" varchar(250) NOT NULL,
 CONSTRAINT "PK_products_dim" PRIMARY KEY ( "product_id" )
);


-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "sales_fact"

CREATE TABLE "dim"."sales_fact"
(
 "id"          integer NOT NULL,
 "sales"       numeric NOT NULL,
 "quantity"    numeric NOT NULL,
 "discount"    numeric NOT NULL,
 "profit"      numeric NOT NULL,
 "order_date"  date NOT NULL,
 "product_id"  integer NOT NULL,
 "emp_id"      integer NOT NULL,
 "order_id"    varchar(50) NOT NULL,
 "customer_id" varchar(50) NOT NULL,
 CONSTRAINT "PK_sales_fact" PRIMARY KEY ( "id" ),
 CONSTRAINT "FK_100" FOREIGN KEY ( "order_date" ) REFERENCES "dim"."dates_dim" ( "order_date" ),
 CONSTRAINT "FK_110" FOREIGN KEY ( "product_id" ) REFERENCES "dim"."products_dim" ( "product_id" ),
 CONSTRAINT "FK_118" FOREIGN KEY ( "emp_id" ) REFERENCES "dim"."emp_dim" ( "emp_id" ),
 CONSTRAINT "FK_131" FOREIGN KEY ( "order_id" ) REFERENCES "dim"."orders_dim" ( "order_id" ),
 CONSTRAINT "FK_139" FOREIGN KEY ( "customer_id" ) REFERENCES "dim"."customers_dim" ( "customer_id" )
);

CREATE INDEX "fkIdx_100" ON "dim"."sales_fact"
(
 "order_date"
);

CREATE INDEX "fkIdx_110" ON "dim"."sales_fact"
(
 "product_id"
);

CREATE INDEX "fkIdx_118" ON "dim"."sales_fact"
(
 "emp_id"
);

CREATE INDEX "fkIdx_131" ON "dim"."sales_fact"
(
 "order_id"
);

CREATE INDEX "fkIdx_139" ON "dim"."sales_fact"
(
 "customer_id"
);




insert into dim.customers_dim (customer_id, customer_name, segment)
select customer_id, customer_name, segment from
(select distinct customer_id, customer_name, segment from public.orders) a;


insert into dim.dates_dim (order_date)
select distinct order_date from public.orders;


insert into dim.emp_dim (emp_id, person, region)
select 100+row_number() over (), person, region from 
(select distinct person, region from public.people) a;


insert into dim.orders_dim (order_id, ship_mode, ship_date, country, state, city, postal_code, returned)
select order_id, ship_mode, ship_date, country, state, city, postal_code, returned from 
(select distinct orders.order_id, ship_mode, ship_date, country, state, city, postal_code, returned from 
public.orders left join public.returns on public.returns.order_id=orders.order_id) a;


insert into dim.products_dim (product_id, category, subcategory, product_name, product_id_1)
select 100+row_number() over (), category, subcategory, product_name, product_id from 
(select distinct category, subcategory, product_name, product_id from public.orders) a;



insert into dim.sales_fact 
(id,
sales,
quantity,
discount,
profit,
order_date,
product_id,
emp_id,
order_id,
customer_id)

select
100+row_number() over (),
sales,
quantity,
discount,
profit,
order_date,
product_id,
emp_id,
order_id,
customer_id

from 
(SELECT distinct
sales,
quantity,
discount,
profit,
c.customer_id,
d.order_date,
e.emp_id,
p.product_id,
dim.orders_dim.order_id
from public.orders o inner 
join dim.customers_dim c on o.customer_id = c.customer_id
join dim.dates_dim d on o.order_date = d.order_date
join dim.emp_dim e on o.region = e.region
join dim.products_dim p on o.product_id = p.product_id_1 and p.product_name = o.product_name 
join dim.orders_dim on o.order_id = dim.orders_dim.order_id) a