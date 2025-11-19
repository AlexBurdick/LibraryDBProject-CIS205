-- SQL DIALECT: MySQL
-- Editor hint: this file contains MySQL-specific syntax (DELIMITER, IN/OUT parameters)
-- Returns all books that are currently checked out
SELECT b.title, r.first_name, r.last_name, due_date 
FROM Checkout AS c
JOIN Book AS b ON Book_idBook = idBook 
JOIN Reader AS r ON Reader_idReader = idReader
WHERE c.return_date IS NULL;

-- Returns all books added in the last year
SELECT
	title AS 'Title', 
	CONCAT(first_name, ' ', last_name) AS 'Name',
	publication_date AS 'Publication Date'
FROM Book
JOIN Book_has_Author ON Book_idBook = idBook
JOIN Author ON Author_idAuthor = idAuthor
WHERE publication_date 
	BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE();

-- Returns all books at a certain reading level
DELIMITER $$
CREATE PROCEDURE SelectBooksOfReadingLevel(
    IN p_ReadingLevel VARCHAR(45)
)
BEGIN
    SELECT title FROM Book
    WHERE reading_level = p_ReadingLevel;
END$$
DELIMITER ;

-- Returns all books available (title, author, section)
SELECT
    b.title AS Title,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS Authors,
    s.name AS Section
FROM Book b
JOIN Book_has_Author ba ON b.idBook = ba.Book_idBook
JOIN Author a ON a.idAuthor = ba.Author_idAuthor
JOIN Section s ON s.idSection = b.Section_idSection
LEFT JOIN Checkout c 
    ON b.idBook = c.Book_idBook 
    AND c.return_date IS NULL
WHERE c.Book_idBook IS NULL
GROUP BY b.idBook, b.title, s.name;

-- Return employees who added a book (and book information)
DELIMITER $$
CREATE PROCEDURE SelectBooksOfReadingLevel(
IN p_employeeID INT
)
BEGIN
	SELECT CONCAT(first_name, ' ', last_name) AS 'Employee', title AS 'Title'
	FROM book
	JOIN employee ON employeeID = idEmployee
	WHERE employeeID = p_employeeID;
END$$
DELIMITER ;

-- Return customers who have a book overdue with contact info
SELECT DISTINCT first_name, last_name, phone, email
FROM reader
JOIN checkout ON idReader = Reader_idReader
WHERE return_date IS NULL AND due_date < CURDATE();

-- Return how much longer a reader gets to have a book
SELECT
    CONCAT(first_name, ' ', last_name) AS Reader,
    title AS Title,
    due_date AS 'Due Date',
    DATEDIFF(due_date, CURDATE()) AS 'Days until/past due'
FROM Checkout
JOIN Reader ON idReader = Reader_idReader
JOIN Book ON idBook = Book_idBook
WHERE return_date IS NULL;

-- Return what a reader has checked out
DELIMITER $$
CREATE PROCEDURE SelectBooksOfReadingLevel(
IN p_readerID INT
)
BEGIN
	SELECT
		CONCAT(first_name, ' ', last_name) AS Reader,
		title AS 'Title'
FROM checkout
JOIN Reader ON idReader = Reader_idReader
JOIN Book ON idBook = Book_idBook
WHERE return_date IS NULL AND idReader = p_readerID;
END$$
DELIMITER ;

-- Return the sections an author has books in
DELIMITER $$
CREATE PROCEDURE SelectBooksOfReadingLevel(
IN p_authorID INT
)
BEGIN
SELECT
	GROUP_CONCAT(CONCAT(first_name, ' ', last_name) SEPARATOR ', ') AS 'Authors',
	name AS 'Section', 
    	title AS 'Title'
FROM section
JOIN book ON idSection = Section_idSection
JOIN book_has_author ON idBook = Book_idBook
JOIN author ON idAuthor = Author_idAuthor
WHERE p_authorID = idAuthor
GROUP BY title, name
ORDER BY name;
END$$
DELIMITER ;

-- Get the reader ID from a phone number
DELIMITER $$
CREATE PROCEDURE getReaderID(
	IN p_phone_number INT
    OUT readerID
)
BEGIN
	
END$$
DELIMITER ;


-- Example procedure from Ken
CREATE PROCEDURE `get_customer_order_history`(
    IN customerID INT,
    OUT total_orders INT,
    OUT money_spent DECIMAL(10, 2)
)
BEGIN
    -- Get the order count
    SELECT COUNT(orderNumber) 
    INTO total_orders
    FROM orders
    WHERE customerNumber = customerID;
    
    -- Calculate the total money spent
    SELECT SUM(amount)
    INTO money_spent
    FROM payments
    WHERE customerNumber = customerID;
    
    -- Return a detailed order list
    SELECT
    o.orderNumber,
        o.orderDate,
        o.status,
        SUM(od.quantityOrdered * od.priceEach) AS OrderTotal
    FROM orders AS o
    INNER JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
    WHERE customerNumber = customerID
    GROUP BY o.orderNumber
    ORDER BY o.orderDate DESC;
    
END

-- Example of calling a procedure fom Python script
call get_customer_order_history(112, @orders, @spent);
SELECT @Orders, @spent;