# Product & Sales Performance
# 1. Show each product’s total sales amount in 2023 along with its category.
SELECT p.ProductName, p.ProductCategory, ROUND(SUM(od.LineTotal)) AS TotalSales
FROM orderinfo AS oi JOIN orderdetails AS od 
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY ProductName, ProductCategory;

# 2. Find the top-selling product in each ProductCategory in 2023.
WITH TopSelling AS (
	SELECT p.ProductName, p.ProductCategory, ROUND(SUM(od.LineTotal)) AS TotalAmount, RANK() OVER(PARTITION BY ProductCategory ORDER BY SUM(od.LineTotal) DESC) AS rn
    FROM orderinfo AS oi JOIN orderdetails AS od 
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY ProductName, ProductCategory
)
SELECT ProductName, ProductCategory, TotalAmount
FROM TopSelling
WHERE rn = 1;

# 3. Identify products that were never sold in 2023.
SELECT p.ProductID, p.ProductName, oi.OrderID
FROM orderinfo AS oi JOIN orderdetails AS od 
		ON oi.OrderID = od.OrderID
	RIGHT JOIN product AS p
		ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2023 AND od.OrderID IS NULL;

# 4. Show products that were sold in both 2022 and 2023.
SELECT DISTINCT p.ProductName
FROM orderinfo AS oi JOIN orderdetails AS od 
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2022 OR YEAR(oi.OrderDate) = 2023;

# 5. Find products sold in 2022 but not in 2023.
SELECT DISTINCT p.ProductName
FROM orderinfo AS oi JOIN orderdetails AS od 
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2022 AND YEAR(oi.OrderDate) NOT IN (2023);

# 6. Display the first product purchased by each customer.
WITH First AS (
	SELECT c.CustomerName, p.ProductName AS FirstProduct, MIN(oi.OrderDate) AS FirstOrderDate, RANK() OVER(PARTITION BY p.ProductName ORDER BY MIN(oi.OrderDate)) AS rn
	FROM customer AS c JOIN orderinfo AS oi 
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od 
		ON oi.OrderID = od.OrderID
	JOIN product AS p
			ON p.ProductID = od.ProductID
	GROUP BY CustomerName, ProductName
)
SELECT CustomerName, FirstProduct, FirstOrderDate
FROM First
WHERE rn = 1;

# 7. List products whose price is the same as another product’s price but with a different name.
SELECT p1.ProductID, p1.ProductName, p2.ProductID, p2.ProductName, p1.Price
FROM product AS p1 JOIN product AS p2
	ON p1.Price <> p2.Price AND p1.ProductID < p2.ProductID AND p1.ProductName <> p2.ProductName;
    
# 8. Find products whose total sales in 2023 exceeded the average total sales of all products in 2023
WITH Total23 AS (
	SELECT p.ProductID, p.ProductName, SUM(od.LineTotal) AS TotalAmount
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
    WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY ProductID, ProductName
),
Average23 AS (
	SELECT p.ProductID, p.ProductName, AVG(od.LineTotal) AS AverageAmount
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
    WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY ProductID, ProductName
)
SELECT t.ProductID, t.ProductName
FROM Total23 AS t JOIN Average23 AS a
	ON t.ProductID = a.ProductID
WHERE t.TotalAmount > AverageAmount;

SELECT * FROM orderdetails;

# 9. Show products where at least one order in 2023 had Quantity ≥ 10
SELECT p.ProductName, COUNT(od.Quantity) AS ProductQty
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY ProductName
HAVING COUNT(od.Quantity) >= 1;





