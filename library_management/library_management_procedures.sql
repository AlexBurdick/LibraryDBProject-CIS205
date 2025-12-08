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