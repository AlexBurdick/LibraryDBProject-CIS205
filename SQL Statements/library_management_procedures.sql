-- SQL DIALECT: MySQL
-- Editor hint: this file contains MySQL-specific syntax (DELIMITER, IN/OUT parameters)
-- Returns all books that are currently checked out
DELIMITER //
CREATE PROCEDURE GetCheckedOutBooks()
BEGIN
    SELECT b.title, r.first_name, r.last_name, due_date 
    FROM Checkout AS c
    JOIN Book AS b ON Book_idBook = idBook 
    JOIN Reader AS r ON Reader_idReader = idReader
    WHERE c.return_date IS NULL;
END //
DELIMITER ;

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
CREATE PROCEDURE EmployeeBookAdded(
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
CREATE PROCEDURE GetBooksOfReader(
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
CREATE PROCEDURE GetSectionsOfAuthor(
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

-- Add book to collection
DELIMITER //
CREATE PROCEDURE AddBook(
    IN p_employeeID INT,
    IN p_Reading_Level_idReading_Level INT,
    IN p_Section_idSection INT,
    IN p_title VARCHAR(200),
    IN p_publication_date DATE,
    IN p_introduce_date DATE,
    IN p_language VARCHAR(50),
    IN p_genre VARCHAR(50)
)
BEGIN
    INSERT INTO Book (
        employeeID, 
        Reading_Level_idReading_Level, 
        Section_idSection, 
        title, 
        publication_date, 
        introduce_date, 
        language, 
        genre
    )
    VALUES (
        p_employeeID,
        p_Reading_Level_idReading_Level,
        p_Section_idSection,
        p_title,
        p_publication_date,
        p_introduce_date,
        p_language,
        p_genre
    );
    
    -- Return success message and new ID
    SELECT 
        CONCAT('Book "', p_title, '" added successfully') AS message,
        LAST_INSERT_ID() AS id;
END //
DELIMITER ;

-- Add Author
DELIMITER //
CREATE PROCEDURE AddAuthor(
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_birth_date DATE,
    IN p_death_date DATE
)
BEGIN
    INSERT INTO Author (first_name, last_name, birth_date, death_date)
    VALUES (p_first_name, p_last_name, p_birth_date, p_death_date);
    
    SELECT 
        CONCAT('Author "', p_first_name, ' ', p_last_name, '" added successfully') AS message,
        LAST_INSERT_ID() AS id;
END //
DELIMITER ;

-- Add book and author to intersection table
DELIMITER //
CREATE PROCEDURE AddBookHasAuthor(
    IN p_Book_idBook INT,
    IN p_Author_idAuthor INT
)
BEGIN
    INSERT INTO book_has_author (Book_idBook, Author_idAuthor)
    VALUES (p_Book_idBook, p_Author_idAuthor);

    SELECT * FROM book_has_author
    WHERE Book_idBook = p_Book_idBook AND Author_idAuthor = p_Author_idAuthor;
END //
DELIMITER ;


-- Example of calling a procedure fom Python script
call get_customer_order_history(112, @orders, @spent);
SELECT @Orders, @spent;

-- Testing statements
SET @max_book_id = (SELECT MAX(idBook) FROM book);						-- Step 1: Find the max book and author IDs
SET @max_author_id = (SELECT MAX(idAuthor) FROM author);
DELETE FROM book_has_author												-- Step 2: Delete from intersection table
WHERE Book_idBook = @max_book_id AND Author_idAuthor = @max_author_id;
DELETE FROM author WHERE idAuthor = @max_author_id;						-- Step 3: Delete from author table
DELETE FROM book WHERE idBook = @max_book_id;							-- Step 4: Delete from book tabl

select * from book_has_author order by Book_idBook desc;
select * from book order by idBook desc;
select * from author order by idAuthor desc;

CALL AddBook(1, 3, 6, 'The Great Gatsby', '1925-04-10', '2025-12-06', 'English', 'Classic');
CALL AddAuthor('F. Scott', 'Fitzgerald', '1896-09-24', '1940-12-21');
CALL AddBookHasAuthor(113, 92);