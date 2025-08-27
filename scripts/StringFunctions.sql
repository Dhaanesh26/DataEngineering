# String functions

USE DNA;
# Beginner Level

# 1. Retrieve all customers whose names start with the letter 'A'
SELECT CustomerName
FROM customer
WHERE CustomerName LIKE 'A%';

# 2. Display product names in uppercase and lowercase.
SELECT UPPER(ProductName) AS Upper_Case_PN, LOWER(ProductName) AS Lower_Case_PN
FROM product;

# 3. Show the first 3 letters of each customer’s name.
SELECT SUBSTRING(CustomerName, 1, 3) AS First_3
FROM customer;

# 4. Find customers whose names end with 'son'.
SELECT CustomerName
FROM customer
WHERE CustomerName LIKE '%son';

# 5. Concatenate CustomerName and CustomerID into a single string like: "Alex Davis (C101)".
SELECT CONCAT(CustomerName, ',', '(', CustomerID, ')') AS SingleColumn
FROM customer;

# Intermediate Level

# 1. Extract the domain name from customer emails (everything after @).
SELECT SUBSTRING(Email, INSTR(Email, '@') + 1) AS DomainName
FROM customer;

# 2. List products whose names contain the word "Pro" (case-insensitive).
SELECT ProductName
FROM product
WHERE ProductName LIKE '%Pro%';

# 3. Find the length of each product name and order by longest first.
SELECT ProductName, LENGTH(ProductName) AS Len_Product
FROM product
ORDER BY Len_Product DESC;

# 4. Replace spaces in ProductName with hyphens -.
SELECT REGEXP_REPLACE(ProductName, ' ', '-') AS NoSpace
FROM product;

# 5. Return all customers where the second character of their name is 'e'.
SELECT CustomerName 
FROM customer
WHERE CustomerName LIKE '_e%';

# Advanced Level

# 1. Show orders where the product name contains exactly two words.
SELECT ProductName
FROM product
WHERE ProductName LIKE '%_% %_%';

# 2. Find customers who have a palindrome name (e.g., "Anna").
SELECT CustomerName, SUBSTRING(CustomerName, 1), REVERSE(CustomerName)
FROM customer
WHERE SUBSTRING(CustomerName, 1) = REVERSE(CustomerName);

# 3. Split a FullName column into FirstName and LastName (using SUBSTRING_INDEX).
SELECT CustomerName, SUBSTRING_INDEX(CustomerName, ' ', 1) AS FirstName, SUBSTRING_INDEX(CustomerName, ' ', -1) AS LastName
FROM customer;

# 4. Count how many products contain the substring "phone" (case-insensitive).
SELECT ProductName, COUNT(ProductID) AS ProductCount
FROM product
WHERE ProductName LIKE 'phone'
GROUP BY ProductName;

# 5. Mask customer phone numbers so only the last 4 digits show (e.g., *******1234).
SELECT CONCAT(REPEAT('*', CHAR_LENGTH(PhoneNumber) - 4), RIGHT(PhoneNumber - 4))
FROM customer;

# String Functions
# 1. Extract domain from email - SUBSTRING & INSTR
SELECT CustomerName, 
	   SUBSTRING(Email, INSTR(Email, '@')+1) AS DomainName
FROM customer;

# 2. Mask credit PhoneNumber - CONCAT & RIGHT
SELECT CustomerName,
	   CONCAT('xxxx-xxx-', RIGHT(PhoneNumber, 4)) AS MaskedPhoneNumber
FROM customer;

# 3. Standardize case - CustomerName with Capital in last name & Lower in first name - CONCAT, UPPER & LOWER
SELECT CONCAT(SUBSTRING_INDEX(UPPER(CustomerName), ' ', -1), ' ',
	   SUBSTRING_INDEX(LOWER(CustomerName), ' ', 1)) AS FLName
FROM customer;

# 4. Find customers by city name prefix - SUBSTRING_INDEX
WITH Find AS (
	SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) As City
    FROM customer
)
SELECT City
FROM Find
WHERE City LIKE '%Ma%';

# 5. Detect Duplicates
SELECT SUBSTRING(Email, INSTR(Email, '@')+1) AS DomainName, COUNT(*) AS CustomerCount
FROM customer
GROUP BY DomainName
HAVING COUNT(*) > 1;

# 6. Reverse
SELECT CustomerName, REVERSE(CustomerName) AS ReverseName
FROM customer;

# 1. Find all customers whose PhoneNumber contains '555' and join with their order history.
SELECT CustomerName, CONCAT(PhoneNumber, ' ', PrimaryAddress) AS Combined
FROM customer
WHERE PhoneNumber LIKE '%36%';

# String 
# 1. Extract First Name and Last Name from CustomerName
SELECT SUBSTRING_INDEX(CustomerName, ' ', 1) AS FirstName, 
       SUBSTRING_INDEX(CustomerName, ' ', -1) AS LastName
FROM customer;

# 2. Standardize Phone Numbers
SELECT CustomerName, PhoneNumber,
       CONCAT('+1', RIGHT(REGEXP_REPLACE(SUBSTRING_INDEX(PhoneNumber, 'x', 1), '[^0-9]', ''), 10)) AS StandardPhoneNumber
FROM customer;

# 3. Show only the last 4 digits of PhoneNumber and hide part of email upto domain name
SELECT CONCAT('xxxx - xxx - ', RIGHT(PhoneNumber, 4)) AS EncrytedPhoneNumber,
       CONCAT(LEFT(Email, 3), 'xxx', SUBSTRING(Email, INSTR(Email, '@') + 1)) AS HiddenEmail
FROM customer;

# Find City
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) As City
FROM customer
WHERE SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) LIKE '%Ma%';

# Domain Classification
SELECT CustomerName, Email,
       CASE
		   WHEN Email LIKE '%yahoo.com%' OR Email LIKE '%gmail.com%' OR Email LIKE '%hotmail.com%' THEN 'Personal'
           ELSE 'Business'
		END AS DomainClass
FROM customer;

# Split Address
SELECT PrimaryAddress, SUBSTRING_INDEX(PrimaryAddress, ',', 1) AS Street,
       SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) AS City,
       SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 3), ',', -1), ' ', -1) AS Zip
FROM customer;

# Working with Address 
SELECT PrimaryAddress,
       SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 1), ' ', 1) AS Code,
       SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) AS City,
       SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ' ', -1), ',', 1) AS Aftercode,
       SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ' ', -1) AS Afte
FROM customer;






