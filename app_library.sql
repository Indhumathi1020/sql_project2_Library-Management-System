-- Library System Management SQL Project

-- CREATE DATABASE library;

-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
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



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


-- Project TASK


-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books (isbn, book_title, category, rental_price, status, author, publisher)
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

update members
set member_address = '234 Short St'
where member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

delete from issued_status
where issued_id = 'IS107';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT issued_book_name
FROM issued_status 
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_member_id, count(issued_id) as books_issued from issued_status
group by issued_member_id
having books_issued > 1;

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

create table book_count
as
select b.isbn, b.book_title, count(i.issued_id) from books b
join issued_status i on issued_book_isbn = isbn
group by b.isbn, b.book_title;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

Select * from books
where category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

select b.category, sum(b.rental_price) from books b
join issued_status i on issued_book_isbn = isbn
group by b.category;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT member_id, reg_date from members
where reg_date < DATE_SUB("2025-07-27", INTERVAL 180 DAY);

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT e1.*, b.manager_id, e2.emp_name as manager
FROM employees as e1
JOIN  branch as b ON b.branch_id = e1.branch_id
JOIN employees as e2 ON b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

create table book_over_7 as 
Select * from books
where rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned

select i.issued_book_name from issued_status i
join return_status r on i.issued_id = r.issued_id
where r.return_id is null;
    

-- ### Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books
--- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

select m.member_name, bk.book_title, ist.issued_date, current_date() - ist.issued_date as overdue_days from issued_status as ist
join members as m on ist.issued_member_id = m.member_id
join books as bk on bk.isbn = ist.issued_book_isbn
left join return_status as rs on rs.issued_id = ist.issued_id
where rs.return_date is not null;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).
--using stored procedure

DELIMITER ;

-- View current books
SELECT * FROM books;

-- Issue Book Test 1 (Available Book)
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

-- Issue Book Test 2 (Unavailable Book)
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

-- Check the books table after issuing
SELECT * FROM books WHERE isbn = '978-0-375-41398-8';
--or--
with status_update as (
select bk.book_title, ist.issued_date, rs.return_date from issued_status as ist
join books as bk on bk.isbn = ist.issued_book_isbn
left join return_status as rs on rs.issued_id = ist.issued_id
where rs.return_date is not null)
update status_update
set status = 'No';

UPDATE issued_status AS ist
JOIN return_status AS rs ON rs.issued_id = ist.issued_id
SET ist.status = 'No'
WHERE rs.return_date IS NOT NULL;

select * from return_status;

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

create table branch_performance (select b.branch_id, count(ist.issued_id), count(r.return_id), sum(bk.rental_price) from branch as b
join employees as e on b.branch_id = e.branch_id
join issued_status as ist on e.emp_id = ist.issued_emp_id
left join return_status as r on ist.issued_id = r.issued_id
join books as bk on ist.issued_book_isbn = bk.isbn
group by b.branch_id);

select * from branch_performance;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table, active_members, containing members who have issued at least one book in the last 6 months.

select distinct(m.member_id) from members as m
join issued_status as ist on m.member_id = ist.issued_member_id
where ist.issued_date > DATE_SUB("2024-07-31", INTERVAL 60 DAY);

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select e.emp_name, count(ist.issued_id), b.branch_id from branch as b
join employees as e on b.branch_id = e.branch_id
join issued_status as ist on e.emp_id = ist.issued_emp_id
join books as bk on ist.issued_book_isbn = bk.isbn
group by e.emp_name, b.branch_id
order by count(ist.issued_id) desc
limit 3;


-- Task 18: Identify Members Who Have Issued the Same Book More Than Once
-- Write a query to identify members who have issued the same book title more than once, regardless of the book's status. Display the member ID, book title, and the number of times they've issued that book.

select ist.issued_member_id, ist.issued_book_name, count(ist.issued_id) as no_of_times from issued_status as ist
join books as bk on ist.issued_book_isbn = bk.isbn
group by ist.issued_member_id, ist.issued_book_name
having no_of_times > 1;

-- Task 19: Stored Procedure
-- Objective: Create a stored procedure to manage the status of books in a library system.
  --  Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
   -- If a book is issued, the status should change to 'no'.
   -- If a book is returned, the status should change to 'yes'.

DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Get the status of the book
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    -- If the book is available, issue it
    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE(), p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book records added successfully for book isbn: ', p_issued_book_isbn) AS message;
    ELSE
        SELECT CONCAT('Sorry, the book is unavailable. book_isbn: ', p_issued_book_isbn) AS message;
    END IF;
END //

-- Task 20: Create Table As Select (CTAS)
--Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
--    The number of overdue books.
  --  The total fines, with each day's fine calculated at $0.50.
 --   The number of books issued by each member.
  --  The resulting table should show:
 --   Member ID
 --   Number of overdue books
  --  Total fines 

            create table fine as (select m.member_id, rs.return_date - ist.issued_date as no_of_return_days, 
current_date() - ist.issued_date as overdue_days, (rs.return_date - ist.issued_date - 30) * 0.30 AS total_fine
from issued_status as ist
join members as m on ist.issued_member_id = m.member_id
left join return_status as rs on rs.issued_id = ist.issued_id
where rs.return_date is not null
having no_of_return_days > 30) ;

select * from fine;
