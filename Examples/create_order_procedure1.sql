DELIMITER $$ -- temporary delimiter to take place of ;

USE classicmodels$$ -- which database the procedure is for
DROP PROCEDURE IF EXISTS create_order;

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_order`(IN currentDate DATE, IN dateRequired DATE, IN comments TEXT, IN custID INT)
BEGIN
	
    DECLARE new_pk INT;			-- create a variable to hold the new primary key
    SELECT MAX(orderNumber)		-- get the current largest order number
    INTO new_pk					-- put it into the variable
    FROM orders;				
    
    SET new_pk = new_pk + 1;	-- add one to the largest PK
    
    INSERT INTO orders			-- now that you have the new PK, create the order
    VALUES(new_pk, currentDate, dateRequired, NULL, 'In Process', comments, custID);

END $$
DELIMITER ;