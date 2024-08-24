select * from sales

--FEATURE ENGINEERING
---------------------------------------------------------------------------------------------------------------------------------------------------
-- creating column time of day
select time,
(
case 
when time between '00:00:00' and '12:00:00' then 'Morning'
when time between '12:01:00' and '16:00:00' then 'Afternoon'
else 'Evening'
end 
)as time_of_day
from sales

-- new column
alter table sales add column time_of_day varchar(20)

-- inserting the values to column time_of_day
update sales 
set time_of_day=
(
case 
when time between '00:00:00' and '12:00:00' then 'Morning'
when time between '12:01:00' and '16:00:00' then 'Afternoon'
else 'Evening'
end 
)

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Add day_name column
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

-- Update day_name column with the day name using TO_CHAR
UPDATE sales
SET day_name = TO_CHAR(date, 'FMDay');
-----------------------------------------------------------------------------------

-- Add month_name column
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

-- Update month_name column with the month name using TO_CHAR
UPDATE sales
SET month_name = TO_CHAR(date, 'FMMonth');

--------------------------------------------------------------------------------------------------------------------------
select * from sales
--1)Generic Question
--1.1)How many unique cities does the data have?

select distinct(city) from sales

--1.2)In which city is each branch?

SELECT DISTINCT city, branch FROM sales;

--2)
Product
--2.1)How many unique product lines does the data have?

select distinct(product_line ) from sales

--2.2)What is the most common payment method?
select payment,count(1) 
from sales 
group by payment

--2.3) What is the most selling product line?

with cte as
(
SELECT product_line,sum(quantity),dense_rank()over(order by count(1)desc)
FROM sales 
group by product_line
)
select * from cte where dense_rank=1

--2.4) What is the total revenue by month?

select month_name, sum(total)from sales group by month_name

--2.5)What month had the largest COGS?

with cte as
(
select month_name, sum(cogs),dense_rank()over(order by sum(cogs)desc) as rnk
from sales 
group by month_name 
)
select * from cte  where rnk=1

--2.6) What product line had the largest revenue?

with cte as
(
select product_line ,sum(total),dense_rank()over(order by sum(total)desc) as rnk
from sales group by product_line
)

select * from cte where rnk=1

--2.7)What is the city with the largest revenue?

with cte as
(
select city ,sum(total),dense_rank()over(order by sum(total)desc) as rnk
from sales group by city
)

select * from cte where rnk=1

--2.8)What product line had the largest VAT?

select*  from sales

--2.9)Fetch each product line and add a column to those product 
--line showing "Good", "Bad". Good if its greater than or eqal to average sales

with cte as
(
select product_line,round(avg(quantity),0) as  avg_qty_category
from sales
group by product_line
)

select *,case
when avg_qty_category >=(select round(avg(quantity),0)from sales) then 'GOOD'
else 'BAD'
end as remark 
from cte

--2.10)Which branch sold more products than average product sold?

select branch ,round(avg(quantity),0) as  avg_per_branch
from sales
group by branch
having (round(avg(quantity),0)) >=(select round(avg(quantity),0) from sales)

--2.11)What is the most common product line by gender?

select gender,product_line,count(1)
from sales 
group by gender,product_line
order by gender,3 desc

--2.12)What is the average rating of each product line?

SELECT product_line,round(AVG(rating)::numeric, 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

--3)Sales

--3.1)Number of sales made in each time of the day per weekday
select * from sales

--3.2)Which of the customer types brings the most revenue?

select customer_type,sum(total) 
from sales 
group by customer_type
order by 2 desc

--3.3)Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    ROUND(AVG(tax_pct)::numeric, 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;
--3.4)Which customer type pays the most in VAT?

SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

--4 Customer
--4.1)How many unique customer types does the data have?

select distinct(customer_type) 
from sales

--4.2)How many unique payment methods does the data have?

select distinct(payment) 
from sales

--4.3)What is the most common customer type?

select customer_type,count(1)
from sales
group by customer_type

--4.4) Which customer type buys the most?

select customer_type,sum(quantity) as quatity,sum(total) as revenue
from sales
group by customer_type

--4.5)What is the gender of most of the customers?
select gender,count(1)
from sales
group by gender

--4.6)What is the gender distribution per branch?

select branch,gender,count(1)
from sales
group by gender,branch
order by branch

--4.7)Which time of the day do customers give most ratings?

SELECT time_of_day,AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC

--4.8)Which time of the day do customers give most ratings per branch?

SELECT branch,time_of_day,AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day,branch
ORDER BY branch,avg_rating DESC

--4.9)Which day of the week has the best avg ratings?

select day_name,avg(rating),dense_rank()over(order by avg(rating)desc )
from sales
group by day_name

--4.10)Which day of the week has the best average ratings per branch?

select branch,day_name,avg(rating),
dense_rank()over(partition by branch order by avg(rating)desc )
from sales
group by branch,day_name
order by branch

