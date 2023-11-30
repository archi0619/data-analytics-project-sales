/* Считаем количество клиентов*/

select COUNT(c.customer_id) as customers_count
from customers c
;

/* Выводим ТОП 10 товаров по сумме продаж в пордке убывания суммы: */

SELECT
	s.ProductID,
	FLOOR(SUM(s.Quantity * p.Price)) AS Amount
FROM sales s
LEFT JOIN products p
	ON s.ProductID = p.ProductId
GROUP BY s.ProductID
ORDER BY Amount DESC
LIMIT 10
;

/* Выводим ТОП 10 продавцов по выручке в порядке убывания*/

select
	concat(e.first_name, ' ', e.last_name) as name,
	count(s.sales_person_id) as operations,
	FLOOR(SUM(s.quantity * p.price)) as income
from employees e
left join sales s
	on e.employee_id = s.sales_person_id
left join products p
	on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
order by income desc nulls last
limit 10
;

/* Выводим данные о продавцах,
 * чья средняя выручка ниже общей средней выручки*/

with tab as (
select
	concat(e.first_name, ' ', e.last_name) as name,
	FLOOR(AVG(s.quantity * p.price)) as average_income
from employees e
left join sales s
	on e.employee_id = s.sales_person_id
left join products p
	on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
)
select *
from tab
where tab.average_income < (
							select
								FLOOR(AVG(s.quantity * p.price))
							from sales s
							left join products p
								on s.product_id = p.product_id
)
order by average_income asc
;

/* Выводим данные по выручке по каждому продавцу и дню недели,
 * сортированные по порядковому номеру дня недели*/

with income_per_weekday as (
select
	to_char(s.sale_date, 'day') as weekday,
	EXTRACT(ISODOW from s.sale_date),
	concat(e.first_name, ' ', e.last_name) as name,
	FLOOR(SUM(s.quantity * p.price)) as income
from employees e
left join sales s
	on e.employee_id = s.sales_person_id
left join products p
	on s.product_id = p.product_id
group by
	concat(e.first_name, ' ', e.last_name),
	to_char(s.sale_date, 'day'),
	EXTRACT(ISODOW from s.sale_date)
order by
	EXTRACT(ISODOW from s.sale_date),
	concat(e.first_name, ' ', e.last_name)
)
select
	ipr.name,
	ipr.weekday,
	ipr.income
from income_per_weekday as ipr
;

/*Группируем таблицу с клиентами в зависимости от возрастной категории */

with age_text as (
select
	*,
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category
from customers
)
select
	age_category,
	count(age_category) as count
from age_text
group by age_category
order by age_category
;

/* Выводим данные по количеству уникальных покупателей и выручке, которую они принесли.
 * Данные сгруппированы по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. */

select
	to_char(s.sale_date, 'YYYY-MM') as date,
	count(distinct(customer_id)) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from sales s
join products p 
	on s.product_id = p.product_id
group by date
order by date
;

/* Выводим данные о покупателях, первая покупка которых была в ходе проведения акций
 * (акционные товары отпускали со стоимостью равной 0).
 * Итоговая таблица отсортирована по id покупателя. */

with tab as (
select
	concat(c.first_name, ' ', c.last_name) as customer,
	min(s.sale_date) over (partition by concat(c.first_name, ' ', c.last_name)) as sale_date,
	min(concat(e.first_name, ' ', e.last_name)) as seller
from sales s
left join products p
	on s.product_id = p.product_id
left join customers c
	on s.customer_id = c.customer_id
left join employees e
	on s.sales_person_id = e.employee_id
group by
	s.customer_id,
	customer,
	sale_date
having sum(s.quantity * p.price) = 0
order by s.customer_id
)
select distinct *
from tab
;
