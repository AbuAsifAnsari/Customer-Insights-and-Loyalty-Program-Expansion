SELECT * FROM project.sales;

SELECT * FROM project.menu;

SELECT * FROM project.members;


Q.1 What is the total amount each customer spent at the restaurant?

select
s.Customer_id, sum(m.Price) as total
from 
Sales as s
join
Menu as m
on s.Product_id = m.Product_id
group by 1

Q.2 How many days has each customer visited the restaurant?

select
Customer_id, count(distinct Order_date) as days
from 
sales
group by 1


Q.3 What was the first item from the menu purchased by each customer?

with a as
(select
s.Customer_id, m.Product_Name, s.Order_date,
dense_rank() over (partition by Customer_id order by Order_date) as rank_
from
sales as s
join 
menu as m
on s.product_id = m.product_id)

select Customer_id, Product_Name, Order_date 
from a 
where rank_ = 1




with a as
(select
s.Customer_id, m.Product_Name, s.Order_date,
dense_rank() over (partition by Customer_id order by Order_date) as rank_
from 
sales as s
join 
menu as m
on s.Product_id = m.Product_id)

select Customer_id, Product_Name, Order_date
from a
where 
rank_ = 1

Q.4 What is the most purchased item on the menu and how many times was it purchased by all customers?

select 
m.Product_Name, count(s.product_id) as cnt
from
sales as s
join 
menu as m
on s.product_id = m.product_id
group by 1 
order by 2 desc 
limit 1


select 
m.Product_Name, count(s.Product_id) as cnt
from
sales as s
join 
menu as m
on s.Product_id = m.Product_id
group by m.Product_Name 
order by 2 desc 
limit 1

Q.5 Which item was the most popular one for each customer?



with a as
(select 
s.Customer_id, m.Product_Name, count(s.Product_id) as cnt,
dense_rank() over (partition by Customer_id order by count(s.Product_id) desc) as rank_
from
sales as s
join 
menu as m
on s.product_id = m.product_id
group by 1, 2)

select Customer_id, Product_Name,cnt from a
where rank_ = 1


Q.6 Which item was purchased first by the customer after they became a member?

with a as
(select
s.customer_id, e.Product_Name, s.Order_date, m.join_date,
dense_rank() over (partition by customer_id order by Order_date) as rank_
from 
sales as s
join 
members as m
on s.Customer_id = m.Customer_id
join 
menu as e
on s.product_id = e.product_id
where s.Order_date > m.join_date)

select customer_id, Product_Name, join_date, order_date
from a 
where rank_ = 1

Q.7 Which item was purchased right before the customer became a member?

with a as
(select
s.customer_id, e.Product_Name, s.Order_date, m.join_date,
dense_rank() over (partition by customer_id order by Order_date desc) as rank_
from 
sales as s
join 
members as m
on s.Customer_id = m.Customer_id
join 
menu as e
on s.product_id = e.product_id
where s.Order_date < m.join_date)

select customer_id, Product_Name, join_date, order_date
from a 
where rank_ = 1

Q.8 What is the total number of items and amount spent for each member before they became a member?

with a as
(select
s.customer_id, s.product_id, e.price, s.order_date, m.join_date,
dense_rank() over (partition by customer_id order by order_date desc) as rank_
from 
sales as s
join 
members as m
on s.Customer_id = m.Customer_id
join 
menu as e
on s.product_id = e.product_id
where s.Order_date < m.join_date)

select customer_id, count(product_id) as cnt, sum(price) as amount
from a 
group by 1

select
s.customer_id, count(s.product_id) as cnt, sum(e.price) as amount
from 
sales as s
join 
members as m
on s.Customer_id = m.Customer_id
join 
menu as e
on s.product_id = e.product_id
where s.Order_date < m.join_date

group by 1
order by 1

Q.9 If each customers’ $1 spent equates to 10 points and 'Sukiya' has a 2x points multiplier — how many points would each customer
have?

select 
s.Customer_id, 
sum(case when m.Product_Name = 'Sukiya' then 2*10*m.price else 10*m.price end) as points
from 
sales as s 
join 
menu as m
on s.Product_id = m.Product_id
group by 1

Q.10 In the first week after a customer joins the program, (including their join date) they earn 2x points on all items; not just sushi —
how many points do customer A and B have at the end of aug24?

select 
a.Customer_id, sum(case when m.product_name = 'Sukiya' then 2*10*m.price
when s.order_date between a.join_date and a.valid_date then 2*10*m.price else 10*m.price end) as points
from
(select
Customer_id, join_date, date_add(join_date, interval 6 day) as valid_date
from 
members) as a
join
sales as s 
on s.Customer_id = a.Customer_id
join 

menu as m
on s.product_id = m.product_id

where s.Order_date < '2024-08-31' and s.Customer_id in ('A', 'B')
group by 1