-- EX: SELECT * FROM fn_verify_phone('01124495648');
CREATE OR REPLACE FUNCTION fn_verify_phone(
    fn_phone VARCHAR(15)
)
RETURNS INT
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_phone_id INT;
    fn_cust_id INT;
BEGIN
    SELECT customer_phone_id, customer_id 
    INTO fn_phone_id, fn_cust_id
    FROM customers_phones_list
    WHERE customer_phone = fn_phone;
    IF fn_phone_id IS NULL THEN
        RAISE NOTICE USING MESSAGE = 'Phone not related to customer';
    ELSE
        PERFORM 1 FROM customers_accounts
        WHERE customer_phone_id = fn_phone_id;
        IF FOUND THEN 
            RAISE EXCEPTION USING MESSAGE = 'This number is linked to an account';
        ELSE
            RETURN fn_cust_id;
        END IF;
    END IF;
END;
$$;

-- EX: SELECT * FROM fn_get_customer_info(2);
CREATE OR REPLACE FUNCTION fn_get_customer_info(
    fn_cust_id INT
)
RETURNS TABLE(
    customer_id INT,
    customer_first_name VARCHAR(35),
	customer_last_name VARCHAR(35) ,
	customer_gender sex_type ,
	customer_birthdate DATE
)
LANGUAGE PLPGSQL
AS
$$
BEGIN
    PERFORM 1 FROM customers cust
    WHERE cust.customer_id = fn_cust_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 
        USING MESSAGE = 'customer not found';
    ELSE
        RETURN QUERY
            SELECT * FROM customers cust
            WHERE cust.customer_id = fn_cust_id;
    END IF;
END;
$$;

