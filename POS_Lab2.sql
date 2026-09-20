-- ============================================================
-- Point of Sale (POS) System Database
-- Database Systems - Lab 2
-- ============================================================

DROP DATABASE IF EXISTS `POS_System`;
CREATE DATABASE `POS_System` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `POS_System`;

-- ------------------------------------------------------------
-- Table: Categories
-- ------------------------------------------------------------
CREATE TABLE `Categories` (
  `CategoryID` INT(11) NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(50) NOT NULL,
  `Description` TEXT DEFAULT NULL,
  PRIMARY KEY (`CategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Customers
-- ------------------------------------------------------------
CREATE TABLE `Customers` (
  `CustomerID` INT(20) NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(50) NOT NULL,
  `LastName` VARCHAR(50) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  `Phone` VARCHAR(20) NOT NULL,
  `Address` TEXT NOT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`CustomerID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Employees
-- ------------------------------------------------------------
CREATE TABLE `Employees` (
  `EmployeeID` INT(11) NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(50) DEFAULT NULL,
  `LastName` VARCHAR(50) DEFAULT NULL,
  `Email` VARCHAR(100) DEFAULT NULL,
  `Phone` VARCHAR(20) DEFAULT NULL,
  `Role` ENUM('Cashier','Manager','Admin') DEFAULT NULL,
  `PasswordHash` VARCHAR(255) DEFAULT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`EmployeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Suppliers
-- ------------------------------------------------------------
CREATE TABLE `Suppliers` (
  `SupplierID` INT(11) NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(100) DEFAULT NULL,
  `ContactName` VARCHAR(50) DEFAULT NULL,
  `Email` VARCHAR(100) DEFAULT NULL,
  `Phone` VARCHAR(20) DEFAULT NULL,
  `Address` TEXT DEFAULT NULL,
  PRIMARY KEY (`SupplierID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Discounts
-- ------------------------------------------------------------
CREATE TABLE `Discounts` (
  `DiscountID` INT(11) NOT NULL AUTO_INCREMENT,
  `Code` VARCHAR(50) DEFAULT NULL,
  `Type` ENUM('Percentage','Fixed') DEFAULT NULL,
  `Value` DECIMAL(10,2) DEFAULT NULL,
  `ExpiryDate` DATE DEFAULT NULL,
  PRIMARY KEY (`DiscountID`),
  UNIQUE KEY `Code` (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Products
-- ------------------------------------------------------------
CREATE TABLE `Products` (
  `ProductID` INT(11) NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(100) NOT NULL,
  `Description` TEXT DEFAULT NULL,
  `SKU` VARCHAR(50) DEFAULT NULL,
  `Price` DECIMAL(10,2) NOT NULL,
  `Cost` DECIMAL(10,2) DEFAULT NULL,
  `QuantityInStock` INT(11) DEFAULT 0,
  `CategoryID` INT(11) DEFAULT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ProductID`),
  UNIQUE KEY `SKU` (`SKU`),
  KEY `CategoryID` (`CategoryID`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `Categories` (`CategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Inventory
-- ------------------------------------------------------------
CREATE TABLE `Inventory` (
  `InventoryID` INT(11) NOT NULL AUTO_INCREMENT,
  `ProductID` INT(11) DEFAULT NULL,
  `QuantityChange` INT(11) DEFAULT NULL,
  `ChangeType` ENUM('Purchase','Sale','Return','Adjustment') DEFAULT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`InventoryID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`ProductID`) REFERENCES `Products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Purchases
-- ------------------------------------------------------------
CREATE TABLE `Purchases` (
  `PurchaseID` INT(11) NOT NULL AUTO_INCREMENT,
  `SupplierID` INT(11) DEFAULT NULL,
  `EmployeeID` INT(11) DEFAULT NULL,
  `PurchaseDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `TotalAmount` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (`PurchaseID`),
  KEY `SupplierID` (`SupplierID`),
  KEY `EmployeeID` (`EmployeeID`),
  CONSTRAINT `purchases_ibfk_1` FOREIGN KEY (`SupplierID`) REFERENCES `Suppliers` (`SupplierID`),
  CONSTRAINT `purchases_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `Employees` (`EmployeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: PurchaseItems
-- ------------------------------------------------------------
CREATE TABLE `PurchaseItems` (
  `PurchaseItemID` INT(11) NOT NULL AUTO_INCREMENT,
  `PurchaseID` INT(11) DEFAULT NULL,
  `ProductID` INT(11) DEFAULT NULL,
  `Quantity` INT(11) DEFAULT NULL,
  `CostPrice` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (`PurchaseItemID`),
  KEY `PurchaseID` (`PurchaseID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `purchaseitems_ibfk_1` FOREIGN KEY (`PurchaseID`) REFERENCES `Purchases` (`PurchaseID`),
  CONSTRAINT `purchaseitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Sales
-- ------------------------------------------------------------
CREATE TABLE `Sales` (
  `SaleID` INT(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` INT(11) DEFAULT NULL,
  `EmployeeID` INT(11) DEFAULT NULL,
  `TotalAmount` DECIMAL(10,2) DEFAULT NULL,
  `PaymentType` ENUM('Cash','Card','Mobile','Other') DEFAULT NULL,
  `SaleDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`SaleID`),
  KEY `CustomerID` (`CustomerID`),
  KEY `EmployeeID` (`EmployeeID`),
  CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `Customers` (`CustomerID`),
  CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `Employees` (`EmployeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: SaleItems
-- ------------------------------------------------------------
CREATE TABLE `SaleItems` (
  `SaleItemID` INT(11) NOT NULL AUTO_INCREMENT,
  `SaleID` INT(11) DEFAULT NULL,
  `ProductID` INT(11) DEFAULT NULL,
  `Quantity` INT(11) DEFAULT NULL,
  `Price` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (`SaleItemID`),
  KEY `SaleID` (`SaleID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `saleitems_ibfk_1` FOREIGN KEY (`SaleID`) REFERENCES `Sales` (`SaleID`),
  CONSTRAINT `saleitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- Table: Returns
-- ------------------------------------------------------------
CREATE TABLE `Returns` (
  `ReturnID` INT(11) NOT NULL AUTO_INCREMENT,
  `SaleID` INT(11) DEFAULT NULL,
  `ProductID` INT(11) DEFAULT NULL,
  `Quantity` INT(11) DEFAULT NULL,
  `Reason` TEXT DEFAULT NULL,
  `ReturnDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ReturnID`),
  KEY `SaleID` (`SaleID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `returns_ibfk_1` FOREIGN KEY (`SaleID`) REFERENCES `Sales` (`SaleID`),
  CONSTRAINT `returns_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- Sample Data
-- ============================================================

INSERT INTO `Categories` (`Name`, `Description`) VALUES
('Electronics', 'Electronic gadgets and accessories'),
('Groceries', 'Daily grocery and food items'),
('Stationery', 'Office and school supplies');

INSERT INTO `Suppliers` (`Name`, `ContactName`, `Email`, `Phone`, `Address`) VALUES
('TechSource Traders', 'Ali Hamza', 'ali.hamza@techsource.com', '03211234567', 'Islamabad'),
('Fresh Mart Distributors', 'Sana Khan', 'sana.khan@freshmart.com', '03007654321', 'Lahore');

INSERT INTO `Employees` (`FirstName`, `LastName`, `Email`, `Phone`, `Role`, `PasswordHash`) VALUES
('Bilal', 'Ahmed', 'bilal.ahmed@possystem.com', '03451112233', 'Manager', 'hashed_pw_1'),
('Hina', 'Riaz', 'hina.riaz@possystem.com', '03211119988', 'Cashier', 'hashed_pw_2');

INSERT INTO `Customers` (`FirstName`, `LastName`, `Email`, `Phone`, `Address`) VALUES
('Ahmed', 'Raza', 'ahmed.raza@gmail.com', '03331234567', 'Gilgit-Baltistan'),
('Sara', 'Iqbal', 'sara.iqbal@gmail.com', '03215557788', 'Skardu');

INSERT INTO `Discounts` (`Code`, `Type`, `Value`, `ExpiryDate`) VALUES
('WELCOME10', 'Percentage', 10.00, '2026-12-31'),
('FLAT500', 'Fixed', 500.00, '2026-11-30');

INSERT INTO `Products` (`Name`, `Description`, `SKU`, `Price`, `Cost`, `QuantityInStock`, `CategoryID`) VALUES
('Wireless Mouse', 'Ergonomic wireless mouse', 'ELEC-001', 1500.00, 900.00, 50, 1),
('Bluetooth Headphones', 'Over-ear Bluetooth headphones', 'ELEC-002', 6000.00, 4200.00, 25, 1),
('Notebook A4', '200-page ruled notebook', 'STAT-001', 150.00, 80.00, 200, 3);

-- Purchase example
INSERT INTO `Purchases` (`SupplierID`, `EmployeeID`, `TotalAmount`) VALUES
(1, 1, 45000.00);

INSERT INTO `PurchaseItems` (`PurchaseID`, `ProductID`, `Quantity`, `CostPrice`) VALUES
(1, 1, 30, 900.00),
(1, 2, 4, 4200.00);

INSERT INTO `Inventory` (`ProductID`, `QuantityChange`, `ChangeType`) VALUES
(1, 30, 'Purchase'),
(2, 4, 'Purchase');

-- Sale example
INSERT INTO `Sales` (`CustomerID`, `EmployeeID`, `TotalAmount`, `PaymentType`) VALUES
(1, 2, 7500.00, 'Card');

INSERT INTO `SaleItems` (`SaleID`, `ProductID`, `Quantity`, `Price`) VALUES
(1, 1, 1, 1500.00),
(1, 2, 1, 6000.00);

INSERT INTO `Inventory` (`ProductID`, `QuantityChange`, `ChangeType`) VALUES
(1, -1, 'Sale'),
(2, -1, 'Sale');

-- Return example
INSERT INTO `Returns` (`SaleID`, `ProductID`, `Quantity`, `Reason`) VALUES
(1, 1, 1, 'Customer changed mind');

INSERT INTO `Inventory` (`ProductID`, `QuantityChange`, `ChangeType`) VALUES
(1, 1, 'Return');

-- ============================================================
-- End of Script
-- ============================================================
