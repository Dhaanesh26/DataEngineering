# SQL SAMPLE QUESTION
# 1. List each customer's CustomerName and total orders in 2022 where OrderStatus is NOT 'Cancelled'. 
#    Show only those with more than 2 such orders. Sort by total orders desc.
SELECT c.CustomerName, COUNT(oi.OrderID) AS TotalOrders
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
WHERE YEAR(oi.OrderDate) = 2022 AND oi.OrderStatus <> 'Cancelled'
GROUP BY CustomerName
HAVING COUNT(oi.OrderID) > 2
ORDER BY TotalOrders DESC;

SELECT * FROM orderinfo;

# 2. Return CustomerID, CustomerName, Region (based on PrimaryAddress containing 'WI'/'GA' → 'East', 'UT'/'AA' → 'West', else 'Other'),
#    and also only display phone number for those customers who only have 10 digit phone numbers after removing '(', ')', '-', 'x', . (dot),  and spaces.
SELECT CustomerID, CustomerName,
	   CASE 
		   WHEN PrimaryAddress LIKE '%WI%' OR PrimaryAddress LIKE '%GA%' THEN 'EAST'
           WHEN PrimaryAddress LIKE '%UT%' OR PrimaryAddress LIKE '%AA%' THEN 'WEST'
           ELSE 'OTHERS'
		END AS Region,
        CONCAT('+1', RIGHT(REGEXP_REPLACE(SUBSTRING_INDEX(PhoneNumber, 'x', 1), '[^0-9]', ''), 10)) AS StandardPhoneNumber
FROM customer;

# 3. Using ROW_NUMBER(), return each customer's latest order in 2022 (by OrderDate). If ties, pick highest TotalAmount.
WITH D AS (
	SELECT c.CustomerID, c.CustomerName, oi.OrderDate, oi.TotalAmount, ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY oi.OrderDate DESC, oi.TotalAmount DESC) AS rn
	FROM customer AS c JOIN orderinfo AS oi 
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od 
		ON od.OrderID = oi.OrderID
)
SELECT CustomerID, CustomerName, OrderDate, rn
FROM D
WHERE rn = 1;

# 4. Top 3 products by sales (sum LineTotal) in each ProductCategory for 2022
WITH Top AS (
	SELECT p.ProductName, p.ProductCategory, ROUND(SUM(od.LineTotal)) AS TotalSales, RANK() OVER(PARTITION BY p.ProductCategory ORDER BY SUM(od.LineTotal) DESC) AS rn
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2022
    GROUP BY ProductName, ProductCategory
)
SELECT ProductName, ProductCategory, TotalSales, rn
FROM Top
WHERE rn <= 3;
		
# 5. All ProductID, ProductName that were purchased by Wholesale customers OR with Price > 400 (include even if never purchased).
SELECT p.ProductID, p.ProductName
FROM product AS p LEFT JOIN orderdetails AS od
	ON p.ProductID = od.ProductID
WHERE Price > 400 AND od.OrderID IS NULL;

# 6. Customers who purchased at least one product in 'Beauty' AND at least one in 'Toys'. Return CustomerID, CustomerName.
SELECT c.CustomerID, c.CustomerName, p.ProductCategory, COUNT(oi.OrderID) AS OrderCount
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od
	ON od.OrderID = oi.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE ProductCategory = 'Beauty' OR ProductCategory = 'Toys'
GROUP BY CustomerID, CustomerName, ProductCategory
HAVING COUNT(oi.OrderID) > 1;

# 7. Active products (IsActive) that have never been ordered.
SELECT p.ProductName, p.IsActive
FROM product AS p LEFT JOIN Orderdetails AS od
	ON p.ProductID = od.ProductID
WHERE od.OrderID IS NULL;

# 8.  For each OrderID, show OrderDate, CustomerName, and total items (sum Quantity).
SELECT oi.OrderID, oi.OrderDate, c.CustomerName, SUM(od.Quantity) AS TotalItems
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od
	ON od.OrderID = oi.OrderID
GROUP BY OrderID, OrderDate, CustomerName;

# 9. Customers whose Email domain is 'yahoo.com'. Return CustomerID, CustomerName, Email
WITH DN AS (
	SELECT CustomerID, CustomerName, Email,
		   SUBSTRING(Email, INSTR(Email, '@')+1) AS DomainName
	FROM customer
)
SELECT CustomerID, CustomerName, Email, DomainName
FROM DN
WHERE DomainName LIKE '%yahoo.com%';

# 10. Total sales amount per ProductCategory for orders placed in October 2022.
SELECT p.ProductCategory, ROUND(SUM(od.LineTotal)) AS TotalSales, ROW_NUMBER() OVER(PARTITION BY ProductCategory ORDER BY SUM(od.LineTotal) DESC)
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2022 AND MONTH(oi.OrderDate) = 10
GROUP BY ProductCategory;

# 11. For each CustomerName, classify as 'VIP' if total purchases (sum LineTotal) > 5000 in 2022 else 'Regular'.
WITH Total AS (
	SELECT CustomerName, ROUND(SUM(od.LineTotal)) AS TotalAmount
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	WHERE YEAR(oi.OrderDate) = 2022
	GROUP BY CustomerName
)
SELECT CustomerName, TotalAmount, 
       CASE 	
			WHEN TotalAmount > 5000 THEN 'VIP'
            ELSE 'Regular'
		END AS Status
FROM Total;

# 12. Fetch the Most expensive product per ProductCategory (price-based).
WITH Expensive AS (
	SELECT ProductName, ProductCategory, Price, RANK() OVER(PARTITION BY ProductCategory ORDER BY Price DESC) AS rn
    FROM product
)
SELECT ProductName, ProductCategory, Price
FROM Expensive
WHERE rn = 1;

    
    



    


