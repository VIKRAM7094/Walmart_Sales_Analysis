select * from walmart

select count(*) from walmart;

select payment_method, count(*) from walmart
group by payment_method;

select count(Distinct branch) from walmart;

select max(quantity) from walmart;

Select min(quantity)from walmart;

-- Business problems

-- Q.1 
-- Find different payment method and number of transactions, number of quantity sold

select payment_method, 
count(*)as no_payment,
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Question 2 
-- Identify the Highest-Rated Category in Each Branch, displaying the branch, category average rating in each branch?
SELECT  
    branch,  
    category,  
    avg_rating,  
    RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS 'rank'  
FROM (  
    SELECT  
        branch,  
        category,  
        AVG(rating) AS avg_rating  
    FROM walmart  
    GROUP BY branch, category  
) AS subquery;

-- Question 3 
-- identify the busiest day for each branch based on the number of transaction
SELECT * 
FROM (
    SELECT
        branch,
        DATE_FORMAT(STR_TO_DATE(date, '%d-%m-%Y'), '%W') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_days
WHERE `rank` = 1;

-- Question 4 
-- Calculate the total quantity of items sold per payment method. list payment_method and total_quantity.alter
select payment_method, 
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Question 5 
-- Determine the average, minimum, and maximum rating of category for each city.
-- List the city, average_rating, min_rating and max_rating.
Select 
city, category,
min(rating) as min_rating,
max(rating) as max_rating,
AVg(rating) as avg_rating
from walmart
group by city, category;

-- Question 6 
-- Calculate the total profit for each category by considering total_profit as
-- (unit_prize * quantity * profit_margin).
-- List category and total_profit,ordered from highest to lowest profit.
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Question 7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY total_trans DESC) AS `rank`
    FROM (
        SELECT 
            branch,
            payment_method,
            COUNT(*) AS total_trans
        FROM walmart
        GROUP BY branch, payment_method
    ) AS sub
)
SELECT 
    branch, 
    payment_method AS preferred_payment_method, 
    total_trans, 
    `rank`
FROM cte
WHERE `rank` = 1;

-- Question 8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Question 9
-- Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS cr_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS rev_dec_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;

