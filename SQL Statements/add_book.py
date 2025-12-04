'''
Command: mysql -u root -p < create_order_procedure1.sql

Adds a new book to the database, the details of which are in the insert statements below.

SQL Stored Procedure AddBook:
    INSERT INTO Book (employeeID, Reading_Level_idReading_Level, Section_idSection, title, publication_date, introduce_date, language, genre)
    VALUES (1, 3, 6, 'The Great Gatsby', '1925-04-10', CURRENT_DATE(), English, 'Classic');

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
        
        # Insert book
        cursor.callproc('AddBook', book)            # Call the stored procedure

        # Now insert author
        cursor.callproc('AddAuthor', author)

        # Last insert book_has_author
        book_author = []
        messages = []
        for result in cursor.stored_results():
            row = result.fetchone()
            book_author.append(row[1])
            message.append[row]
        cursor.callproc('AddBookHasAuthor', book_author)
        return messages
    
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
    messages = add_book(book, author)
    for message in messages:
        print(message)