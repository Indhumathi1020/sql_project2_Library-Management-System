# Library Management System using MySQL – Project P2

## 📚 Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: MySQL (library_db)

This project demonstrates the implementation of a **Library Management System** using **SQL (MySQL)**. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase database design, manipulation, and querying skills.

---

## 🎯 Objectives

- Set up the **Library Management System Database**: Create and populate tables for branches, employees, members, books, issued status, and return status.
- **CRUD Operations**: Perform Create, Read, Update, and Delete operations.
- **CTAS (Create Table As Select)**: Create summary tables based on query results.
- **Advanced SQL Queries**: Perform analytical and reporting queries on the data.

---

## 🗂️ Project Structure

### 1. Database Setup

**Database Creation**
```sql
CREATE DATABASE library_db;
USE library_db;
```

**Table Creation**
```sql
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

DROP TABLE IF EXISTS members;
CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);

DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

---

### 2. CRUD Operations

**Task 1: Add a New Book Record**
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

**Task 2: Update a Member's Address**
```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from Issued Status**
```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

---

### 3. CTAS (Create Table As Select)

**Task 6: Create a Summary Table of Book Issue Counts**
```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```

---

### 4. Data Analysis & Sample Queries

**Task 7: Retrieve All Books in a Specific Category**
```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Task 8: Calculate Total Rental Income by Category**
```sql
SELECT 
    b.category,
    SUM(b.rental_price) AS total_income,
    COUNT(*) AS total_issues
FROM issued_status AS ist
JOIN books AS b ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;
```

**Task 13: Identify Members with Overdue Books (30+ Days)**
```sql
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    DATEDIFF(CURDATE(), ist.issued_date) AS overdue_days
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL AND DATEDIFF(CURDATE(), ist.issued_date) > 30;
```

**Task 15: Branch Performance Report**
```sql
CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS books_issued,
    COUNT(rs.return_id) AS books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;
```

---

### 5. Stored Procedures

**Task 19: Procedure to Issue a Book & Update Status**
```sql
DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT status INTO v_status FROM books WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);

        UPDATE books SET status = 'no' WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book issued successfully: ', p_issued_book_isbn) AS message;
    ELSE
        SELECT CONCAT('Book is currently not available: ', p_issued_book_isbn) AS message;
    END IF;
END$$

DELIMITER ;
```

---

## 📊 Reports & Insights

- **Database Schema**: ERD diagrams showcasing table relationships (uploaded separately).
- **Data Analysis**: Insights into book categories, overdue books, branch performance, and employee activities.
- **Summary Reports**: High-demand books, active members, and employee performance metrics.

---

## 🚀 How to Use

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/Library-System-Management.git
    ```

2. **Set Up the Database**:
    - Run all the **SQL scripts** to create tables and insert sample data.

3. **Run Queries**:
    - Use the **analysis_queries.sql** file to execute analytical reports and stored procedures.

4. **Modify & Extend**:
    - Add more queries, procedures, and optimize reports as needed.

---

## ✅ Conclusion

This project demonstrates key SQL skills in setting up and managing a Library Management System using MySQL. It includes end-to-end database design, CRUD operations, CTAS queries, stored procedures, and analytical reporting.

---

## 📎 References

- MySQL Documentation: https://dev.mysql.com/doc/
- SQL Syntax Reference: https://www.w3schools.com/sql/