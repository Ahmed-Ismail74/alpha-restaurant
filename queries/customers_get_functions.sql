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


-- Get the phones of customer
-- EX: SELECT * FROM fn_get_customer_phones(2);
CREATE OR REPLACE FUNCTION fn_get_customer_phones(
    fn_cust_id INT
)
RETURNS TABLE(
    customer_phone_id INT ,
	customer_phone VARCHAR(15)
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
            SELECT li.customer_phone_id, li.customer_phone
            FROM customers_phones_list li
            WHERE customer_id = fn_cust_id;
    END IF;
END;
$$;


-- Get the addresses of customer
-- EX: SELECT * FROM fn_get_customer_addresses(2);
CREATE OR REPLACE FUNCTION fn_get_customer_addresses(
    fn_cust_id INT
)
RETURNS TABLE(
    address_id INT ,
	customer_address VARCHAR(95) ,
	customer_city VARCHAR(35),
	location_coordinates POINT
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
            SELECT li.address_id, li.customer_address, li.customer_city, li.location_coordinates 
            FROM customers_addresses_list li
            WHERE customer_id = fn_cust_id;
    END IF;
END;
$$;



-- The function take account id and return friends name and customer id
CREATE OR REPLACE FUNCTION fn_get_friends_list(
    fn_acc_id INT
)
RETURNS TABLE(
    id INT,
    name TEXT
)
LANGUAGE PLPGSQL
AS
$$
BEGIN 
    PERFORM 1 FROM customers_accounts cust
    WHERE cust.account_id = fn_acc_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 
        USING MESSAGE = 'Account not found';
    ELSE
        RETURN QUERY    
            SELECT cust.customer_id, (cust.customer_first_name || ' ' || cust.customer_last_name) as name
            FROM friendships fr
            INNER JOIN customers_accounts acc 
            ON (fr.account_id_receiver = acc.account_id AND fr.account_id_receiver != fn_acc_id)
            OR (fr.account_id_sender = acc.account_id AND fr.account_id_sender != fn_acc_id)

            INNER JOIN customers cust ON acc.customer_id = cust.customer_id 
            WHERE fr.account_id_receiver = fn_acc_id OR fr.account_id_sender = fn_acc_id;
    END IF;
END;
$$;

-- SELECT * FROM fn_get_friend_requests(4);
-- SELECT * FROM friends_requests;
CREATE OR REPLACE FUNCTION fn_get_friend_requests(
    fn_acc_id INT
)
RETURNS TABLE(
    id INT,
    cust_name TEXT 
)
LANGUAGE PLPGSQL
AS
$$
BEGIN
    PERFORM 1 FROM customers_accounts
    WHERE account_id = fn_acc_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account not found';
    ELSE
        RETURN QUERY
            SELECT cust.customer_id, (customer_first_name || ' ' || customer_last_name)
            FROM friends_requests req
            LEFT JOIN customers_accounts acc ON req.sender_account_id = acc.account_id
            LEFT JOIN customers cust ON cust.customer_id = acc.customer_id
            WHERE 
                req.receiver_account_id = fn_acc_id
                AND req.friend_request_status = 'pending';
    END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_customer_hash(
	fn_customer_phone varchar(15)
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    fn_phone_id INT;
BEGIN
	SELECT customer_phone_id INTO fn_phone_id
    FROM customers_phones_list
	WHERE customer_phone = fn_customer_phone;
	IF fn_phone_id IS NULL THEN
		RAISE EXCEPTION 'Account not Exist';
	ELSE
		RETURN (
			SELECT customer_password FROM customers_accounts
			WHERE customer_phone_id = fn_phone_id
			);
	END IF;
END;
$$;




CREATE OR REPLACE FUNCTION fn_get_customer_sign_in_info(
	fn_customer_phone varchar(15)
)
RETURNS TABLE(
    customer_id INT,
	customer_first_name VARCHAR(35),
	customer_last_name VARCHAR(35)
)
LANGUAGE plpgsql
AS $$
DECLARE
    fn_customer_id INT;
BEGIN
	SELECT cust_phone.customer_id INTO fn_customer_id
    FROM customers_phones_list cust_phone
	WHERE cust_phone.customer_phone = fn_customer_phone;
	IF fn_customer_id IS NULL THEN
		RAISE EXCEPTION 'Customer not Exist';
	ELSE
		RETURN QUERY(
			SELECT 
            cust.customer_id,
            cust.customer_first_name,
            cust.customer_last_name
            FROM customers cust
			WHERE cust.customer_id = fn_customer_id
			);
	END IF;
END;
$$;