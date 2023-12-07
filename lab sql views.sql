/* Creating a Customer Summary Report

In this exercise, you will create a customer summary report that summarizes key informatio
n about customers in the Sakila database, including their rental history and payment details.
 The report will be generated using a combination of views, CTEs, and temporary tables.
 */
 
 -- step 1. First, create a view that summarizes rental information for each customer. 
 -- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
use sakila;

-- drop view if exists for safeguards
DROP VIEW IF EXISTS rental_info; 

CREATE VIEW rental_info as (
	SELECT 
		r.customer_id,
		concat(c.first_name,' ',c.last_name) as cust_name,
		c.email,
		count(rental_id) as total_number_of_rental
	FROM
		rental r
	RIGHT JOIN customer c ON r.customer_id = c.customer_id -- right join to preserve every single customer ID.
	GROUP BY r.customer_id, cust_name, c.email
);

/*-- step2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.
*/

-- drop temp table if exists for safeguards
DROP TEMPORARY TABLE IF EXISTS rental_pmt_info; 

CREATE TEMPORARY TABLE rental_pmt_info as (
	SELECT 
		ro.customer_id,
        ro.cust_name, 
        ro.email, 
        ro.total_number_of_rental,
		sum(p.amount) as total_paid
	FROM
			payment p
	RIGHT JOIN rental_info ro ON p.customer_id = ro.customer_id -- right join so that all customers are included

	GROUP BY 
			ro.customer_id,
			ro.cust_name, 
			ro.email, 
			ro.total_number_of_rental
);

/*Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table
-- created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.
*/

WITH CTE_customer_rental_info  AS
(
  SELECT 
	*, 
    round((total_paid/total_number_of_rental),2) as average_payment_per_rental  -- to obtain average payment per rental
FROM 
	rental_pmt_info
)
SELECT * FROM CTE_customer_rental_info; -- select from CTE 
-- WHERE customer_id = 1; 
-- use the where statement as needed to show the selected customer 
