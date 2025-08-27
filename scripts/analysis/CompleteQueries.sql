# Complete SQL
# 1. Using a CTE, calculate the total sales per customer in 2023, then list the top 5 customers by spending -> CTE, AGG, GROUP BY, JOINS
SELECT c.CustomerID, c.CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSales
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY CustomerID, CustomerName
ORDER BY TotalSales DESC
LIMIT 5;

# 2. Find the number of orders each product received in 2022, then join it with product to display product name and sales count.
SELECT p.ProductName, COUNT(oi.OrderID) AS SalesCount
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2022
GROUP BY ProductName;

# 3. find customers whose spending increased in 2023 compared to 2022 -> CTE, AGG, GROUP BY, JOINS, CASE WHEN
WITH Spending22 AS (
	SELECT c.CustomerID, c.CustomerName, SUM(oi.TotalAmount) AS TotalSpending22
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID= oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2022
    GROUP BY CustomerID, CustomerName
),
Spending23 AS (
	SELECT c.CustomerID, c.CustomerName, SUM(oi.TotalAmount) AS TotalSpending23
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID= oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY CustomerID, CustomerName
)
SELECT s22.CustomerID, s22.CustomerName,
	   CASE 
		   WHEN s23.TotalSpending23 > s22.TotalSpending22 THEN 'Increased'
           ELSE 'Decreased'
		END AS SpendingGrowth
FROM Spending22 AS s22 JOIN Spending23 AS s23
	ON s22.CustomerID = s23.CustomerID;

# 4. Get each product’s total sales in 2023, and then return only those with sales greater than the average sales of all products in 2023.
WITH TotalSales AS (
	SELECT p.ProductName, ROUND(SUM(od.LineTotal)) AS TotalSalesAmount
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY ProductName
),
AverageSales AS (
	SELECT ROUND(AVG(TotalSalesAmount)) AS AverageSales23
    FROM TotalSales
)
SELECT t.ProductName, t.TotalSalesAmount, a.AverageSales23
FROM TotalSales AS t CROSS JOIN AverageSales AS a 
WHERE TotalSalesAmount > AverageSales23;

# 5. With a CTE that calculates sales by product category, find categories where total sales in 2023 are at least 20% higher than in 2022 -> Window Functions
WITH Sales22 AS (
	SELECT p.ProductID, p.ProductName, p.ProductCategory, SUM(od.LineTotal) AS TotalSales22, ROW_NUMBER() OVER(PARTITION BY p.ProductCategory)
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2022
	GROUP BY ProductID, ProductName, ProductCategory
),
Sales23 AS (
	SELECT p.ProductID, p.ProductName, p.ProductCategory, SUM(od.LineTotal) AS TotalSales23, ROW_NUMBER() OVER(PARTITION BY p.ProductCategory)
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2023
	GROUP BY ProductID, ProductName, ProductCategory
)
SELECT DISTINCT s22.ProductCategory
FROM Sales22 AS s22 JOIN Sales23 AS s23
	ON s22.ProductID = s23.ProductID
WHERE s23.TotalSales23 > (0.2 * s22.TotalSales22);

# 6. Get total orders per customer, and filter customers who placed at least 10 orders -> CTE, AGG, GROUP BY, HAVING, JOINS
SELECT c.CustomerName, COUNT(oi.OrderID) AS OrderCount
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
GROUP BY CustomerName
HAVING COUNT(oi.OrderID) >= 10;

# 7. calculate total sales per product, then classify them into "High", "Medium", "Low" sales groups using CASE WHEN.
WITH Sales AS (
	SELECT p.ProductName, ROUND(SUM(od.LineTotal)) AS TotalSales
    FROM orderdetails AS od JOIN product AS p
		ON od.ProductID = p.ProductID
	GROUP BY ProductName
)
SELECT ProductName, TotalSales,
       CASE
		   WHEN TotalSales > 80000 THEN 'High'
           WHEN TotalSales > 50000 THEN 'Medium'
           ELSE 'Others'
		END AS ProdStatus
FROM Sales;

# 8. Build a CTE for each customer’s total spending in 2023, then categorize them as "VIP" (≥ ₹50,000), 
# "Regular" (₹20,000–₹49,999), or "Occasional" (< ₹20,000).
WITH Spending AS (
	SELECT c.CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSpending
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY CustomerName
)
SELECT CustomerName, TotalSpending,
       CASE 
		   WHEN TotalSpending >= 50000 THEN 'Vip'
           WHEN TotalSpending > 20000 AND TotalSpending < 50000 THEN 'Regular'
           ELSE 'Occasional'
		END AS SpendingTag
FROM Spending;

# 9. Use a CTE to compare 2022 vs 2023 sales per product and classify as "Growing", "Declining", or "Stable".
WITH Sales22 AS (
	SELECT p.ProductID, p.ProductName, ROUND(SUM(od.LineTotal)) AS ProductSales22
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p 
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2022
    GROUP BY ProductID, ProductName
),
Sales23 AS (
	SELECT p.ProductID, p.ProductName, ROUND(SUM(od.LineTotal)) AS ProductSales23
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p 
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY ProductID, ProductName
)
SELECT s22.ProductID, s22.ProductName, s22.ProductSales22, s23.ProductSales23,
       CASE
		   WHEN s22.ProductSales22 < s23.ProductSales23 THEN 'Growing'
           WHEN s22.ProductSales22 > s23.ProductSales23 THEN 'Declining'
           ELSE 'Stable'
		END AS GrowthStatus
FROM Sales22 AS s22 JOIN Sales23 AS s23
	ON s22.ProductID = s23.ProductID
ORDER BY ProductID;

# 10. Use a CTE with ROW_NUMBER() OVER (PARTITION BY ProductCategory ORDER BY SUM(LineTotal) DESC) to get the top-selling product in each category in 2023.
WITH Top AS (
	SELECT p.ProductName, p.ProductCategory, ROUND(SUM(od.LineTotal)) AS TotalSales, ROW_NUMBER() OVER(PARTITION BY p.ProductCategory ORDER BY SUM(od.LineTotal) DESC) AS rn
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	GROUP BY ProductName, ProductCategory
)
SELECT ProductName, ProductCategory, TotalSales, rn
FROM Top
WHERE rn = 1;

# 11. calculate each customer’s rank by total spending in 2023.
WITH Ranking AS (
	SELECT c.CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSpending, RANK() OVER(ORDER BY SUM(oi.TotalAmount) DESC) AS rn
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2023
	GROUP BY CustomerName
)
SELECT CustomerName, TotalSpending, rn
FROM Ranking;
       
# 12. find the first product sold to each customer
WITH ProductDate AS (
	SELECT c.CustomerID, c.CustomerName, p.ProductName, oi.OrderDate AS FirstProductDate, RANK() OVER(PARTITION BY c.CustomerID ORDER BY oi.OrderDate ASC, p.ProductID ASC) AS rn
	FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
)
SELECT CustomerID, CustomerName, ProductName, FirstProductDate
FROM ProductDate
WHERE rn = 1;

# 13. Use a CTE to get customers grouped by city, then perform a self join to find pairs of customers in the same city -> STRING 
WITH Pairs AS (
	SELECT CustomerID, CustomerName,
           SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) AS City
	FROM customer
)
SELECT  p1.CustomerName, p2.CustomerName, p1.City
FROM Pairs AS p1 JOIN Pairs AS p2
	ON p1.City = p2.City AND p1.CustomerID < p2.CustomerID;
    
SELECT * FROM customer;

# 14. Create a CTE of products grouped by price, then find other products with the same price but different names -> SELF JOIN 
WITH Pricee AS (
	SELECT ProductID, ProductName, Price
    FROM product
)
SELECT p1.ProductName, p2.ProductName
FROM Pricee AS p1 JOIN Pricee AS p2
	ON p1.Price = p2.Price AND p1.ProductID < p2.ProductID;
    

# 15. Build a CTE for customers with the same registration date and list all such pairs -> SELF JOIN 
WITH Registration AS (
	SELECT c.CustomerID, c.CustomerName, oi.OrderDate
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
)
SELECT r1.CustomerName, r2.CustomerName, r1.OrderDate
FROM Registration AS r1 JOIN Registration AS r2 
	ON r1.OrderDate = r2.OrderDate AND r1.CustomerID < r2.CustomerID;

WITH CD AS (
	SELECT CustomerID, CustomerName, CreatedDate
    FROM customer
)
SELECT c1.CustomerName, c2.CustomerName, c1.CreatedDate
FROM CD AS c1 JOIN CD AS c2
	ON c1.CreatedDate = c2.CreatedDate AND c1.CustomerID < c2.CustomerID;


