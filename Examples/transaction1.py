'''
	Command: mysql -u root -p < create_order_procedure1.sql
	
	This demonstrates recording a multi-step transaction to a MySQL database.
	This transaction requires 3 tables to be updated. To maintain ACID compliance
	we only commit changes when the entire transction is complete. If any stage 
	fails, the entire transaction needs to fail.

	https://www.essentialsql.com/sql-acid-database-properties-explained/

	DB: 		Classic Models
	Server: 	MySQL
	Address: 	127.0.0.1
	Port: 		3306

	Various techniques are demonstrated. Connections are created and closed on an "as needed" basis
	and not left to persist.
	Also demonstrates passing MySQL Cursor objects as arguments to functions
'''
import mysql.connector	# module to allow us to talk to MySQL
import datetime			# module to get the current date and do date math

def get_connection() -> mysql.connector.connect:
	'''
		returns a connection to the classicmodels database
	'''
	try:
		c = mysql.connector.connect(
				user	 = 'root',			# change this to work with other users
				password = 'root',			# change password
				database = 'classicmodels',	# database name
				host  	 = 'localhost'		# address of MySQL student. Default port 3306
			)
		print("Connection Successful")
		return c
	except mysql.connector.Error as err:	# if you make it here, there was a problem
		print(f'There was a problem connecting to the database {err}')
		return None							# nothing to return because connection failed
	
def process_order(custID: int) -> int:
	'''
		process an order for a given customer
		returns the order number created
	'''
	current_date	= datetime.date.today()					# get today's date
	required_date	= current_date + datetime.timedelta(10)	# required date is 10 days from now
	comments		= ask_for_comments()					# get comments from user
	
	con = get_connection()									# get a connection object
	cur = con.cursor()										# get a cursor object to execute queries	

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

def add_order_details(orderID: int, cart: list) -> None:
	'''
		add order details for a given order number and shopping cart
	'''
	con = get_connection()					# get a connection object
	cur = con.cursor()						# get a cursor object to execute queries	

	# TO DO: add order details to the order
	# iterate through the shopping cart
	# each item in the cart is a tuple of (product_code, quantity, price)
	# each row also needs to have the order number, which was passed in as an argument
	# once the cart has been prepared, use the executemany() method to execute the query
	
	# create an SQL query with placeholders for the values
	order_details = []	# list to hold the order details to be inserted
	sql =	"INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) " \
			"VALUES (%s, %s, %s, %s, %s);"
	
	con.commit()							# commit the transaction
	con.close()								# close the connection

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