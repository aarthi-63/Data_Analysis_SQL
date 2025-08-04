--                                                     Library Management System

-- creating the database
create database library_management

-- selecting database
use library_management

-- creating table

--TABLE : branch

create table  branch(
branch_id nvarchar(10) primary key,
manager_id nvarchar(10),
branch_address nvarchar(30),
contact_no nvarchar(15)
)

-- TABLE : books

create table books(
isbn nvarchar(50) primary key,
book_title nvarchar(80),
category nvarchar(30),
rental_price float,
status nvarchar(10),
author nvarchar(30),
publisher nvarchar(30)
)

-- TABLE : members

create table members(
member_id nvarchar(10) primary key,
member_name nvarchar(30),
member_address nvarchar(30),
reg_date date
)

-- TABLE : return_status

create table return_status(
return_id nvarchar(10) primary key,
issued_id nvarchar(30),
return_date date,
return_book_isbn nvarchar(50),
foreign key(return_book_isbn) references books(isbn)
)

-- TABLE : employees

create table employees(
emp_id nvarchar(10) primary key,
emp_name nvarchar(30),
position nvarchar(30),
salary float,
branch_id nvarchar(10),
foreign key(branch_id) references branch(branch_id)
)

-- TABLE : issued_status

create table issued_status(
issued_id nvarchar(10) primary key,
issued_member_id nvarchar(10),
issued_book_name nvarchar(80),
issued_date date,
issued_book_isbn nvarchar(50),
issued_emp_id nvarchar(10),
foreign key(issued_member_id) references members(member_id),
foreign key(issued_book_isbn) references books(isbn),
foreign key(issued_emp_id) references employees(emp_id)
)

