# REVISION 

# A. STRING FUNCTIONS - SUBSTRING, SUBSTRING_INDEX, INSTR, REGEXP_REPLACE, RIGHT, LEFT, CONCAT, LTRIM, RTRIM, UPPER, LOWER
# 1. List the first 4 letters of each CustomerName and also the last 3 letters of their Region.
WITH GetRegion AS (
	SELECT CustomerName,
		   CASE 
				WHEN PrimaryAddress LIKE '%WI%' OR PrimaryAddress LIKE '%GA%' THEN 'EAST'
				WHEN PrimaryAddress LIKE '%UT%' OR PrimaryAddress LIKE '%AA%' THEN 'WEST'
			END AS Region
	FROM customer
)
SELECT CustomerName, LEFT(CustomerName, 4) AS FirstFourLetters, RIGHT(Region, 3) AS LastThreeLetters
FROM GetRegion;

# 2. Extract the domain from each customer’s Email and return only those whose domain is 'gmail.com'.
WITH ExtractD AS (
	SELECT CustomerName, Email, SUBSTRING(Email, INSTR(Email, '@') + 1) AS DomainName
    FROM customer
)
SELECT CustomerName, Email, DomainName
FROM ExtractD
WHERE DomainName LIKE '%gmail.com%';

# 3. Display all customers whose PrimaryAddress contains 'Avenue'.
SELECT PrimaryAddress 
FROM customer
WHERE PrimaryAddress LIKE '%Avenue%';

# 4. Show CustomerName in uppercase, Email in lowercase, and combine them into one column formatted as: NAME - email.
WITH Combination AS (
	SELECT UPPER(CustomerName) AS CustomerName, LOWER(Email) AS Email
    FROM customer
)
SELECT CONCAT(CustomerName, ' - ', Email) AS CombinedCustomerInfo
FROM Combination;

# 5. Return CustomerID, Phone after removing all non-numeric characters. Show only those customers whose cleaned phone number has exactly 10 digits.
SELECT CustomerID,
       PhoneNumber,
       RIGHT(REGEXP_REPLACE(SUBSTRING_INDEX(PhoneNumber, 'x', 1), '[^0-9]', ''), 10) AS StandardPhoneNumber
FROM customer;

# 6. For each product, display the first 5 characters and last 2 characters of ProductName.
SELECT LEFT(ProductName, 5) AS FirstFive, RIGHT(ProductName, 2) AS LastTwo
FROM product;

# 7. Show CustomerName without leading or trailing spaces, and also count how many characters were trimmed compared to the original.
WITH Counting AS (
	SELECT LENGTH(CustomerName) AS LengthCN, TRIM(CustomerName) AS TrimmedCustomerName
    FROM customer
)
SELECT (LengthCN - LENGTH(TrimmedCustomerName)) AS Difference
FROM Counting;

# 8. Display the CustomerID, CustomerName, and only the part of Email before @.
SELECT CustomerID, CustomerName, SUBSTRING_INDEX(Email, '@', 1) AS BeforeAt
FROM customer;

# 9. Find customers whose CustomerName starts with the same first two letters as their Region.
WITH Reg AS (
	SELECT CustomerName,
		   CASE 
			   WHEN PrimaryAddress LIKE '%WI%' OR PrimaryAddress LIKE '%GA%' THEN 'EAST'
			   WHEN PrimaryAddress LIKE '%UT%' OR PrimaryAddress LIKE '%AA%' THEN 'WEST'
		   END AS Region
	FROM customer
)
SELECT CustomerName
FROM Reg
WHERE LEFT(CustomerName, 2) = LEFT(Region, 2);

# 10. Create a list where each row looks like: "CustomerName (Phone)" → but Phone must be cleaned (digits only) and Name should be UPPERCASE.
WITH Cleaned AS (
	SELECT UPPER(CustomerName) AS CustomerName,
           RIGHT(REGEXP_REPLACE(SUBSTRING_INDEX(PhoneNumber, 'x', 1), '[^0-9]', ''), 10) AS StandardPhoneNumber
	FROM customer
)
SELECT CONCAT(CustomerName, ' ', '(', StandardPhoneNumber, ')') AS CombinedInfo
FROM Cleaned;

# 11. Return all customers whose Email contains 'yahoo' using INSTR.
SELECT CustomerName, Email
FROM customer
WHERE Email LIKE '%yahoo%';

# 12. Show ProductName in lowercase but with the first 3 letters uppercase (hint: combine UPPER, LOWER, CONCAT, SUBSTRING).
SELECT CONCAT(UPPER(LEFT(ProductName, 3)), LOWER(RIGHT(ProductName, LENGTH(ProductName)-3))) AS NewProductName
FROM product;

# GROUP BY, HAVING, AGGREGATE FUNCTIONS, WINDOW FUNCTIONS, CTE, CASE STATEMENTS  START TIME -> 6:40
# 1. Find the top 5 customers by total spending in 2023
SELECT CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSpending
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
GROUP BY CustomerName
ORDER BY TotalSpending DESC
LIMIT 5;

# 2. Show each product’s number of orders in 2022 along with its name.
SELECT ProductName, COUNT(oi.OrderID) AS OrderCount
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE YEAR(oi.OrderDate) = 2022
GROUP BY ProductName;

# 3. Identify customers whose spending increased in 2023 compared to 2022.
WITH Spending22 AS (
	SELECT c.CustomerID, c.CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSpending22
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2022
	GROUP BY CustomerID, CustomerName
),
Spending23 AS (
	SELECT c.CustomerID, c.CustomerName, ROUND(SUM(oi.TotalAmount)) AS TotalSpending23
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2023
	GROUP BY CustomerID, CustomerName
)
SELECT s22.CustomerName, s22.TotalSpending22, s23.TotalSpending23,
	   CASE
			WHEN s22.TotalSpending22 < s23.TotalSpending23 THEN 'Spending Increased'
            ELSE 'Spending Decreased'
		END AS SpendingStatus
FROM Spending22 AS s22 JOIN Spending23 AS s23
	ON s22.CustomerID = s23.CustomerID;
    
# 4. List products in 2023 whose sales were higher than the average sales of all products in that year
# NOTE : When finding aggregations for whole column dont group by their individual columns
WITH TotalSales AS (
	SELECT p.ProductID, p.ProductName, ROUND(SUM(od.LineTotal)) AS TotalSales23
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY ProductID, ProductName
),
AverageSales AS (
	SELECT ROUND(AVG(TotalSales23)) AS AverageSales23
    FROM TotalSales
)
SELECT t.ProductName, t.TotalSales23, a.AverageSales23
FROM TotalSales AS t CROSS JOIN AverageSales AS a
WHERE  t.TotalSales23 >  a.AverageSales23
ORDER BY t.TotalSales23;

# 5. Find all products purchased by customers whose phone number contains “999”.
SELECT p.ProductName, GROUP_CONCAT(DISTINCT(c.CustomerName)) AS CustomerName
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od
	ON od.OrderID = oi.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE c.PhoneNumber LIKE '%9%'
GROUP BY ProductName;

# 6. List customers who placed orders in 2023 where the shipping date was later than the average shipping date gap for that year.
WITH OrdersPlaced AS (
	SELECT CustomerName, oi.OrderID, oi.OrderDate, oi.ShippingDate
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	WHERE YEAR(oi.OrderDate) = 2023
),
AverageDate AS (
	SELECT AVG(ShippingDate) AS AverageShippingDate
    FROM OrdersPlaced
)
SELECT op.CustomerName, op.OrderDate, ad.AverageShippingDate
FROM OrdersPlaced AS op JOIN AverageDate AS ad
WHERE ad.AverageShippingDate < op.OrderDate;

SELECT * FROM orderinfo;

# 7. List products that were purchased by customers who also purchased at least one product in the "Electronics" category.
WITH ElectronicsBuyers AS (
	SELECT c.CustomerID
	FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	WHERE p.ProductCategory = 'Electronics'
)
SELECT c.CustomerName, p.ProductName
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
JOIN orderdetails AS od
	ON od.OrderID = oi.OrderID
JOIN product AS p
	ON p.ProductID = od.ProductID
WHERE c.CustomerID IN (SELECT CustomerID FROM ElectronicsBuyers)
ORDER BY c.CustomerName, p.ProductName;

# 1. Find each product category’s total sales amount, and only show categories where the total sales are above ₹1,00,000
SELECT p.ProductCategory, ROUND(SUM(od.LineTotal)) AS TotalSales 
FROM orderdetails AS od JOIN product AS p
	ON od.ProductID = p.ProductID
GROUP BY ProductCategory
HAVING TotalSales > 100000;

# 2. List each customer and the total number of orders they placed in 2023, but only include those who placed more than 5 orders.
SELECT c.CustomerName, COUNT(oi.OrderID) AS TotalOrders
FROM customer AS c JOIN orderinfo AS oi
	ON c.CustomerID = oi.CustomerID
WHERE YEAR(oi.OrderDate) = 2023
GROUP BY CustomerName
HAVING TotalOrders > 5;

# 3. Show the total number of orders per month in 2022, but only include months where more than 200 orders were placed.
SELECT COUNT(oi.OrderID) AS TotalOrders, MONTH(oi.OrderDate) AS OrderMonth
FROM orderinfo AS oi JOIN orderdetails AS od
	ON oi.OrderID = od.OrderID
 WHERE YEAR(oi.OrderDate) = 2022
 GROUP BY OrderMonth
 HAVING TotalOrders > 200;

# 4. For each product, show the product name, total sales, and a label: "High" if sales > ₹50,000, "Medium" if between ₹20,000 and ₹50,000, else "Low"
WITH Sales AS (
	SELECT p.ProductName, ROUND(SUM(od.LineTotal)) AS TotalSales
	FROM orderdetails AS od JOIN product AS p
		ON od.ProductID = p.ProductID
	GROUP BY ProductName
)
SELECT ProductName, TotalSales,
	   CASE
           WHEN TotalSales > 50000 THEN 'High'
		   WHEN TotalSales > 20000 AND TotalSales < 50000 THEN 'Medium'
           ELSE 'Low'
		END AS PriceStatus
FROM Sales;

# 5. For each customer, show "New" if their first order date is in 2023, "Returning" otherwise
WITH FD AS (
	SELECT c.CustomerName, MIN(oi.OrderDate) AS FirstOrderDate
    FROM customer AS c JOIN orderinfo AS oi
		ON c.CustomerID = oi.CustomerID
	JOIN orderdetails AS od
		ON od.OrderID = oi.OrderID
	WHERE YEAR(oi.OrderDate) = 2023
	GROUP BY CustomerName
)
SELECT CustomerName, 
       CASE
           WHEN FirstOrderDate BETWEEN 01-01-2023 AND 01-01-2024 THEN 'New'
           ELSE 'Returning'
		END AS DateStat
FROM FD;

# 6. For each product category, calculate average sales and classify as "Growing" if average sales in 2023 > average sales in 2022.
WITH AverageSales22 AS (
    SELECT p.ProductCategory, AVG(od.LineTotal) AS AvgSales22
    FROM orderinfo oi
    JOIN orderdetails od ON oi.OrderID = od.OrderID
    JOIN product p ON p.ProductID = od.ProductID
    WHERE YEAR(oi.OrderDate) = 2022
    GROUP BY p.ProductCategory
),
AverageSales23 AS (
    SELECT p.ProductCategory, AVG(od.LineTotal) AS AvgSales23
    FROM orderinfo oi
    JOIN orderdetails od ON oi.OrderID = od.OrderID
    JOIN product p ON p.ProductID = od.ProductID
    WHERE YEAR(oi.OrderDate) = 2023
    GROUP BY p.ProductCategory
)
SELECT 
    a22.ProductCategory,
    a22.AvgSales22,
    a23.AvgSales23,
    CASE 
        WHEN a23.AvgSales23 > a22.AvgSales22 THEN 'Growing'
        ELSE 'Not Growing'
    END AS CategoryStatus
FROM AverageSales22 a22
JOIN AverageSales23 a23 
    ON a22.ProductCategory = a23.ProductCategory;

# Using a CTE, find the top 3 products by sales for each year.
WITH Top AS (
	SELECT p.ProductID, p.ProductName, ROUND(SUM(od.LineTotal)) AS TotalSales, YEAR(oi.OrderDate) AS OrderYear, RANK() OVER(PARTITION BY YEAR(oi.OrderDate) ORDER BY SUM(od.LineTotal) DESC, YEAR(oi.OrderDate) DESC) AS rn
    FROM orderinfo AS oi JOIN orderdetails AS od
		ON oi.OrderID = od.OrderID
	JOIN product AS p
		ON p.ProductID = od.ProductID
	GROUP BY ProductID, ProductName, OrderYear
)
SELECT ProductID, ProductName, TotalSales, OrderYear
FROM Top
WHERE rn <= 3;






    