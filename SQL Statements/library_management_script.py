'''
Command: mysql -u root -p < create_order_procedure1.sql
DB: 		library_management
Server: 	MySQL
Address: 	127.0.0.1
Port: 		3306
'''
import mysql.connector	# module to allow us to talk to MySQL
import datetime			# module to get the current date and do date math

'''
returns a connection to the classicmodels database
'''
def get_connection() -> mysql.connector.connect:
    try:
        c = mysql.connector.connect(
            user	 = 'root',
            password = 'root',
            database = 'library_management',
            host  	 = 'localhost'
        )
        print("Connection Successful")
        return c
    except mysql.connector.Error as err:
        print(f'There was a problem connecting to the database {err}')
        return None

# Get customers who have a book overdue with contact info
def process_order(custID: int) -> int:
    
    current_date	= datetime.date.today()					# get today's date
    required_date	= current_date + datetime.timedelta(10)	# required date is 10 days from now
    comments		= ask_for_comments()					# get comments from user
    
    con = get_connection()									# get a connection object
    cur = con.cursor()										# get a cursor object to execute queries	

    # calls stored procedure create_order
    args = (current_date, required_date, comments, custID)	# package arguments for stored procedure
    cur.callproc('create_order', args)						# call the stored procedure to create the order
    con.commit()											# commit the transaction
    
    # execute some explicit SQL to get the last order number created
    sql = "SELECT MAX(orderNumber) FROM orders;"			# get the last order number created
    cur.execute(sql)										# execute the query
    orderID = cur.fetchone()[0]								# fetch the order number
    con.close()												# close the connection			

    return orderID

def ask_for_comments() -> str:
    comments = input("What comments do you have for this order? ")
    return comments

# add order details for a given order  number and shopping cart
def add_order_details(orderID: int, cart: list) -> None:
    con = get_connection()					# get a connecti on object
    cur = con.cursor()						# get a cursor object to execute queries	

    order_details = []	# list to hold the order details to be inserted
    
    line_number = 1
    for item in cart:
        product_code = item[0]
        quantity = item[1]
        price = item[2]
        
        sql_row = (orderID, product_code, quantity, price, line_number)
        line_number += 1
        order_details.append( sql_row )
    
    sql =	"INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) " \
            "VALUES (%s, %s, %s, %s, %s);"
    
    cur.executemany(sql, order_details)
    
    con.commit()                # commit the transaction
    con.close()                 # close the connection

if __name__ == '__main__':
    # mock shopping cart, just for testing purposes
    shopping_cart = [			# list of tuples
        ('S10_4698', 2, 75),	# tuple of product_code, quantity ordered, price each
        ('S12_4473', 4, 100),
        ('S10_1678', 3, 90),
        ('S12_3148', 2, 67)
    ]

    # existing customer number, just for testing purposes
    customer = 475													# random customer ID
    id = process_order(customer)									# create an order and get the new orderID
    print(f'Order {id} has been created for customer {customer}.')	# print the results
    add_order_details(id, shopping_cart)							# add the order details with the new ID
    print(f'Order details for order {id} have been added.')