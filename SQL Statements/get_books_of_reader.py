'''
Command: mysql -u root -p < create_order_procedure1.sql
DB: 		library_management
Server: 	MySQL
Address: 	127.0.0.1
Port: 		3306

SQL Stored Procedure GetBooksOfReader:
    SELECT
        CONCAT(first_name, ' ', last_name) AS Reader,
        title AS 'Title'
    FROM checkout
    JOIN Reader ON idReader = Reader_idReader
    JOIN Book ON idBook = Book_idBook
    WHERE return_date IS NULL AND idReader = p_readerID;
'''

import mysql.connector

# Returns a connection to the classicmodels database
def get_connection() -> mysql.connector.connect:
    c = mysql.connector.connect(
        user	 = 'root',
        password = 'root',
        database = 'library_management',
        host  	 = 'localhost'
    )
    print("Connection Successful")
    return c

# Print out the books a reader has checkedout
def get_books_of_reader():
    try:
        connection = get_connection()               # If this fails an exception will be thrown
        cursor = connection.cursor(dictionary=True) # Create a cursor object as dictionary, from DeepSeek (12/04/2025)
        cursor.callproc('GetBooksOfReader')         # Call the stored procedure

        for result in cursor.stored_results():      # Get results from the stored procedure call
            results = result.fetchall()
            
            if not results:                         # If there are no books checked out
                print("No books are currently checked out.")
            else:
                print("Checked out books\n")        # Print header
                print("="*80)
                print(f"{'Title':<40} {'Reader':<25}")
                for row in results:
                    title = row['Title']
                    borrower = f"{row['Reader']}"
                    print(f"{title:<40} {borrower:<25}")
                
                print(f"\nTotal books checked out: {len(results)}")

    
    except mysql.connector.Error as err:
        print(f'There was a problem connecting to the database {err}')
        return None
    
    finally:
        cursor.close()
        connection.close()

if __name__ == '__main__':
    get_books_of_reader()