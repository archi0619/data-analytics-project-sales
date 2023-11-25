/* Считаем количество клиентов*/

select COUNT(c.customer_id) as customers_count
from customers c;
