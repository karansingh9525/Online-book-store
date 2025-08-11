-- Create Database
CREATE DATABASE OnlineBookstore;

-- Switch to the database
\c OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

/*
-- Import Data into Books Table
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock) 
FROM 'D:\Course Updates\30 Day Series\SQL\CSV\Books.csv' 
CSV HEADER;

-- Import Data into Customers Table
COPY Customers(Customer_ID, Name, Email, Phone, City, Country) 
FROM 'D:\Course Updates\30 Day Series\SQL\CSV\Customers.csv' 
CSV HEADER;

-- Import Data into Orders Table
COPY Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount) 
FROM 'D:\Course Updates\30 Day Series\SQL\CSV\Orders.csv' 
CSV HEADER;

*/

-- 1) Retrieve all books in the "Fiction" genre:
SELECT * FROM Books
WHERE Genre='Fiction';
-- 2) Find books published after the year 1950:
SELECT * FROM Books
WHERE published_year>=1950;

-- 3) List all customers from the Canada:
SELECT * FROM Customers
Where country='Canada'; -- no customer

-- 4) Show orders placed in November 2023:
SELECT * FROM Orders
Where order_date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:
SELECT SUM(stock) as total_stock
FROM Books;

-- 6) Find the details of the most expensive book:
SELECT * FROM Books ORDER BY price DESC 
LIMIT 1;
--pahle dec. order me kiya fir upper wala ek return kar diya

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT * FROM Orders
WHERE quantity>1;
-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT * FROM Orders
WHERE Total_Amount>20;

-- 9) List all genres available in the Books table:
select distinct genre
from Books;

-- 10) Find the book with the lowest stock:
Select * from Books order by stock asc
limit 1

-- 11) Calculate the total revenue generated from all orders:
select sum(Total_Amount) as revenue
from Orders;
-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:
     -- quantity Orders me hai or genre Books
select b.genre , sum(o.Quantity) as totsl_b_sold from Orders o join Books b 
ON o.book_id=b.book_id -- condition on which order & book is joining 
GROUP BY genre; --genere by grouping ho raha hai...

-- 2) Find the average price of books in the "Fantasy" genre:
select avg(price) as avg_price_fantasy from Books
where genre='Fantasy';


-- 3) List customers who have placed at least 2 orders:
     --without customer name
select customer_id,count(Order_id) as order_count
from Orders
group by customer_id 
having count(Order_id)>=2;
    -- with customer name
select o.customer_id, c.Name, count(o.Order_id) as order_count
from Orders o join Customers c ON o.customer_id=c.customer_id
group by o.customer_id ,c.Name
having count(o.Order_id)>=2;
/*
HAVING use karenege jab aggregate formula ke upper condition ho
WHERE jab column ke upper condition ho
*/
-- 4) Find the most frequently ordered book:
SELECT Book_id,count(order_id) as order_count
from Orders
group by book_id
order by order_count desc limit 1;

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :
SELECT * FROM Books 
where genre='Fantasy'
order by price desc limit 3;


-- 6) Retrieve the total quantity of books sold by each author:
select b.author, sum(o.quantity) as total_book_sold
from Orders o join Books b
on o.book_id=b.book_id
group by b.author;

-- 7) List the cities where customers who spent over $30 are located:
select distinct c.city , o.total_amount 
from Orders o join Customers c
on o.customer_id=c.customer_id
where o.total_amount>30;

-- 8) Find the customer who spent the most on orders:
select c.name , sum(o.total_amount) as total_spent
from Orders o join Customers c 
on o.customer_id=c.customer_id
group by c.name
order by total_spent  desc limit 1;

--9) Calculate the stock remaining after fulfilling all orders:  imp***
   --(stock - quantity) karna hai har Row me
SELECT * FROM Books;
SELECT * FROM Orders;
  -- isme left join use hoga kyki table 1(books) ka sara lena hai table 2(ordrs)
  -- minus karke or agar table 2(orders) me quntity nahi hai to pura ka pura stock wala
  -- value aa jayega --- isiliye LEFT JOIN use karenge
select b.book_id,b.title, b.stock,coalesce(sum(o.quantity),0) as order_quantity,
        b.stock-coalesce(sum(o.quantity),0) as remaining_quantity
from Orders o left join Books b
on o.book_id=b.book_id
group by b.book_id order by b.book_id;

   /*   wrong sol_n
   select b.stock,o.quantity,b.stock-o.quantity as remening
   from Orders o join Books b
   on o.book_id=b.book_id
   */
