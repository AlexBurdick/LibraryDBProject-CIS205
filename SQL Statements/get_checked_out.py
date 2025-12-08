'''
DB: 		library_management
Server: 	MySQL
Address: 	127.0.0.1
Port: 		3306

SQL Stored Procedure GetCheckedOutBooks:
    SELECT b.title, r.first_name, r.last_name, due_date 
    FROM Checkout AS c
    JOIN Book AS b ON Book_idBook = idBook 
    JOIN Reader AS r ON Reader_idReader = idReader
    WHERE c.return_date IS NULL;
'''

import mysql.connector

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

# Calls a stored procedure to get checked out books
def get_checked_out_books():
    try:
        connection = get_connection()               # If this fails an exception will be thrown
        cursor = connection.cursor(dictionary=True) # Create a cursor object as dictionary, from DeepSeek (12/04/2025)
        cursor.callproc('GetCheckedOutBooks')    # Call the stored procedure
        
        for result in cursor.stored_results():      # Get results from the stored procedure call
            results = result.fetchall()
            
            if not results:                         # If there are no books checked out
                print("No books are currently checked out.")
            else:
                print("Checked out books")        # Print header
                print("="*80)
                print(f"{'TITLE':<40} {'READER':<25} {'DUE DATE':<15}")
                for row in results:
                    title = row['title']
                    borrower = f"{row['first_name']} {row['last_name']}"
                    due_date = row['due_date']
                    print(f"{title:<40} {borrower:<25} {due_date}")
                
                print(f"\nTotal books checked out: {len(results)}")

    except mysql.connector.Error as err:
        print(f'There was a problem connecting to the database {err}')
        return None
    
    # Recommended by DeepSeek (12/04/2025), this will ensure the connection is closed
    # if there is a failure anywhere in the try block, even after the connection is made
    finally:
        cursor.close()
        connection.close()

if __name__ == '__main__':
    get_checked_out_books()