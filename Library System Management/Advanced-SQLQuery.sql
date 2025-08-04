--                                                    Library Management System

-- selecting the databse
use library_management

-- Advanced SQL Operations

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.*/

select m.member_id,
		member_name,
		issued_book_name,
		issued_date,
		DATEDIFF(d,issued_date,getdate()) as 'days_overdue'
from members m
inner join issued_status i
on m.member_id=i.issued_member_id
where i.issued_id not in (select distinct issued_id from return_status)
and DATEDIFF(d,issued_date,getdate())>30
order by 4 desc

/* Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals. */

select branch_id,
		COUNT(istat.issued_id) as 'Issued_Book_Count',
		count(return_id) as 'Return_Book_Count',
		sum(rental_price) as 'Total_Revenue'
from employees e
inner join issued_status istat
on e.emp_id=istat.issued_emp_id
inner join books b
on istat.issued_book_isbn=b.isbn
left join return_status rs
on b.isbn=rs.return_book_isbn
group by branch_id


/* Task 15: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 6 months. */

select member_id
into active_members
from members m
inner join issued_status ista
on m.member_id=ista.issued_member_id
where DATEDIFF(M,issued_date,GETDATE())<=6
group by m.member_id
having count(issued_id)>1

select * from active_members

/* Task 16: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch. */

select top 3 e.emp_id,
		e.emp_name,
		count(*) as 'Count_of_book_processed',
		branch_id
from employees e
inner join issued_status istat
on e.emp_id=istat.issued_emp_id
group by e.emp_id,e.emp_name,branch_id
order by 3 desc

/* Task 17: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines */

with overdue_books as (select istat.issued_member_id,
		count(*) as 'over_due_books',
		sum(rental_price) as 'rental_price_of_book',
		sum(DATEDIFF(d,issued_date,GETDATE())) as 'overdue_days'
from members m
inner join issued_status istat
on m.member_id=istat.issued_member_id
inner join books b
on istat.issued_book_isbn=b.isbn
where issued_id not in (select issued_id from return_status) and
DATEDIFF(d,issued_date,GETDATE())>30
group by istat.issued_member_id)

select issued_member_id as 'member_id',
		count(over_due_books) as 'over_due_books_count',
		sum(rental_price_of_book)+(sum(overdue_days)*0.5) as 'Total_fine'
into overdue_books_fine
from overdue_books
group by issued_member_id
order by 3 desc

select * from overdue_books_fine

--_____________________________________________________________________________________________________________________________