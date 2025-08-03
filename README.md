**Library Management System using MySQL (Project P2)
📚 Project Overview
This project demonstrates the development of a Library Management System using MySQL. The project covers database design, CRUD operations, CTAS (Create Table As Select) queries, and advanced SQL analysis. The system manages library branches, employees, members, books, issuing/returning operations, and detailed reporting.

🎯 Objectives
Design and implement the Library Management System database schema.

Perform CRUD operations on the core entities.

Use CTAS to create summary tables.

Execute complex SQL queries for data analysis and reporting.

Demonstrate stored procedures for handling book issuance and returns.

🗂️ Project Structure
Database Setup

Database: library_db

Tables:

branch

employees

members

books

issued_status

return_status

ERD Diagram: (Uploaded separately)

CRUD Operations

Insert new books/members.

Update member addresses.

Delete issued records.

Retrieve data based on business scenarios.

CTAS Queries

Generate summary tables (e.g., issued books count, active members).

Advanced SQL Queries

Identify overdue books & fines.

Analyze branch performance.

Employee performance reports.

Member activity tracking.

Stored Procedures

Automate book issuance/return workflows.

Maintain book availability status.

🛠️ Sample MySQL Queries for Reference
1. Create Database & Tables
sql
Copy
Edit
CREATE DATABASE library_db;
USE library_db;

CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Similarly for members, books, issued_status, return_status
2. Insert Sample Book Record
sql
Copy
Edit
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
3. Update Member Address
sql
Copy
Edit
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
4. Identify Members with Overdue Books (> 30 days)
sql
Copy
Edit
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    DATEDIFF(CURDATE(), ist.issued_date) AS overdue_days
FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL
AND DATEDIFF(CURDATE(), ist.issued_date) > 30;
5. Branch Performance Summary (CTAS)
sql
Copy
Edit
CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_books_issued,
    COUNT(rs.return_id) AS number_books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
GROUP BY b.branch_id, b.manager_id;
6. Stored Procedure to Issue Book
sql
Copy
Edit
DELIMITER //

CREATE PROCEDURE issue_book (
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(50),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);
    
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;
    
    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES(p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);
        
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
        
        SELECT 'Book issued successfully' AS message;
    ELSE
        SELECT 'Book is currently unavailable' AS message;
    END IF;
END //

DELIMITER ;
7. CTAS: Overdue Books with Fine Calculation
sql
Copy
Edit
CREATE TABLE overdue_fines AS
SELECT 
    ist.issued_member_id,
    COUNT(*) AS overdue_books,
    COUNT(*) * (DATEDIFF(CURDATE(), ist.issued_date) - 30) * 0.50 AS total_fine
FROM issued_status ist
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL
AND DATEDIFF(CURDATE(), ist.issued_date) > 30
GROUP BY ist.issued_member_id;
📈 Reports Generated
Branch Performance Reports

Employee Issuance Count Reports

Overdue Books and Fines

Active Members Report

High-Demand Books

✅ Conclusion
This project demonstrates the end-to-end development of a Library Management System using MySQL, covering database setup, data operations, advanced analytics, and procedural SQL programming. It serves as a practical project to reinforce database management and querying skills.

🚀 How to Use
Clone the Repository:

bash
Copy
Edit
git clone https://github.com/najirh/Library-System-Management---P2.git
Set Up the Database:

Execute the database_setup.sql file in MySQL to create and populate the database.

Run Queries:

Use the SQL queries provided in analysis_queries.sql or your custom solution file.

Explore & Modify:

Modify queries to generate custom reports or insights as per project needs.**
