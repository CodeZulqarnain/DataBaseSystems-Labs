-- ============================================================================
-- CarGo Rentals -- Car Rental Management System
-- DBMS Open-Ended Lab
-- Dialect: Microsoft SQL Server (T-SQL) -- tested for SSMS
-- ============================================================================

IF DB_ID('CarGoRentals') IS NOT NULL
BEGIN
    ALTER DATABASE CarGoRentals SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CarGoRentals;
END
GO

CREATE DATABASE CarGoRentals;
GO

USE CarGoRentals;
GO

-- ============================================================================
-- TASK 1: DATABASE DESIGN AND IMPLEMENTATION
-- ============================================================================
-- Design notes (see report for full justification):
--   Customers   : one row per customer (identified independently of any rental)
--   Vehicles    : one row per physical vehicle, tracks current Status
--   Rentals     : one row per rental transaction (links a Customer to a Vehicle)
--   Returns     : one row per completed return, linked 1:1 to a Rental
--   Payments    : one row per payment made against a Rental (supports partial/
--                 multiple payments per rental)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: Customers
-- ----------------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID      INT IDENTITY(1,1) PRIMARY KEY,
    FullName        VARCHAR(100) NOT NULL,
    Phone           VARCHAR(15)  NOT NULL UNIQUE,
    CNIC            VARCHAR(15)  NOT NULL UNIQUE,
    Email           VARCHAR(100) NULL UNIQUE,
    Address         VARCHAR(200) NULL,
    RegisteredOn    DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE))
);
GO

-- ----------------------------------------------------------------------------
-- Table: Vehicles
-- ----------------------------------------------------------------------------
CREATE TABLE Vehicles (
    VehicleID       INT IDENTITY(1,1) PRIMARY KEY,
    VehicleNumber   VARCHAR(15)  NOT NULL UNIQUE,       -- registration plate
    Make            VARCHAR(50)  NOT NULL,
    Model           VARCHAR(50)  NOT NULL,
    ManufactureYear INT          NOT NULL CHECK (ManufactureYear BETWEEN 1990 AND 2030),
    DailyRate       DECIMAL(10,2) NOT NULL CHECK (DailyRate > 0),
    Status          VARCHAR(15)  NOT NULL DEFAULT 'Available'
                    CHECK (Status IN ('Available','Rented','Maintenance'))
);
GO

-- ----------------------------------------------------------------------------
-- Table: Rentals
-- ----------------------------------------------------------------------------
CREATE TABLE Rentals (
    RentalID            INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID          INT NOT NULL,
    VehicleID           INT NOT NULL,
    RentalDate          DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    ExpectedReturnDate  DATE NOT NULL,
    AgreedDailyRate     DECIMAL(10,2) NOT NULL,   -- copy of rate at time of booking (historical accuracy)
    Status              VARCHAR(15) NOT NULL DEFAULT 'Active'
                        CHECK (Status IN ('Active','Completed','Cancelled')),
    CONSTRAINT fk_rental_customer FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),
    CONSTRAINT fk_rental_vehicle FOREIGN KEY (VehicleID)
        REFERENCES Vehicles(VehicleID),
    CONSTRAINT chk_dates CHECK (ExpectedReturnDate >= RentalDate)
);
GO

-- ----------------------------------------------------------------------------
-- Table: Returns  (1:1 with Rentals -- a rental is returned at most once)
-- ----------------------------------------------------------------------------
CREATE TABLE Returns (
    ReturnID            INT IDENTITY(1,1) PRIMARY KEY,
    RentalID            INT NOT NULL UNIQUE,
    ActualReturnDate    DATE NOT NULL,
    TotalDays           INT NOT NULL CHECK (TotalDays > 0),
    LateFee             DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (LateFee >= 0),
    CONSTRAINT fk_return_rental FOREIGN KEY (RentalID)
        REFERENCES Rentals(RentalID)
);
GO

-- ----------------------------------------------------------------------------
-- Table: Payments
-- ----------------------------------------------------------------------------
CREATE TABLE Payments (
    PaymentID       INT IDENTITY(1,1) PRIMARY KEY,
    RentalID        INT NOT NULL,
    Amount          DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentDate     DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    PaymentMethod   VARCHAR(15) NOT NULL DEFAULT 'Cash'
                    CHECK (PaymentMethod IN ('Cash','Card','Online')),
    CONSTRAINT fk_payment_rental FOREIGN KEY (RentalID)
        REFERENCES Rentals(RentalID)
);
GO

-- Helpful indexes for reporting / JOIN performance (see Task 7 optimization)
CREATE INDEX idx_rentals_customer ON Rentals(CustomerID);
CREATE INDEX idx_rentals_vehicle  ON Rentals(VehicleID);
CREATE INDEX idx_payments_rental  ON Payments(RentalID);
GO

-- ============================================================================
-- SAMPLE DATA
-- ============================================================================

INSERT INTO Customers (FullName, Phone, CNIC, Email, Address) VALUES
('Ali Khan',        '0300-1234567', '35202-1111111-1', 'ali.khan@mail.com',     'Model Town, Lahore'),
('Sara Ahmed',      '0321-2345678', '35202-2222222-2', 'sara.ahmed@mail.com',   'DHA Phase 5, Lahore'),
('Bilal Hussain',   '0333-3456789', '42101-3333333-3', 'bilal.h@mail.com',      'Gulshan-e-Iqbal, Karachi'),
('Ayesha Malik',    '0345-4567890', '61101-4444444-4', 'ayesha.malik@mail.com', 'F-10, Islamabad'),
('Usman Tariq',     '0301-5678901', '35201-5555555-5', 'usman.tariq@mail.com',  'Johar Town, Lahore');
GO

INSERT INTO Vehicles (VehicleNumber, Make, Model, ManufactureYear, DailyRate, Status) VALUES
('ABC-123', 'Toyota',   'Corolla',  2022, 5000.00, 'Available'),
('LEA-456', 'Honda',    'Civic',    2023, 6500.00, 'Available'),
('LES-789', 'Suzuki',   'Alto',     2021, 3000.00, 'Available'),
('LEB-321', 'Toyota',   'Yaris',    2022, 4500.00, 'Available'),
('KHI-654', 'Kia',      'Sportage', 2023, 8000.00, 'Available'),
('ISB-987', 'Hyundai',  'Elantra',  2021, 5500.00, 'Maintenance');
GO

-- Rentals: some active (currently rented), some completed
INSERT INTO Rentals (CustomerID, VehicleID, RentalDate, ExpectedReturnDate, AgreedDailyRate, Status) VALUES
(1, 1, '2026-09-01', '2026-09-04', 5000.00, 'Completed'),  -- Ali Khan / Corolla
(2, 2, '2026-09-05', '2026-09-08', 6500.00, 'Completed'),
(3, 3, '2026-09-10', '2026-09-12', 3000.00, 'Completed'),
(1, 4, '2026-09-15', '2026-09-18', 4500.00, 'Active'),     -- Ali Khan renting again, currently out
(4, 5, '2026-09-18', '2026-09-22', 8000.00, 'Active');     -- currently out
GO

-- Corresponding returns for the completed rentals only
INSERT INTO Returns (RentalID, ActualReturnDate, TotalDays, LateFee) VALUES
(1, '2026-09-04', 3, 0.00),
(2, '2026-09-08', 3, 0.00),
(3, '2026-09-13', 3, 500.00);   -- returned 1 day late
GO

-- Payments against rentals
INSERT INTO Payments (RentalID, Amount, PaymentDate, PaymentMethod) VALUES
(1, 15000.00, '2026-09-04', 'Cash'),
(2, 19500.00, '2026-09-08', 'Card'),
(3, 9500.00,  '2026-09-13', 'Online'),
(4, 13500.00, '2026-09-15', 'Cash'),   -- advance payment on an active rental
(5, 32000.00, '2026-09-18', 'Online');
GO

-- Mark vehicles that are currently on active rentals as 'Rented'
-- (would normally be handled automatically by the trigger below on new inserts;
--  done manually here only to make the seeded sample data consistent)
UPDATE Vehicles SET Status = 'Rented' WHERE VehicleID IN (4, 5);
GO

-- ============================================================================
-- TRIGGERS
-- ============================================================================
-- SQL Server has no BEFORE trigger, so the availability check is implemented
-- as an INSTEAD OF INSERT trigger (it runs in place of the insert, so it can
-- block the insert before any row is written -- the same effect as MySQL's
-- BEFORE INSERT trigger).
-- ----------------------------------------------------------------------------

CREATE TRIGGER trg_check_vehicle_availability
ON Rentals
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Reject if the vehicle does not exist
    IF EXISTS (
        SELECT 1 FROM inserted i
        LEFT JOIN Vehicles v ON v.VehicleID = i.VehicleID
        WHERE v.VehicleID IS NULL
    )
    BEGIN
        RAISERROR('Vehicle does not exist.', 16, 1);
        RETURN;
    END

    -- Reject if the vehicle is not currently Available
    -- (enforces: "a vehicle should not be available for another rental
    --  while it is already rented")
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Vehicles v ON v.VehicleID = i.VehicleID
        WHERE v.Status <> 'Available'
    )
    BEGIN
        RAISERROR('Vehicle is not available for rental.', 16, 1);
        RETURN;
    END

    -- All rows passed validation: perform the real insert
    INSERT INTO Rentals (CustomerID, VehicleID, RentalDate, ExpectedReturnDate, AgreedDailyRate, Status)
    SELECT CustomerID, VehicleID, RentalDate, ExpectedReturnDate, AgreedDailyRate, Status
    FROM inserted;
END
GO

-- ----------------------------------------------------------------------------
-- Trigger 2: When a new rental is created, mark the vehicle as 'Rented'
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_mark_vehicle_rented
ON Rentals
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE v
    SET v.Status = 'Rented'
    FROM Vehicles v
    JOIN inserted i ON i.VehicleID = v.VehicleID;
END
GO

-- ----------------------------------------------------------------------------
-- Trigger 3: When a return is recorded, mark the vehicle 'Available' again
-- and close out the rental as 'Completed'
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_process_return
ON Returns
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE v
    SET v.Status = 'Available'
    FROM Vehicles v
    JOIN Rentals r ON r.VehicleID = v.VehicleID
    JOIN inserted i ON i.RentalID = r.RentalID;

    UPDATE r
    SET r.Status = 'Completed'
    FROM Rentals r
    JOIN inserted i ON i.RentalID = r.RentalID;
END
GO

-- ============================================================================
-- TASK 3: JOIN QUERIES
-- ============================================================================

-- Q1: Customer name, vehicle number, model, rental date, return date for every rental
SELECT
    c.FullName            AS CustomerName,
    v.VehicleNumber,
    v.Model,
    r.RentalDate,
    ret.ActualReturnDate
FROM Rentals r
INNER JOIN Customers c ON c.CustomerID = r.CustomerID
INNER JOIN Vehicles  v ON v.VehicleID  = r.VehicleID
LEFT JOIN Returns    ret ON ret.RentalID = r.RentalID;   -- LEFT JOIN: active rentals have no return yet
GO

-- Q2: All customers and the vehicles they have rented (customers with zero
--     rentals must still appear)
SELECT
    c.FullName            AS CustomerName,
    v.VehicleNumber,
    v.Model
FROM Customers c
LEFT JOIN Rentals r  ON r.CustomerID = c.CustomerID
LEFT JOIN Vehicles v ON v.VehicleID  = r.VehicleID
ORDER BY c.FullName;
GO

-- Q3: All vehicles and their current rental information (vehicles that are
--     not currently rented must still appear)
SELECT
    v.VehicleNumber,
    v.Model,
    v.Status,
    c.FullName    AS CurrentRenter,
    r.RentalDate,
    r.ExpectedReturnDate
FROM Vehicles v
LEFT JOIN Rentals r  ON r.VehicleID = v.VehicleID AND r.Status = 'Active'
LEFT JOIN Customers c ON c.CustomerID = r.CustomerID
ORDER BY v.VehicleNumber;
GO

-- Q4: Total number of rentals made by each customer (customers with no
--     rentals must show a count of 0)
SELECT
    c.FullName          AS CustomerName,
    COUNT(r.RentalID)   AS TotalRentals
FROM Customers c
LEFT JOIN Rentals r ON r.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY TotalRentals DESC;
GO

-- ============================================================================
-- TASK 4: VIEW
-- ============================================================================
-- Consolidated rental report: one row per rental with customer, vehicle,
-- return and payment information combined. Useful because management can
-- query a single view instead of writing a 5-table JOIN every time a rental
-- report is needed, and reporting tools (Excel, BI dashboards) can plug into
-- it directly without exposing the underlying normalized schema.

CREATE VIEW vw_RentalReport AS
SELECT
    r.RentalID,
    c.FullName              AS CustomerName,
    c.Phone                 AS CustomerPhone,
    v.VehicleNumber,
    v.Model                 AS VehicleModel,
    r.RentalDate,
    r.ExpectedReturnDate,
    ret.ActualReturnDate,
    r.Status                AS RentalStatus,
    r.AgreedDailyRate,
    ret.LateFee,
    ISNULL(pay.TotalPaid, 0) AS TotalPaid
FROM Rentals r
JOIN Customers c   ON c.CustomerID = r.CustomerID
JOIN Vehicles  v   ON v.VehicleID  = r.VehicleID
LEFT JOIN Returns ret ON ret.RentalID = r.RentalID
LEFT JOIN (
    SELECT RentalID, SUM(Amount) AS TotalPaid
    FROM Payments
    GROUP BY RentalID
) pay ON pay.RentalID = r.RentalID;
GO

-- Demonstration:
SELECT * FROM vw_RentalReport ORDER BY RentalID;
GO

-- ============================================================================
-- TASK 6: STORED PROCEDURE
-- ============================================================================
-- Registers a new rental for a customer/vehicle pair and calculates the
-- estimated rental charge for the planned period (daily rate * number of
-- days). Relies on trg_check_vehicle_availability to reject the booking if
-- the vehicle is not Available.

CREATE PROCEDURE sp_RegisterRental
    @CustomerID          INT,
    @VehicleID           INT,
    @RentalDate          DATE,
    @ExpectedReturnDate  DATE,
    @EstimatedCharge     DECIMAL(10,2) OUTPUT,
    @NewRentalID         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DailyRate DECIMAL(10,2);
    DECLARE @Days INT;

    -- Fetch the vehicle's current daily rate
    SELECT @DailyRate = DailyRate
    FROM Vehicles
    WHERE VehicleID = @VehicleID;

    IF @DailyRate IS NULL
    BEGIN
        RAISERROR('Invalid VehicleID.', 16, 1);
        RETURN;
    END

    SET @Days = DATEDIFF(DAY, @RentalDate, @ExpectedReturnDate);
    IF @Days < 1 SET @Days = 1;

    SET @EstimatedCharge = @Days * @DailyRate;

    -- Insert the rental (trg_check_vehicle_availability fires here and
    -- blocks the insert if the vehicle isn't Available; trg_mark_vehicle_rented
    -- then flips the vehicle to 'Rented')
    INSERT INTO Rentals (CustomerID, VehicleID, RentalDate, ExpectedReturnDate, AgreedDailyRate)
    VALUES (@CustomerID, @VehicleID, @RentalDate, @ExpectedReturnDate, @DailyRate);

    SET @NewRentalID = SCOPE_IDENTITY();
END
GO

-- Demonstration: register a new rental for Usman Tariq (CustomerID 5) on the
-- Suzuki Alto (VehicleID 3), which is currently Available
DECLARE @charge DECIMAL(10,2), @newId INT;

EXEC sp_RegisterRental
    @CustomerID = 5,
    @VehicleID = 3,
    @RentalDate = '2026-09-25',
    @ExpectedReturnDate = '2026-09-28',
    @EstimatedCharge = @charge OUTPUT,
    @NewRentalID = @newId OUTPUT;

SELECT @newId AS NewRentalID, @charge AS EstimatedCharge;
GO

-- Demonstration of the business rule being enforced: this call is expected
-- to fail because VehicleID 4 is currently 'Rented' (uncomment to test)
-- DECLARE @charge2 DECIMAL(10,2), @newId2 INT;
-- EXEC sp_RegisterRental 2, 4, '2026-09-26', '2026-09-29', @charge2 OUTPUT, @newId2 OUTPUT;

-- ============================================================================
-- TASK 7: OPTIMIZATION -- see report for full analysis. Improved query below.
-- ============================================================================

-- BEFORE: computing each customer's total amount paid using a correlated
-- subquery per row (re-scans Payments/Rentals once per customer)
SELECT
    c.CustomerID,
    c.FullName,
    (SELECT ISNULL(SUM(p.Amount), 0)
     FROM Payments p
     JOIN Rentals r ON r.RentalID = p.RentalID
     WHERE r.CustomerID = c.CustomerID) AS TotalPaid
FROM Customers c;
GO

-- AFTER: single pass using JOIN + GROUP BY, supported by the
-- idx_rentals_customer / idx_payments_rental indexes created above
SELECT
    c.CustomerID,
    c.FullName,
    ISNULL(SUM(p.Amount), 0) AS TotalPaid
FROM Customers c
LEFT JOIN Rentals r  ON r.CustomerID = c.CustomerID
LEFT JOIN Payments p ON p.RentalID   = r.RentalID
GROUP BY c.CustomerID, c.FullName;
GO
