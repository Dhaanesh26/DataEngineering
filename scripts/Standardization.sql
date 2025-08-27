USE DNA;

SELECT * FROM customer;
    
# Data Standardization - String Functions

# 1. TRIM() - Removes leading or trailing spaces
SELECT TRIM(CustomerName) AS Lefy  FROM customer;

# 2. LTRIM() - Removes spaces from beginning of string
SELECT LTRIM(CustomerName) FROM customer;

# 3. RTRIM() - Removes spaces from the end of string
SELECT RTRIM(CustomerName) FROM customer;

# 4. UPPER AND LOWER - Converts to upper and lower case
SELECT UPPER(CustomerName) AS Capitalized, LOWER(CustomerName) AS Small FROM customer;

# 5. LENGTH() - Finds lenght of string
SELECT LENGTH(CustomerName) AS No_of_characters FROM customer; 

# 6. CHAR_LENGTH - No of characters in byte style
SELECT CHAR_LENGTH(CustomerName) FROM customer;

# 7. SUBSTRING("string", "position to start", "no of characters to extract") - Extract a part of string 
SELECT CustomerName, SUBSTRING(CustomerName, 2, 4) AS Extracted_String FROM customer;

# 8. INSTR() - Finds a position of a character
SELECT INSTR('dhaanesh.suresh@gmail.com', '@');

# 9. CONCAT() - Combines two strings 
SELECT CONCAT("Dhaanesh", "Suresh");

# 10. REPLACE() - Replaces any character with other character
SELECT REPLACE("123-456", "-", "");

# REGEXP_REPLACE() - Removes unwanted patterns
SELECT PhoneNumber, REGEXP_REPLACE(PhoneNumber, '[^0-9]', "") FROM customer;

SELECT * FROM customer;

# Exercise 

# Q1. Remove extra spaces & fix casing in names 
SELECT TRIM(UPPER(CustomerName)) AS Standard_Name FROM customer;

# Q2. Standardize phone number formats (E.164 or local standard)
SELECT PhoneNumber, CONCAT('+1', RIGHT(REGEXP_REPLACE(SUBSTRING_INDEX(PhoneNumber, 'x', 1), '[^0-9]', ''), 10)) AS Standard_PhoneNumber
FROM customer;

# Q3. Remove unwanted non-numeric characters from phone number
SELECT PhoneNumber, REGEXP_REPLACE(PhoneNumber, '[^0-9]',"") AS Cleaned_Number
FROM customer;

# Q4. Check if an Email has @ or not
SELECT Email, 
	CASE
		WHEN INSTR(Email, '@') > 0 THEN 'Valid'
        ELSE 'Invalid'
	END AS email_status
FROM customer;

# Q5. Get the domain name of the email
SELECT Email,
	CASE 
		WHEN INSTR(Email, '@') > 0 THEN 'Valid'
        ELSE 'Invalid'
	END AS email_status,
    SUBSTRING(Email, INSTR(Email, '@') + 1) AS domain_name
FROM customer;


SELECT SUBSTRING(Email, INSTR(Email, '@') + 1) AS domain_name FROM customer;

# Removes unwanted character from phone number
SELECT PhoneNumber, REGEXP_REPLACE(PhoneNumber, '[^0-9]', '') AS Clean_PhoneNumber FROM customer;

# Phone Number in standardised format
SELECT PhoneNumber, 
	CONCAT('+1', RIGHT(REGEXP_REPLACE(SUBSTRING_INDEX(PhoneNumber, 'x', 1), '[^0-9]', ''), 10)) AS Clean_PhoneNumber
FROM customer;

# Address

SELECT 
    CustomerID,
    SUBSTRING_INDEX(PrimaryAddress, ',', 1) AS street,
    SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 2), ',', -1) AS city,
    SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 3), ',', -1) AS state,
    SUBSTRING_INDEX(SUBSTRING_INDEX(PrimaryAddress, ',', 4), ',', -1) AS postal_code,
    SUBSTRING_INDEX(PrimaryAddress, ',', -1) AS country
FROM customer;

# Convert string to data
SELECT STR_TO_DATE(CreatedDate, '%Y,%m,%d') FROM customer;

# Standardize catgorical data 
SELECT isActive, 
	CASE
		WHEN UPPER(isActive) IN ('TRUE') THEN 'True'
        ELSE 'False'
	END AS standard_status
FROM customer;

# Remove duplicates

DELETE FROM customers
WHERE CustomerID NOT IN (
	SELECT MIN(CustomerID)
	FROM customer
	GROUP BY Email
);

