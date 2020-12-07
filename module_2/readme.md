# Комментарии к модулю 2

## Модуль 2.3

В файлах orders.sql, people.sql, returns.sql находится код для создания таблиц на основе данных из файла интернет-магазина из Sample - Superstore.xls. Все работы выполнялись в
PostgreSQL через PgAdmin 4.26 локально.


## Модуль 2.4


Модель базы данных, разработанная через sqldbm.com:

![Model of store data](https://github.com/Gennadynemchin/datalearn/blob/main/module_2/dimensional_model.png)

Создание и insert таблиц находится в файле 2.4_modelling.sql. Модель создается в новой схеме dim. В таблице emp_dim (менеджеры) происходит генерация суррогатных id для emp_id - 
уникальные идентификаторы сотрудников. 
Таблица products_dim: здесь параллельно существует product_id (суррогатный ключ, генерируется при инсерте) и product_id_1 - берется при select distinct из нашей родительской 
таблицы public.orders. Это сделано для того, чтобы обойти проблему двойного id в одном продукте. Таким образом, мы сохранили изначальные строки с id и создали уникальные.
В таблице sales_fact id генерируется при инсерте. Джоин происходит при помощи запроса в родительскую таблицу public.orders:

```sql
SELECT distinct
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
join dim.orders_dim on o.order_id = dim.orders_dim.order_id
```

В коде выше: выбираем необходимые нам колонки (уникальные, чтобы не было повторений) из таблицы public.orders и наших таблиц-словарей, производя inner join между public.orders и таблицами-словарями. 


## Модуль 2.6(2.5)

Создание схемы для этого дашборда находится в директории 2.5: stg_orders.sql, from_stg_to_dw.sql

Ссылка на дашбоард:

https://datastudio.google.com/reporting/314e9e7f-ea5b-4f33-9764-e02bb6510871


![Screenshot of Dashboard](https://github.com/Gennadynemchin/datalearn/blob/main/module_2/2.5/Dashboard_Homework.jpg)

