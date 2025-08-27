# Customer & Order Analysis
# 1. Find the top 5 customers by total spending in 2023 -> AGG, GROUP BY, JOINS
SELECT c.CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSpent, YEAR(oi.OrderDate) AS OrderYear
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od
	ON od.OrderID = od.OrderID
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY CustomerName, OrderYear
ORDER BY TotalSpent DESC
LIMIT 5;

SELECT * FROM orderinfo;

# 2. Show the total number of orders and total amount spent by each customer in 2022 -> AGG, GROUP BY, JOINS
SELECT c.CustomerName, COUNT(oi.OrderID) AS OrderCount, ROUND(SUM(od.LineTotal)) AS TotalAmount, YEAR(oi.OrderDate) AS OrderYear
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od
	ON od.OrderID = oi.OrderID
WHERE YEAR(oi.OrderDate) = 2022
GROUP BY CustomerName, OrderYear;

# 3. Identify customers whose total spending in 2023 is higher than in 2022 -> CTE's, AGG, GROUP BY, JOINS
WITH TotalSpend22 AS (
	SELECT c.CustomerID, c.CustomerName, ROUND(SUM(od.LineTotal)) AS TotalSpending2022
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	WHERE YEAR(oi.OrderDate) = 2022
    GROUP BY CustomerID, CustomerName
),
TotalSpend23 AS (
	SELECT c.CustomerID, c.CustomerName, ROUND(SUM(od.LineTotal)) AS TotalSpending2023
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY CustomerID, CustomerName
)
SELECT T22.CustomerID, T22.CustomerName, T22.TotalSpending2022, T23.TotalSpending2023,
	   CASE 
		  WHEN T22.TotalSpending2022 < T23.TotalSpending2023 THEN '2023 Greater'
          ELSE '2022 Greater'
		END AS SpentStatus
FROM TotalSpend22 AS T22 JOIN TotalSpend23 AS T23
	ON T22.CustomerID = T23.CustomerID
WHERE  T22.TotalSpending2022 < T23.TotalSpending2023;

# 4. List customers who have never placed an order -> LEFT JOIN
SELECT c.CustomerName
FROM customer AS c LEFT JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
WHERE oi.OrderID IS NULL;

# 5. Find customers whose first order date was in 2023 -> AGG, GROUP BY, JOINS
SELECT c.CustomerName, MIN(oi.OrderDate) AS OrderYear 
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
GROUP BY CustomerName
HAVING YEAR(MIN(oi.OrderDate)) = 2023;

# 6. Show customers who have placed more than 10 orders in total -> AGG, GROUP BY, JOINS
SELECT c.CustomerName, COUNT(oi.OrderID) AS OrderCount 
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
GROUP BY CustomerName
HAVING COUNT(oi.OrderID) > 10;

# 7. List customers who have the same PrimaryAddress -> STRING Functions, SELF JOIN
SELECT c1.CustomerID, c1.CustomerName, c2.CustomerID, c2.CustomerName,
	   SUBSTRING_INDEX(SUBSTRING_INDEX(c1.PrimaryAddress, ',', 2), ',', -1) AS City
FROM customer AS c1 JOIN customer AS c2
	ON SUBSTRING_INDEX(SUBSTRING_INDEX(c1.PrimaryAddress, ',', 2), ',', -1) = SUBSTRING_INDEX(SUBSTRING_INDEX(c2.PrimaryAddress, ',', 2), ',', -1)
    AND c1.CustomerID < c2.CustomerID;

# 8. Find customers with duplicate Email domains -> STRING Functions, SELF JOIN
WITH DN AS (
	SELECT CustomerID, CustomerName,
		   SUBSTRING(Email, INSTR(Email, '@') + 1) AS DomainName
	FROM customer
)
SELECT d1.CustomerID, d1.CustomerName, d1.DomainName, d2.CustomerID, d2.CustomerID
FROM DN AS d1 JOIN DN AS d2 
	ON d1.DomainName = d2.DomainName
    AND d1.CustomerID < d2.CustomerID;

# 9. Display all customers created in the same month as the customer named “John Doe” -> SELF JOIN
SELECT c1.CustomerID, c1.CustomerName, MONTH(c1.CreatedDate) AS CreatedMonth, c2.CustomerID, c2.CustomerName
FROM customer AS c1 JOIN customer AS c2
	ON MONTH(c1.CreatedDate) = MONTH(c2.CreatedDate)
	AND c1.CustomerID < c2.CustomerID
WHERE MONTH(c1.CreatedDate) = 07;

# 10. Find customers whose phone number contains 555 -> LIKE Operator
SELECT CustomerName, PhoneNumber
FROM customer
WHERE PhoneNumber LIKE '%555%';




    