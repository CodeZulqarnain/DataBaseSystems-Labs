-- ============================================================
-- Database Systems - Lab 9
-- Topic: SQL Joins (Part 2 of 2)
-- Scope: Part B (Self joins, multi-table joins, combined challenges)
-- Continued from Lab 8 (setup script + Part A)
-- Uses the Company schema created in Lab 8 (joins_lab database)
-- ============================================================

USE joins_lab;

-- ============================================================
-- PART B: Self Joins, Multi-table Joins, Combined Challenges
-- ============================================================

-- Task B1: Each employee with their manager's name (SELF JOIN)
-- Top-level managers still appear, with NULL Manager
SELECT e.EmpName AS Employee,
       m.EmpName AS Manager
FROM Employee e
LEFT JOIN Employee m ON e.ManagerID = m.EmpID;

-- Task B2: Employees who earn more than their direct manager
SELECT e.EmpName AS Employee, e.Salary AS EmpSalary,
       m.EmpName AS Manager, m.Salary AS MgrSalary
FROM Employee e
INNER JOIN Employee m ON e.ManagerID = m.EmpID
WHERE e.Salary > m.Salary;

-- Task B3: Employees whose manager works in a different department
-- Self-join Employee for the manager, then join Department twice
-- (once for the employee's dept, once for the manager's dept)
SELECT e.EmpName AS Employee,
       m.EmpName AS Manager,
       de.DeptName AS EmployeeDept,
       dm.DeptName AS ManagerDept
FROM Employee e
INNER JOIN Employee m  ON e.ManagerID = m.EmpID
INNER JOIN Department de ON e.DeptID = de.DeptID
INNER JOIN Department dm ON m.DeptID = dm.DeptID
WHERE e.DeptID != m.DeptID;

-- Task B4: Every employee with the project name they work on and hours
-- (3-table join: Employee -> Assignment -> Project)
SELECT e.EmpName, p.ProjectName, a.HoursPerWeek
FROM Employee e
JOIN Assignment a ON e.EmpID = a.EmpID
JOIN Project p ON a.ProjectID = p.ProjectID;

-- Task B5: Every assignment with employee, project, and project's department
-- (4-table join)
SELECT e.EmpName, p.ProjectName, d.DeptName, a.HoursPerWeek
FROM Assignment a
JOIN Employee e ON a.EmpID = e.EmpID
JOIN Project p ON a.ProjectID = p.ProjectID
JOIN Department d ON p.DeptID = d.DeptID;

-- Task B6: Names and weekly hours of employees on the Mobile App project
SELECT e.EmpName, a.HoursPerWeek
FROM Employee e
JOIN Assignment a ON e.EmpID = a.EmpID
JOIN Project p ON a.ProjectID = p.ProjectID
WHERE p.ProjectName = 'Mobile App';

-- Task B7: Every Lahore employee with their assigned projects
-- (include Lahore employees who have no assignments)
SELECT e.EmpName, p.ProjectName, a.HoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
LEFT JOIN Project p ON a.ProjectID = p.ProjectID
WHERE e.City = 'Lahore';

-- Task B8: Employees who work on a project run by a different department
-- than their own (compare e.DeptID and p.DeptID)
SELECT DISTINCT e.EmpName
FROM Employee e
JOIN Assignment a ON e.EmpID = a.EmpID
JOIN Project p ON a.ProjectID = p.ProjectID
WHERE e.DeptID != p.DeptID;

-- Task B9: For each department, list project names that started in 2024
-- (include departments with no such projects)
-- NOTE: the date condition is placed in the ON clause, not WHERE,
-- otherwise the LEFT JOIN would silently become an INNER JOIN
-- (see manual section 7, "subtle trap")
SELECT d.DeptName, p.ProjectName, p.StartDate
FROM Department d
LEFT JOIN Project p
       ON p.DeptID = d.DeptID
      AND YEAR(p.StartDate) = 2024;

-- Task B10: Every employee with total weekly hours across all projects
-- (include employees with zero hours)
SELECT e.EmpName, COALESCE(SUM(a.HoursPerWeek), 0) AS TotalHours
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
GROUP BY e.EmpID, e.EmpName;

-- ============================================================
-- End of Lab 9 Script
-- ============================================================
