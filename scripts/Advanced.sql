# Comparative / Advanced Patterns
# 1. Compare each customer’s average TotalAmount per order with the overall average order amount, and show only those above average.
WITH CustomerAvg AS (
	SELECT c.CustomerID, c.CustomerName, ROUND(AVG(oi.TotalAmount)) AS CustomerAvgAmount
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	GROUP BY CustomerID, CustomerName
),
OverallAverage AS (
	SELECT ROUND(AVG(oi.TotalAmount)) AS OverallAvgAmount
    FROM orderinfo AS oi
)
SELECT CustomerID, CustomerID, CustomerAvgAmount, OverallAvgAmount
FROM CustomerAvg AS ca CROSS JOIN OverallAverage AS oa
WHERE ca.CustomerAvgAmount > oa.OverallAvgAmount;

# 2. Rank customers by total spending within each year.
SELECT c.CustomerName, YEAR(oi.OrderDate) AS OrderYear, SUM(oi.TotalAmount) AS TotalSpending, RANK() OVER(PARTITION BY YEAR(oi.OrderDate) ORDER BY SUM(oi.TotalAmount) DESC) AS rn
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od 
	ON od.OrderID = oi.OrderID
GROUP BY CustomerName, OrderYear;

# 3. Find the earliest order date for each product.
SELECT p.ProductName, MIN(oi.OrderDate) AS EarliestOrderDate
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.productID = od.ProductID
GROUP BY ProductName;

# 4. Find the earliest order date for each customer.
SELECT c.CustomerName, MIN(oi.OrderDate) AS EarliestCustomerOrderDate
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
GROUP BY CustomerName;

# 5. Show the ProductCategory that generated the highest revenue in 2023.
SELECT p.ProductCategory, ROUND(SUM(od.LineTotal)) AS HighestRevenue
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY ProductCategory
ORDER BY HighestRevenue DESC
LIMIT 1;

# 6. Find the year-over-year sales growth percentage for each product.
WITH ProductSales AS (
	SELECT p.ProductID, p.ProductName, YEAR(oi.OrderDate) AS OrderYear, ROUND(SUM(od.LineTotal)) AS TotalSales
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	GROUP BY ProductID, ProductName, OrderYear
),
YoY AS (
	SELECT ProductID, ProductName, OrderYear, TotalSales,
    LAG(TotalSales) OVER(PARTITION BY ProductID ORDER BY TotalSales) AS PreviousYearSales
    FROM ProductSales
)
SELECT ProductID, ProductName, OrderYear, TotalSales, PreviousYearSales, 
	   ROUND((((TotalSales-PreviousYearSales)/PreviousYearSales) * 100),2) AS YoYPercentage
FROM YoY
WHERE PreviousYearSales IS NOT NULL
ORDER BY ProductName, OrderYear;

# 7. Identify customers who have ordered from all product categories at least once.
SELECT CustomerName, ProductCategory 
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID



