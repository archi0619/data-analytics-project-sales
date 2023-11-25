/* Считаем количество клиентов*/

select COUNT(c.customer_id) as customers_count
from customers c;

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
limit 10;

/* Выводим данные о продавцах, чья средняя выручка ниже общей средней выручки*/

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
order by average_income asc;

/* Выводим данные по выручке по каждому продавцу и дню недели, сортированные по порядковому номеру дня недели*/
with income_per_weekday as (
select
	to_char(s.sale_date, 'Day') as weekday,
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
	to_char(s.sale_date, 'Day'), EXTRACT(ISODOW from s.sale_date)
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

