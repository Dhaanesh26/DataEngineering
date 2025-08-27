# Order Trends & Patterns
# 1. Show the total number of orders per month in 2023.
SELECT MONTH(oi.OrderDate) AS OrderMonth, COUNT(oi.OrderID) AS TotalOrders
FROM orderinfo AS oi
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY OrderMonth
ORDER BY OrderMonth ASC;

#. 2. Find the month in each year with the highest total TotalAmount.
WITH Highest AS (
	SELECT ROUND(SUM(od.LineTotal)) AS TotalAmount, YEAR(oi.OrderDate) AS OrderYear, MONTH(oi.OrderDate) AS OrderMonth, RANK() OVER(PARTITION BY YEAR(oi.OrderDate) ORDER BY SUM(od.LineTotal) DESC) AS rn
	FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	GROUP BY OrderYear, OrderMonth
)
SELECT TotalAmount, OrderYear, OrderMonth, rn
FROM Highest
WHERE rn = 1;

SELECT * FROM orderinfo;
# 3. Identify orders that were shipped more than 7 days after the order date.
SELECT OrderID, OrderStatus, ShippingDate, OrderDate
FROM orderinfo
WHERE OrderStatus = 'Shipped' AND DATEDIFF(ShippingDate, OrderDate) > 2;

# 4. List orders with a NULL or empty ShippingAddress.
SELECT OrderID
FROM orderinfo 
WHERE ShippingAddress IS NULL OR ShippingAddress = '';

# 5. Show the average TotalAmount per PaymentMethod.
SELECT ROUND(AVG(TotalAmount)) AS AverageTotalAmount, PaymentMethod
FROM orderinfo 
GROUP BY PaymentMethod;

# 6. Find the most frequently purchased product for each customer.
WITH MostFrequent AS (
	SELECT DISTINCT c.CustomerID, c.CustomerName, p.ProductID, p.ProductName, COUNT(*) AS ProductCount, RANK() OVER(PARTITION BY c.CustomerID ORDER BY COUNT(*) DESC) rn
	FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	GROUP BY CustomerID, CustomerName, ProductID, ProductName
)
SELECT CustomerID, CustomerName, ProductID, ProductName, ProductCount
FROM MostFrequent
WHERE rn = 1;

# 7. Show orders where the OrderStatus is "Cancelled" and TotalAmount > ₹5000.
SELECT oi.OrderID, oi.OrderStatus, SUM(od.LineTotal) AS TotalAmount
FROM orderinfo AS oi JOIN orderdetails od
	ON oi.OrderID = od.OrderID
WHERE oi.OrderStatus = 'Cancelled' AND TotalAmount > 2000
GROUP BY OrderID, OrderStatus;

# 8. Identify orders with a Discount greater than 20%.
SELECT oi.OrderID, c.CustomerName, p.ProductName, od.Quantity, od.UnitPrice, od.Discount
FROM orderinfo oi
JOIN orderdetails od 
    ON oi.OrderID = od.OrderID
JOIN product p 
    ON od.ProductID = p.ProductID
JOIN customer c
    ON oi.CustomerID = c.CustomerID
WHERE od.Discount > 0.20;


# 9. Show the percentage of orders paid with "Credit Card" in 2023.
WITH PM AS (
	SELECT COUNT(PaymentMethod) AS CreditCardCount
    FROM orderinfo
    WHERE PaymentMethod = 'Credit Card'
),
TotalPM AS (
	SELECT COUNT(PaymentMethod) AS TotalCount
    FROM orderinfo
)
SELECT ((p.CreditCardCount/t.TotalCount) * 100) AS CreditCardPercentage
FROM PM AS p JOIN TotalPM AS t






