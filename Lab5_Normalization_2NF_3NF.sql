-- ============================================================
-- Database Systems - Lab 5
-- Topic: Database Normalization (Part 2 of 2)
-- Scope: Task 3 (Convert to 2NF)
--        Task 4 (Convert to 3NF)
--        Task 5 (Verification queries)
--        Task 6 (Reflection)
-- Continued from Lab 4 (Task 1: FDs/anomalies, Task 2: 1NF)
-- ============================================================

CREATE DATABASE IF NOT EXISTS bookstore_normalization;
USE bookstore_normalization;

-- ============================================================
-- TASK 3: Convert to 2NF
-- ============================================================

-- 1NF primary key was (OrderID, BookID). Inspect each non-key attribute
-- to see whether it depends on the WHOLE key or only PART of it:
--
--   OrderDate, CustID, CustName, CustEmail  -> depend on OrderID ALONE
--                                               => PARTIAL DEPENDENCY, extract
--   BookTitle, Publisher, UnitPrice         -> depend on BookID ALONE
--                                               => PARTIAL DEPENDENCY, extract
--   Qty                                     -> depends on (OrderID, BookID) together
--                                               => FULL dependency, keep in line-item table
--
-- Decompose into: Orders (order+customer info), Book_2NF (book+publisher
-- info), and OrderLine (the linking/junction table keeping only Qty).

DROP TABLE IF EXISTS OrderLine;
DROP TABLE IF EXISTS OrderBook_1NF;
DROP TABLE IF EXISTS Book_2NF;
DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    OrderID   VARCHAR(10) PRIMARY KEY,
    OrderDate DATE,
    CustID    VARCHAR(10),
    CustName  VARCHAR(50),
    CustEmail VARCHAR(100)
);

CREATE TABLE Book_2NF (
    BookID    VARCHAR(10) PRIMARY KEY,
    BookTitle VARCHAR(100),
    Publisher VARCHAR(50),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE OrderLine (
    OrderID VARCHAR(10),
    BookID  VARCHAR(10),
    Qty     INT,
    PRIMARY KEY (OrderID, BookID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (BookID) REFERENCES Book_2NF(BookID)
);

-- Progress, but not done:
-- Orders still mixes order info with customer info (CustName, CustEmail
-- depend on CustID, not on OrderID) -> this is a TRANSITIVE dependency,
-- resolved next in 3NF.

-- ============================================================
-- TASK 4: Convert to 3NF
-- ============================================================

-- In Orders: OrderID -> CustID, and CustID -> CustName, CustEmail.
-- CustName/CustEmail depend on CustID (a non-prime attribute), not
-- directly on OrderID. Extract Customer into its own table.

DROP TABLE IF EXISTS OrderLine;
DROP TABLE IF EXISTS Orders;

CREATE TABLE Customer (
    CustID    VARCHAR(10) PRIMARY KEY,
    CustName  VARCHAR(50),
    CustEmail VARCHAR(100)
);

CREATE TABLE Orders (
    OrderID   VARCHAR(10) PRIMARY KEY,
    OrderDate DATE,
    CustID    VARCHAR(10),
    FOREIGN KEY (CustID) REFERENCES Customer(CustID)
);

CREATE TABLE OrderLine (
    OrderID VARCHAR(10),
    BookID  VARCHAR(10),
    Qty     INT,
    PRIMARY KEY (OrderID, BookID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (BookID) REFERENCES Book_2NF(BookID)
);

-- Final 3NF schema: Customer, Orders, Book_2NF, OrderLine
-- Every non-prime attribute now depends on the key, the whole key,
-- and nothing but the key.

-- Populate
INSERT INTO Customer VALUES
('C-11', 'Bilal', 'bilal@x.com'),
('C-12', 'Areeba', 'areeba@x.com');

INSERT INTO Orders VALUES
('O-501', '2026-04-02', 'C-11'),
('O-502', '2026-04-03', 'C-12'),
('O-503', '2026-04-05', 'C-11');

INSERT INTO Book_2NF VALUES
('B-1', 'SQL Basics', 'Pearson', 1200.00),
('B-2', 'Python 101', 'OReilly', 1500.00),
('B-3', 'Networks',   'Pearson', 1800.00);

INSERT INTO OrderLine VALUES
('O-501', 'B-1', 1),
('O-501', 'B-2', 2),
('O-502', 'B-1', 3),
('O-503', 'B-3', 1),
('O-503', 'B-2', 1);

-- ============================================================
-- TASK 5: Verification queries
-- ============================================================

-- (a) Reproduce the original report: one row per book purchased
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustName,
    c.CustEmail,
    b.BookTitle,
    b.Publisher,
    b.UnitPrice,
    ol.Qty,
    (b.UnitPrice * ol.Qty) AS LineTotal
FROM OrderLine ol
JOIN Orders o   ON ol.OrderID = o.OrderID
JOIN Customer c ON o.CustID = c.CustID
JOIN Book_2NF b ON ol.BookID = b.BookID
ORDER BY o.OrderID, b.BookID;

-- (b) Every customer's total spend
SELECT
    c.CustID,
    c.CustName,
    SUM(b.UnitPrice * ol.Qty) AS TotalSpend
FROM Customer c
JOIN Orders o   ON c.CustID = o.CustID
JOIN OrderLine ol ON o.OrderID = ol.OrderID
JOIN Book_2NF b ON ol.BookID = b.BookID
GROUP BY c.CustID, c.CustName
ORDER BY TotalSpend DESC;

-- ============================================================
-- TASK 6: Reflection
-- ============================================================

-- How the final 3NF schema prevents the anomalies from Task 1 (Lab 4):
--
-- 1. Insertion anomaly fixed: a new book and its publisher can now be
--    added directly to Book_2NF the moment it is catalogued, with no
--    need for an order to exist first — Book_2NF is independent of
--    Orders/OrderLine.
-- 2. Update anomaly fixed: a customer's email lives in exactly one row
--    of Customer, keyed by CustID. Changing it means updating a single
--    row, and every order automatically reflects the new value through
--    the foreign key.
-- 3. Deletion anomaly fixed: deleting an order (a row in Orders/
--    OrderLine) no longer removes book or publisher facts, because
--    that information is stored independently in Book_2NF.
-- 4. Redundancy is minimized: customer name/email, and book title/
--    publisher/price, are each stored exactly once, rather than
--    repeating on every order line that references them.
-- 5. Referential integrity is now enforced by foreign keys, so an
--    OrderLine can never reference a nonexistent Order or Book.
-- 6. The schema remains easy to query: Task 5's joins show the
--    original flat report can always be reconstructed on demand,
--    so normalization costs nothing in terms of reporting ability.

-- ============================================================
-- End of Lab 5 Script
-- ============================================================
