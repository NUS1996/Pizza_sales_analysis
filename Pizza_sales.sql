CREATE DATABASE pizza_store; 

DROP TABLE IF EXISTS orders; 
CREATE TABLE orders ( 
order_id INT NOT NULL, 
date date NOT NULL,
time time NOT NULL 
);   

CREATE TABLE order_details 
 ( 
order_details_id INT NOT NULL, 
order_id INT NOT NULL, 
pizza_id TEXT NOT NULL, 
quantity INT NOT NULL  
); 

# Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders FROM orders;

# Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(od.quantity* p.price),2) AS total_revenue 
FROM order_details od
LEFT JOIN pizzas p 
ON od.pizza_id = p.pizza_id
;

# Identify the highest-priced pizza.

SELECT pt.name, p.price 
FROM pizzas p 
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY 2 DESC 
LIMIT 1;

# Identify the most common pizza size ordered.

SELECT p.size, COUNT(od.order_details_id) FROM order_details od 
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size 
ORDER BY 2 DESC
LIMIT 1;

# List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, SUM(od.quantity) AS total_quantity  , COUNT(od.order_details_id) AS times_ordered FROM order_details od 
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name 
ORDER BY 2 DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantity FROM order_details od 
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC; 

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(time), COUNT(order_id)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name) 
FROM pizza_types
GROUP BY category
ORDER BY 2 DESC; 

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(avg_pizza_ordered),0) FROM 
(
SELECT o.date, SUM(od.quantity) AS avg_pizza_ordered FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1 
ORDER BY 2 DESC) AS total_order_per_day 
;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, SUM(od.quantity*p.price) AS revenue FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY 2 DESC 
LIMIT 3;
 
 # Calculate the percentage contribution of each pizza type to total revenue.
 
SELECT pt.category, ROUND(SUM(od.quantity*p.price) / (SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
FROM order_details 
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2)  AS revenue FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY 2 DESC; 

-- Analyze the cumulative revenue generated over time.
SELECT revenue.date,ROUND(SUM(total_price) OVER(order by revenue.date),2) AS cummulative_revenuew
FROM
(SELECT o.date, SUM(od.quantity * p.price) AS total_price 
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY o.date) AS revenue; 

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category. 

SELECT category, name, revenue, ranking
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS ranking
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
) AS ranked_pizzas
WHERE ranking <= 3;



 







 


 








