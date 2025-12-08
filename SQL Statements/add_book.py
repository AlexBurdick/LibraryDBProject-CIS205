'''
Command: mysql -u root -p < create_order_procedure1.sql

Adds a new book to the database, the details of which are in the insert statements below.

SQL Stored Procedure AddBook:
    INSERT INTO Book (employeeID, Reading_Level_idReading_Level, Section_idSection, title, publication_date, introduce_date, language, genre)
    VALUES (1, 3, 6, 'The Great Gatsby', '1925-04-10', CURRENT_DATE(), 'English', 'Classic');

Also needs to make use of AddAuthor:
    INSERT INTO Author (first_name, last_name, birth_date, death_date)
    VALUES ('F. Scott', 'Fitzgerald', '1896-09-24', '1940-12-21')

And AddBookHasAuthor:
    INSERT INTO book_has_author (Book_idBook, Author_idAuthor)
    VALUES (p_Book_idBook, p_Author_idAuthor);
'''

import mysql.connector
import datetime

# Returns a connection to the classicmodels database
def get_connection() -> mysql.connector.connect:
    c = mysql.connector.connect(
        user	 = 'test_user',
        password = 'test_password123',
        database = 'library_management',
        host  	 = 'localhost'
    )
    print("Connection Successful")
    return c

def add_book(book, author):
    try:
        connection = get_connection()               # If this fails an exception will be thrown
        cursor = connection.cursor(dictionary=True) # Create a cursor object as dictionary, from DeepSeek (12/04/2025)
        book_id = None                              # Store the book ID for intersection table
        author_id = None                            # Store the author ID for intersection table

        # Insert book
        cursor.callproc('AddBook', book)            # Call the stored procedure
        for result in cursor.stored_results():
            row = result.fetchone()
            if row:
                print(row['message'])
                book_id = row['id']
        cursor.fetchall()                           # Clear any remaining results
        
        # Now insert author
        cursor.callproc('AddAuthor', author)
        for result in cursor.stored_results():
            row = result.fetchone()
            if row:
                print(row['message'])
                author_id = row['id']
        cursor.fetchall()

        # Debugging code from DeepSeek (12/06/2025)
        # In your add_book function, add this before calling AddBookHasAuthor:
        print(f"DEBUG: Book ID = {book_id}, Author ID = {author_id}")
        print(f"DEBUG: Checking if relationship exists...")

        cursor.execute("SELECT * FROM book_has_author WHERE Book_idBook = %s AND Author_idAuthor = %s", 
                    (book_id, author_id))
        result = cursor.fetchone()
        print(f"DEBUG: Existing relationship found: {result}")

        cursor.execute("SELECT MAX(Book_idBook) as max_book, MAX(Author_idAuthor) as max_author FROM book_has_author")
        max_ids = cursor.fetchone()
        print(f"DEBUG: Max IDs in table: {max_ids}")

        # Add row to the instersection table
        book_author = [book_id, author_id]
        cursor.callproc('AddBookHasAuthor', book_author)

        if book_id and author_id:
            book_author = [book_id, author_id]
            connection.commit()
            cursor.callproc('AddBookHasAuthor', book_author)
            
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    print(f"Book-Author relationship created: idBook = {book_id}, idAuthor = {author_id}")
    
        connection.commit()

    except mysql.connector.Error as err:
        print(f'There was a problem connecting to the database {err}')
        return None
    
    finally:
        cursor.close()
        connection.close()


if __name__ == '__main__':
    current_date = datetime.date.today()
    book = [1, 3, 6, 'The Great Gatsby', '1925-04-10', current_date, 'English', 'Classic']
    author = ['F. Scott', 'Fitzgerald', '1896-09-24', '1940-12-21']
    add_book(book, author)