-- ============================================================
-- Database Systems - Lab 4
-- Topic: Database Normalization (Part 1 of 2)
-- Scope: Task 1 (Functional Dependencies & Anomalies)
--        Task 2 (Convert to 1NF)
-- Continued in Lab 5: Task 3 (2NF) onward
-- ============================================================

-- ============================================================
-- TASK 1: Identify FDs and anomalies
-- ============================================================

-- Raw unnormalized data (Table 7.1 from manual):
-- OrderID | OrderDate | CustID | CustName | CustEmail | BookID | BookTitle | Publisher | UnitPrice | Qty

-- Functional Dependencies identified:
--   OrderID           -> OrderDate, CustID
--   CustID            -> CustName, CustEmail
--   BookID            -> BookTitle, Publisher, UnitPrice
--   (OrderID, BookID) -> Qty
--   (Publisher is fully determined by BookID, not by OrderID)

-- Candidate key of the raw table: (OrderID, BookID)
--   -- this is the only combination that uniquely identifies
--   -- "how many of which book were bought on which order"

-- Anomalies present in the flat/unnormalized design:
--
-- Insertion anomaly:
--   We cannot add a new publisher's book (e.g. a new title from a new
--   publisher) to the catalog until it is actually purchased in an order,
--   because book/publisher data only exists as part of an order row.
--
-- Update anomaly:
--   If customer Bilal's email changes, every order row belonging to
--   Bilal (O-501 and O-503) must be updated. Missing one row leaves
--   inconsistent email addresses for the same customer.
--
-- Deletion anomaly:
--   If order O-502 (the only order containing "SQL Basics" at that
--   point) is deleted, we lose all knowledge that Pearson publishes
--   "SQL Basics" at PKR 1200, even though that is a fact about the
--   book, not about the order.

-- ============================================================
-- TASK 2: Convert to 1NF
-- ============================================================

-- 1NF requires atomic values and no repeating groups.
-- We flatten the multi-valued "Books purchased per order" cells into
-- one row per (order, book) pair.
-- Primary Key for the 1NF table: (OrderID, BookID)
--   because a single OrderID can list multiple BookIDs, and the pair
--   together uniquely identifies each line item.

CREATE DATABASE IF NOT EXISTS bookstore_normalization;
USE bookstore_normalization;

DROP TABLE IF EXISTS OrderBook_1NF;

CREATE TABLE OrderBook_1NF (
    OrderID    VARCHAR(10),
    OrderDate  DATE,
    CustID     VARCHAR(10),
    CustName   VARCHAR(50),
    CustEmail  VARCHAR(100),
    BookID     VARCHAR(10),
    BookTitle  VARCHAR(100),
    Publisher  VARCHAR(50),
    UnitPrice  DECIMAL(10,2),
    Qty        INT,
    PRIMARY KEY (OrderID, BookID)
);

INSERT INTO OrderBook_1NF VALUES
('O-501', '2026-04-02', 'C-11', 'Bilal',  'bilal@x.com',   'B-1', 'SQL Basics',  'Pearson',  1200.00, 1),
('O-501', '2026-04-02', 'C-11', 'Bilal',  'bilal@x.com',   'B-2', 'Python 101',  'OReilly',  1500.00, 2),
('O-502', '2026-04-03', 'C-12', 'Areeba', 'areeba@x.com',  'B-1', 'SQL Basics',  'Pearson',  1200.00, 3),
('O-503', '2026-04-05', 'C-11', 'Bilal',  'bilal@x.com',   'B-3', 'Networks',    'Pearson',  1800.00, 1),
('O-503', '2026-04-05', 'C-11', 'Bilal',  'bilal@x.com',   'B-2', 'Python 101',  'OReilly',  1500.00, 1);

-- Verify: one row per book purchased, all cells atomic
SELECT * FROM OrderBook_1NF ORDER BY OrderID, BookID;

-- ============================================================
-- Still broken (as the manual notes about the class example):
-- OrderDate/CustName/CustEmail repeat for every book in an order,
-- and BookTitle/Publisher/UnitPrice repeat for every order that
-- includes that book. Redundancy remains -> this is only 1NF.
-- Partial and transitive dependencies are resolved in Lab 5
-- (2NF and 3NF).
-- ============================================================
