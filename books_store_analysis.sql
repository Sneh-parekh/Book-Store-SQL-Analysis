CREATE DATABASE book_store_analysis;
USE book_store_analysis;

CREATE TABLE Books (
    Book_ID INT PRIMARY KEY,
    Title VARCHAR(150),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price DECIMAL(10,2),
    Stock INT
);

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    City VARCHAR(50),
    Country VARCHAR(50)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Book_ID INT,
    Order_Date DATE,
    Quantity INT,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);



CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Book_ID INT,
    Order_Date DATE,
    Quantity INT,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Book_ID INT,
    Order_Date DATE,
    Quantity INT,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Books.csv'
INTO TABLE Books
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Book_ID, Title, Author, Genre, Published_Year, Price, Stock);

ALTER TABLE Customers
MODIFY Country VARCHAR(100);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_ID, Name, Email, Phone, City, Country);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Customer_ID, Book_ID, @order_date, Quantity, Total_Amount)
SET Order_Date = STR_TO_DATE(@order_date, '%d-%m-%Y');

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

-- (1). List book titles along with their prices
SELECT Title, Price
FROM Books;

-- (2). Find all books priced above 40
SELECT Title, Price
FROM Books
WHERE Price > 40;

-- (3). Retrieve customers who live in the same city as at least one other customer
SELECT City, COUNT(*) AS Customer_Count
FROM Customers
GROUP BY City
HAVING COUNT(*) > 1;

-- (4). Show books published after the year 2000
SELECT Title, Published_Year
FROM Books
WHERE Published_Year > 2000;

-- (5). Show orders placed in the year 2022
SELECT Order_ID, Order_Date
FROM Orders
WHERE YEAR(Order_Date) = 2022;

-- (6). Find total number of books per genre
SELECT Genre, COUNT(*) AS Total_Books
FROM Books
GROUP BY Genre;

-- (7). Identify books that are currently out of stock or low stock (<=5)
SELECT Title, Stock
FROM Books
WHERE Stock <= 5;

-- (8). Calculate average order value
SELECT AVG(Total_Amount) AS Avg_Order_Value
FROM Orders;

-- (9). Retrieve orders where more than 2 items were purchased
SELECT Order_ID, Quantity
FROM Orders
WHERE Quantity > 2;

-- (10). Count how many orders each customer has placed
SELECT Customer_ID, COUNT(Order_ID) AS Order_Count
FROM Orders
GROUP BY Customer_ID;

-- (11). Display total number of books in stock
SELECT SUM(Stock) AS Total_Stock
FROM Books;

-- (12). Retrieve the minimum and maximum book price
SELECT MIN(Price) AS Min_Price, MAX(Price) AS Max_Price
FROM Books;

-- (13). Display total revenue generated from all orders
SELECT SUM(Total_Amount) AS Total_Revenue
FROM Orders;

-- (14). Find the book with the lowest stock:
SELECT * FROM Books 
ORDER BY stock 
LIMIT 3;

-- (15). Identify customers from countries other than USA
SELECT Name, Country
FROM Customers
WHERE Country <> 'USA';

-- (16). Count total number of customers
SELECT COUNT(*) AS Total_Customers
FROM Customers;

-- Advance Questions : 

-- (1). Identify top 5 customers by total spending
SELECT c.Name, SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Name
ORDER BY Total_Spent DESC
LIMIT 5;

-- (2). Retrieve total quantity of books sold for each genre
SELECT b.Genre, SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre;

-- (3). Calculate total revenue generated per genre
SELECT b.Genre, SUM(o.Total_Amount) AS Genre_Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre;

-- (4). Identify customers who have never placed an order
SELECT c.Name
FROM Customers c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_ID IS NULL;

-- (5). Find the most frequently ordered book
SELECT b.Title, SUM(o.Quantity) AS Total_Ordered
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Title
ORDER BY Total_Ordered DESC
LIMIT 1;

-- (6). List cities where customers spent more than 100 in total
SELECT c.City, SUM(o.Total_Amount) AS City_Spending
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.City
HAVING SUM(o.Total_Amount) > 100;

-- (7). Calculate remaining stock for each book after orders
SELECT 
    b.Title,
    b.Stock - IFNULL(SUM(o.Quantity), 0) AS Remaining_Stock
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Title, b.Stock;

-- (8). Find monthly revenue trend
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Order_Month,
    SUM(Total_Amount) AS Monthly_Revenue
FROM Orders
GROUP BY Order_Month
ORDER BY Order_Month;

-- (9). Identify authors whose books generated more than $50 in revenue
SELECT b.Author, SUM(o.Total_Amount) AS Author_Revenue
FROM Books b
JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Author
HAVING SUM(o.Total_Amount) > 50;

-- (10). Determine inventory shortage risk (stock < total sold)
SELECT b.Title, b.Stock, IFNULL(SUM(o.Quantity),0) AS Total_Sold
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Title, b.Stock
HAVING b.Stock < Total_Sold;

-- (11). Identify repeat customers using window function
SELECT DISTINCT Name
FROM (
    SELECT c.Name,
           COUNT(o.Order_ID) OVER (PARTITION BY c.Customer_ID) AS Order_Count
    FROM Customers c
    JOIN Orders o ON c.Customer_ID = o.Customer_ID
) customer_orders
WHERE Order_Count > 1;

