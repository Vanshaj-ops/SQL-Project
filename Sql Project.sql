
#This project showcases a self-initiated practice in data analysis, featuring a mock database created using Python. 
#All the information within this dataset is entirely fictional and does not represent any real individuals or entities. 
#The primary purpose of this project was to enhance my proficiency in SQL syntax and database querying techniques.
#In this analysis, I explored fundamental and advanced insights that can be derived from a dataset. 
#While some columns, such as category or product names, contain randomly generated words that may not always make logical sense, 
#there was no compromise in the depth of knowledge applied. This project was purely undertaken for skill development and hands-on practice in SQL.
#________________________________________________________________________________________________________________________________________________________________


use ecom;
# -------------------------- Query 1: Total Amount Spent by Customers --------------------------
# Using CTE to calculate total spending per customer, then filtering those who spent more than 2000
# and displaying top 10 customers sorted by amount spent.

with cte as (
	select c.CustomerID, 
		c.FirstName,
		c.LastName , 
		sum(o.TotalAmount) as Total_Spent 
	from 
		customers c 
	join 
		orders o 
	on 	
		o.CustomerID = c.CustomerID 
    group by 
		c.FirstName, c.CustomerID, c.LastName)
	select 
		* from cte 
	where 
		Total_Spent > 2000 
	order by 
		Total_Spent desc 
	limit 10;

# ---------------------- Query 2: Ranking Products Based on Total Revenue ----------------------
# Calculates total revenue generated per product, ranks the top 10 products based on revenue.

 with cte as(
 select p.ProductName, round(sum(p.Price * oi.Quantity)) as Total_Revenue
 from products p join order_items oi on	oi.ProductID  = p.ProductID group by p.ProductName, p.ProductID)
 select ProductName, Total_Revenue, rank () over(order by Total_Revenue desc ) as Rank_Total_Revenue from cte limit 10  ;

 # ---------------------- Query 3: Cumulative Revenue Over Time ----------------------
# Computes daily revenue per order and calculates cumulative sum over time.
with 
	Cumulative_Rev_over_time 
		as
(select 	
	o.OrderID, 
    o.OrderDate
as 
	OrderDate, 
    sum(p.Price * oi.Quantity) as Total_Revenue 
from 
	products p 
	join 
	order_items oi 
	on 
	oi.ProductID = p.ProductID 
	join 
	orders o
	on 
	o.OrderID = oi.OrderID 
group by 
	o.OrderDate, o.OrderID ) 
select  
	OrderDate, 
	Total_Revenue,
    sum(Total_Revenue) over(order by OrderDate) 
from 
	Cumulative_Rev_over_time  ;



# ---------------------- Query 4: Average Order and Payment Amount by Product ----------------------
# Joins several tables to compute the average order value and average payment amount per product and customer.
SELECT 
    pr.ProductName,
    c.FirstNAME,
    ROUND(AVG(o.TotalAmount), 2) AS Avg_Order_value,
    ROUND(AVG(p.PaymentAmount), 2) AS Avg_payment_amount
FROM
    orders o
        JOIN
    customers c ON c.CustomerID = o.CustomerID
        JOIN
    payments p ON p.OrderID = o.orderID
        JOIN
    order_items oi ON oi.OrderID = p.OrderID
        JOIN
    products pr ON pr.ProductID = oi.ProductID
GROUP BY c.FirstName , pr.ProductName , c.CustomerID;
    

# ---------------------- Query 5: Shipping Delays ----------------------
# Calculates the number of days between shipping and delivery, and filters records where delay >= 7 days.
    
    with cte as(
    SELECT 
    s.ShippingDate,
    s.DeliveryDate,
    datediff(s.DeliveryDate,s.ShippingDate) as Days_Diff,
    p.ProductName
FROM
    shipping s
        JOIN
    order_items oi ON s.OrderID = oi.OrderID
        JOIN
    products p ON p.ProductID = oi.ProductID order by ShippingDate) select * from cte where Days_Diff >= 7 order by Days_Diff asc;
    
# ---------------------- Query 6: Multiple Payments ----------------------    
-- Finds customers who used more than 2 different payment methods for a single order
with 
	cte as (
select
	o.OrderID, 
    c.FirstName, 
    c.LastName, 
    count(distinct p.PaymentMethod) as PaymentMethod 
from 
	orders o 
    join 
    customers c  
    on c.CustomerID =o.CustomerID 
    join 
    payments p 
    on 
    p.OrderID = o.OrderID 
group by c.FirstName, c.LastName, o.OrderID)
select 
	* 
from 
	cte 
where 
	PaymentMethod > 2 ;
# ----------------------------- Query 7: Average Quantity by Product -----------------------------
-- Calculates the average quantity ordered for each product
SELECT 
    p.ProductID,
    p.ProductName,
    ROUND(AVG(o.Quantity), 2) AS Avg_Quantity
FROM
    order_items o
        JOIN
    products p ON p.ProductID = o.ProductID
GROUP BY p.ProductID , p.ProductName
ORDER BY avg_quantity DESC
;

# ----------------------------- Query 8: Total Revenue by Product (Temporary Table) -----------------------------
-- Creates a temporary table of total revenue generated per product

create temporary table Sales
select 
	p.ProductName, 
    sum(p.Price*oi.Quantity) As Total_Revenue 
from 
	products p 
    join order_items oi 
    on 
    oi.ProductID = p.ProductId 
group by p.ProductName;

SELECT 
    *
FROM
    sales;

# ----------------------------- Query 9: High Revenue Categories -----------------------------
-- Identifies product categories with highest revenue and ranks them

with cte as(
SELECT 
    c.CategoryName,
    
    ROUND(SUM(p.Price * oi.Quantity))  as Total_Category_Revenue
FROM
    products p
        JOIN
    categories c ON c.CategoryID = p.CategoryID
        JOIN
    order_items oi ON oi.ProductID = p.ProductID
GROUP BY c.CategoryName)
select  
	CategoryName, 
    Total_Category_Revenue, 
    rank() over( order by Total_Category_Revenue DESC ) as Rank_ 
from 
	cte ;

# ----------------------------- Query 10: Best Selling Products -----------------------------
-- Lists top 10 products based on total sales revenue

with 
cte as (
select 
	p.ProductName, 
    sum(p.Price * oi.Quantity) as Total_Revenue 
from 
	products p 
    join order_items oi 
    on 
    oi.ProductID = p.ProductID 
group by p.ProductName )
select 
	ProductName, 
    round(Total_Revenue) as Total_Revenue, 
    rank() over(order by Total_Revenue desc) as Rank_TR  
from 
	cte limit 10; 
# ----------------------------- Query 11: Top 10 Customers by Spending -----------------------------
-- Shows top 10 customers ranked by their total spending
with 
cte as(
select  
	c.FirstName,
    c.LastName, 
    sum(o.TotalAmount) as Total_Spending 
from 
	customers c 
    join 
    orders o 
    on o.CustomerID = c.CustomerID 
group by c.FirstName, c.LastName) 
select 
	FirstName,
    LastName, 
    round(Total_Spending) as Total_Spending, 	
    rank() over (order by Total_Spending desc) as Rank_Of_Customer_By_Total_Spending 
from 
	cte limit 10;  

# ----------------------------- Query 12: Monthly Revenue Trend -----------------------------
-- Tracks monthly revenue and cumulative revenue growth over time
with 	
cte as(
select 
	date_format(o.OrderDate, '%Y-%m') as Date,
	round(sum(TotalAmount)) as Total_Revenue 
from 
	orders o 
group by date)
select 
	*, 
    round(sum(Total_Revenue) over(order by date)) as Cumm_Total_Revenue 
    from cte ;
# ----------------------------- Query 13: Average Delayed Days by Order Status -----------------------------
-- Calculates the average delivery delay for orders based on their status
SELECT 
    o.Status,
    ROUND(AVG(DATEDIFF(sh.DeliveryDate, sh.ShippingDate))) AS Avg_Delayed_Days
FROM
    shipping sh
        JOIN
    orders o ON o.OrderID = sh.OrderID
GROUP BY o.Status
ORDER BY Avg_Delayed_Days DESC;

# ----------------------------- Query 14: Most Preferred Payment Method -----------------------------
-- Lists payment methods ranked by usage frequency and total payment amount

SELECT 
    PaymentMethod,
    COUNT(PaymentID) AS Count_of_Transaction,
    ROUND(SUM(PaymentAmount)) AS Total_Paymen_Amount
FROM
    payments
GROUP BY PaymentMethod
ORDER BY Count_of_Transaction DESC;

# ----------------------------- Query 15: Long Delivery Durations -----------------------------
-- Finds orders that took 14 or more days between shipping and delivery
SELECT 
    o.OrderID,
    o.TotalAmount AS Total_Amount,
    s.ShippingDate,
    s.DeliveryDate,
    DATEDIFF(s.DeliveryDate, s.ShippingDate) AS Date_Diff
FROM
    orders o
        JOIN
    shipping s ON o.OrderID = s.OrderID
HAVING Date_Diff >= 14
ORDER BY date_diff , Total_Amount DESC;


# ----------------------------- Query 16: Number of Orders per Customer -----------------------------
-- Counts how many orders each customer has placed

SELECT 
    c.FirstName, c.LastName, COUNT(o.OrderDate) AS count_of_date
FROM
    customers c
        JOIN
    orders o ON o.CustomerID = c.CustomerID
GROUP BY c.FirstName , o.OrderDate , c.LastName
ORDER BY count_of_Date DESC;

# ----------------------------- Query 17: Average Order Value Over Time -----------------------------
-- Calculates average order value per month
SELECT 
    *
FROM
    orders;
with 
cte as (
select  
	date_format(orderDate, '%Y,%m') as month ,
    round(sum(TotalAmount),2) as Total_Amount, 
    count(OrderId) as total_order 
from 
	orders 
group by month )
select  
	month,
    Total_Amount, 
    Total_order, 
    round((Total_Amount / Total_order),2) as avg_order_value 
from 
cte 
order by 
Total_Amount desc;

# ----------------------------- Query 18: Customer Segmentation -----------------------------
-- Segments customers into High, Middle, and Low value based on total spending
with cte as(
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ROUND(SUM(o.TotalAmount)) AS Total_Amount
FROM
    customers c
        JOIN
    orders o ON c.CustomerID = o.OrderID
GROUP BY c.CustomerID , c.FirstName , c.LastName order by Total_Amount desc)
SELECT 
    *,
    CASE
        WHEN Total_Amount > 800 THEN 'High_Value'
        WHEN Total_Amount BETWEEN 500 AND 800 THEN 'Middle Value'
        ELSE 'Low_Value'
    END AS Customer_Category
FROM
    cte
ORDER BY Total_Amount desc;

# ----------------------------- Query 19: Most Profitable Products and Categories -----------------------------
-- Ranks products and categories by total revenue contribution
select * from products;
select * from order_items;
select * from categories;
with cte as(
SELECT 
    c.CategoryName,
    p.ProductName,
    round(sUM(oi.Quantity * p.Price)) AS Total_Revenue
FROM
    products p
        JOIN
    categories c ON c.CategoryID = p.CategoryID
        JOIN
    order_items oi ON oi.ProductID = p.ProductID
GROUP BY c.CategoryName , p.ProductName)
    select 
    *,
    rank () over(order by Total_Revenue desc) as _Rank
from 
cte;
# ----------------------------- Query 20: Customer Retention and Churn Rate -----------------------------
-- Identifies active, at-risk, and lost customers based on their most recent order date
with cte as(

SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    MAX(o.OrderDate) AS last_Date
FROM
    customers c
        LEFT JOIN
    orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID , c.FirstName , c.LastName)
select *, case when last_date < date_sub(curdate(), interval 6 month) then "At_Risk"
 when last_date < date_sub(curdate(), interval  5 month) then "Lost"
else "Active"
end as Customer_Status
from cte order by Customer_Status asc; 
select * from products;
select * from order_items;
# ----------------------------- Query 21: Average Order Value for Specific Customer -----------------------------
-- Calculates average order value for customer Dakota Gonzales using item-level data

select * from orders;
select * from customers;
select * from products;
select * from order_items;
with cte as (
SELECT 
    o.OrderID,
    o.CustomerID,
	O.OrderDate,
    ROUND(sum(p.Price * oi.Quantity)) AS Total_Order_Value
FROM
    orders o
        JOIN
    order_items oi ON oi.OrderID = o.OrderID
        JOIN
    products p ON p.ProductID = oi.ProductID
GROUP BY o.OrderID, o.CustomerID)
SELECT 
    c.FirstName, c.LastName, round(avg(Total_Order_Value)) as Avg_Value
FROM
    cte a
        JOIN
    customers c ON a.CustomerID = c.CustomerID
    where FirstName = "Dakota" and LastNAME = "Gonzales"
GROUP BY c.FirstName , c.LastName , Total_Order_Value
ORDER BY Total_Order_Value DESC;

# ----------------------------- Query 22: Same Query Using Aggregated Method -----------------------------
-- Alternate way to calculate average order value for Dakota Gonzales using grouped totals

select * from orders;
with cte as(
SELECT 
    c.FirstName,
    C.LastName,
    ROUND(SUM(p.Price * oi.Quantity)) AS Total_Order_Value
FROM
    orders o
        JOIN
    order_items oi ON o.OrderID = oi.OrderID
        JOIN
    products p ON p.ProductID = oi.ProductID
        JOIN
    customers c ON c.CustomerID = o.CustomerID
        where FirstName = "Dakota" and LastNAME = "Gonzales"
GROUP BY c.FirstName , c.LastName)
SELECT 
    FirstName,
    LastName,
    ROUND(AVG(Total_Order_Value)) AS Avg_Total_Value
FROM
    cte a group by Total_Order_Value,FirstNAME,LastNAME,Total_Order_Value order by Total_Order_Value desc;