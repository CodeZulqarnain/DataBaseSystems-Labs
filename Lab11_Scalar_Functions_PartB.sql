-- ============================================================
-- Database Systems - Lab 11
-- Topic: Scalar SQL Functions (Part 2 of 2)
-- Scope: Part B (Numeric & Date/Time Functions)
-- Continued from Lab 10 (setup script + Part A)
-- Uses the Customer/Product schema created in Lab 10 (scalar_lab database)
-- ============================================================

USE scalar_lab;

-- ============================================================
-- PART B: Numeric and Date/Time Functions
-- ============================================================

-- Task B1: 15% discount on every product, rounded to 2 decimals
SELECT ProdName, Price, ROUND(Price * 0.85, 2) AS DiscountedPrice
FROM Product;

-- Task B2: 17% sales tax and final price
SELECT ProdName,
       ROUND(Price * 0.17, 2) AS Tax,
       ROUND(Price * 1.17, 2) AS PriceWithTax
FROM Product;

-- Task B3: Floor and ceiling of price / 1000
SELECT ProdName, Price,
       FLOOR(Price / 1000) AS FloorVal,
       CEIL(Price / 1000) AS CeilVal
FROM Product;

-- Task B4: Round each price to the nearest hundred
SELECT ProdName, Price, ROUND(Price, -2) AS RoundedToHundred
FROM Product;

-- Task B5: Products with an odd ProdID
SELECT ProdID, ProdName
FROM Product
WHERE MOD(ProdID, 2) = 1;

-- Task B6: Year, month name, and weekday of joining, per customer
SELECT CustName,
       YEAR(JoinDate) AS JoinYear,
       MONTHNAME(JoinDate) AS JoinMonth,
       DAYNAME(JoinDate) AS JoinWeekday
FROM Customer;

-- Task B7: Date of birth formatted as 'DD-Month-YYYY'
SELECT CustName, DATE_FORMAT(DOB, '%d-%M-%Y') AS FormattedDOB
FROM Customer;

-- Task B8: Current age in years
SELECT CustName, DOB, TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age
FROM Customer;

-- Task B9: Days since each customer joined
SELECT CustName, JoinDate, DATEDIFF(CURDATE(), JoinDate) AS DaysSinceJoin
FROM Customer;

-- Task B10: Customers who joined in the year 2023 (date function, not BETWEEN)
SELECT CustName, JoinDate
FROM Customer
WHERE YEAR(JoinDate) = 2023;

-- Task B11: Products launched in any year's Q4 (Oct, Nov, Dec)
SELECT ProdName, LaunchDate
FROM Product
WHERE MONTH(LaunchDate) IN (10, 11, 12)
ORDER BY LaunchDate;

-- Task B12: Customers who joined within the last 6 months from today
SELECT CustName, JoinDate
FROM Customer
WHERE JoinDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- Task B13: Product 'age' in days (days since launch)
SELECT ProdName, LaunchDate, DATEDIFF(CURDATE(), LaunchDate) AS AgeInDays
FROM Product;

-- Task B14: Date exactly 90 days after each product's LaunchDate
SELECT ProdName, LaunchDate,
       DATE_ADD(LaunchDate, INTERVAL 90 DAY) AS NinetyDaysLater
FROM Product;

-- Task B15: Combined challenge -
-- 'Hello ALI KHAN, age 31, joined Jan 2022'
SELECT CustID,
       CONCAT(
           'Hello ', UPPER(TRIM(CustName)),
           ', age ', TIMESTAMPDIFF(YEAR, DOB, CURDATE()),
           ', joined ', DATE_FORMAT(JoinDate, '%b %Y')
       ) AS Summary
FROM Customer;

-- ============================================================
-- End of Lab 11 Script
-- ============================================================
