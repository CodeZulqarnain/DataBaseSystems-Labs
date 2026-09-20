-- ============================================================
-- Database Systems - Lab 3
-- Topic: Database Keys, Table Commands, CRUD Operations
-- ============================================================

DROP DATABASE IF EXISTS `University_Lab3`;
CREATE DATABASE `University_Lab3`;
USE `University_Lab3`;

-- ============================================================
-- TASK 1: Create the tables with constraints
-- (Departments, Students, Courses, Instructors, Enrollments)
-- ============================================================

-- Departments Table
-- dept_id is the Primary Key (Surrogate Key - system assigned)
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) UNIQUE   -- Unique Key: no two departments share a name
);

-- Students Table
-- student_id is AUTO_INCREMENT -> Surrogate Key
-- email is UNIQUE -> Candidate Key / Alternate Key (since student_id was chosen as PK instead)
-- dept_id is a Foreign Key referencing departments
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Courses Table
-- course_id is Primary Key
-- dept_id is Foreign Key referencing departments
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Instructors Table
-- instructor_id is Primary Key
-- email is Unique -> Alternate Key
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Enrollments Table (Composite Key example)
-- Primary Key is made of (student_id, course_id) together -> Composite Key
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- ============================================================
-- TASK 2: Insert data and query using SELECT
-- ============================================================

INSERT INTO departments VALUES
(1, 'CS'),
(2, 'EE');

INSERT INTO students (name, email, age, dept_id) VALUES
('Ali', 'ali@gmail.com', 20, 1),
('Sara', 'sara@gmail.com', 21, 1),
('Ahmed', 'ahmed@gmail.com', 22, 2);

INSERT INTO courses VALUES
(101, 'Database', 1),
(102, 'AI', 1),
(201, 'Circuits', 2);

INSERT INTO instructors VALUES
(1, 'Dr. Farhan', 'farhan@gmail.com', 1),
(2, 'Dr. Nadia', 'nadia@gmail.com', 2);

INSERT INTO enrollments VALUES
(1, 101, 'Fall 2025'),
(1, 102, 'Fall 2025'),
(2, 101, 'Fall 2025');

-- Query all records from each table
SELECT * FROM departments;
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM instructors;
SELECT * FROM enrollments;

-- ============================================================
-- TASK 3: Update a student's name
-- ============================================================

UPDATE students
SET name = 'Ali Khan'
WHERE student_id = 1;

-- Verify the update
SELECT * FROM students WHERE student_id = 1;

-- ============================================================
-- TASK 4: Delete a student record
-- ============================================================

-- Note: enrollments references students via FOREIGN KEY, so we
-- remove the dependent enrollment rows first to avoid an FK error.
DELETE FROM enrollments WHERE student_id = 3;
DELETE FROM students WHERE student_id = 3;

-- Verify the delete
SELECT * FROM students;

-- ============================================================
-- TASK 5: Try TRUNCATE and DROP
-- (Demonstrated on a scratch/demo table so we don't lose our
--  actual lab data above)
-- ============================================================

CREATE TABLE demo_table (
    id INT PRIMARY KEY,
    note VARCHAR(50)
);

INSERT INTO demo_table VALUES (1, 'test row 1'), (2, 'test row 2');

SELECT * FROM demo_table;   -- shows 2 rows

TRUNCATE TABLE demo_table;  -- removes all rows, keeps table structure
SELECT * FROM demo_table;   -- now empty

DROP TABLE demo_table;      -- removes the table completely
-- SELECT * FROM demo_table;  -- would now error: table doesn't exist

-- ============================================================
-- TASK 6: Add a new column using ALTER TABLE
-- ============================================================

ALTER TABLE students
ADD phone VARCHAR(20);

-- Verify new column exists
DESCRIBE students;

-- Optional: populate the new column for existing students
UPDATE students SET phone = '03001234567' WHERE student_id = 1;
UPDATE students SET phone = '03211234567' WHERE student_id = 2;

SELECT * FROM students;

-- ============================================================
-- TASK 7: Practice joins between Students and Courses
-- (joined through the enrollments table)
-- ============================================================

-- INNER JOIN: students with the courses they are enrolled in
SELECT s.student_id, s.name, c.course_name, e.semester
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id;

-- LEFT JOIN: all students, including those with no enrollments
SELECT s.student_id, s.name, c.course_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id;

-- ============================================================
-- TASK 8: Explore candidate keys, alternate keys, composite keys
-- ============================================================

-- In the `students` table:
--   Candidate Keys : student_id, email  (either could uniquely identify a row)
--   Primary Key    : student_id (chosen candidate key, surrogate/AUTO_INCREMENT)
--   Alternate Key  : email (the candidate key NOT chosen as primary key)
--   Super Keys     : {student_id}, {email}, {student_id, name}, {student_id, email}, ...
--                     (any superset of a candidate key is a super key)

-- In the `enrollments` table:
--   Composite Key  : (student_id, course_id) together form the Primary Key,
--                     because neither column alone is unique in this table
--                     (a student can enroll in many courses, and a course
--                      can have many students).

-- Example query demonstrating the composite key in action:
SELECT student_id, course_id, semester
FROM enrollments
ORDER BY student_id, course_id;

-- ============================================================
-- End of Lab 3 Script
-- ============================================================
