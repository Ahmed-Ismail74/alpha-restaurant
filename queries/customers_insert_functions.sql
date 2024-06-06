-- EX: CALL pr_customer_signup(
--     'ahmed',
--     'khalid',
--     'm',
--     '01124495648',
--     'jsfjashkdjah2sdjkh2hjhsjkahd',
--     '1st aksjdkjl12skaj',
--     'cairo'
-- )
-- Used to sign up if phone is not exist  
-- Or phone is related with wrong customer who is not have an account
CREATE OR REPLACE PROCEDURE pr_customer_signup(
    fn_cust_first_name VARCHAR(35),
    fn_cust_last_name VARCHAR(35),
    fn_cust_gender sex_type,
    fn_cust_phone VARCHAR(15),
    fn_cust_password varchar(60),
    fn_cust_address VARCHAR(95),
    fn_cust_city VARCHAR(35) DEFAULT NULL,
    fn_location_coordinates POINT DEFAULT NULL,
    fn_cust_birthdate DATE DEFAULT NULL,
    fn_picture_path VARCHAR(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_cust_id INT;
    fn_phone_id INT;
BEGIN
    INSERT INTO customers(
        customer_first_name,
        customer_last_name,
        customer_gender,
        customer_birthdate)
        VALUES(
            fn_cust_first_name,
            fn_cust_last_name,
            fn_cust_gender,
            fn_cust_birthdate
        ) RETURNING customer_id INTO fn_cust_id;
    INSERT INTO customers_addresses_list(
        customer_id,
        customer_address,
        customer_city,
        location_coordinates
    ) VALUES(
        fn_cust_id,
        fn_cust_address,
        fn_cust_city,
        fn_location_coordinates
    );
    SELECT customer_phone_id INTO fn_phone_id 
    FROM customers_phones_list 
    WHERE customer_phone = fn_cust_phone;
    
    IF fn_phone_id IS NULL THEN
        INSERT INTO customers_phones_list(
            customer_id,
            customer_phone
        ) VALUES(
            fn_cust_id,
            fn_cust_phone
        ) RETURNING customer_phone_id INTO fn_phone_id;
    ELSE
        PERFORM 1 FROM customers_accounts 
        WHERE customer_phone_id = fn_phone_id;
        IF NOT FOUND THEN
            UPDATE customers_phones_list
            SET customer_id = fn_cust_id
            WHERE fn_phone_id = customer_phone_id;
        ELSE
            RAISE EXCEPTION 
            USING MESSAGE = 'This number is linked to an account',
            HINT = 'Change the number or recover the account';
        END IF;
    END IF;

    INSERT INTO customers_accounts(
        customer_id,
        customer_phone_id,
        customer_password,
        picture_path
    ) VALUES(
        fn_cust_id,
        fn_phone_id,
        fn_cust_password,
        fn_picture_path
    );
    RAISE NOTICE USING MESSAGE = 'Account created successfully';
END;
$$;



-- procedure to create customer account if already have customer data
-- maybe change the data also 
-- CALL pr_add_account_to_customer(
--     11,
--     'kareem',
--     'sayed',
--     'm',
--     '01000015545',
--     'ahsjdhajsdhjashdjhasjd',
--     '1sh ali hesssen'
-- ) 
CREATE OR REPLACE PROCEDURE pr_add_account_to_customer(
    fn_cust_id INT,
    fn_cust_first_name VARCHAR(35),
    fn_cust_last_name VARCHAR(35),
    fn_cust_gender sex_type,
    fn_cust_phone VARCHAR(15),
    fn_cust_password varchar(60),
    fn_cust_address VARCHAR(95),
    fn_cust_city VARCHAR(35) DEFAULT NULL,
    fn_location_coordinates POINT DEFAULT NULL,
    fn_cust_birthdate DATE DEFAULT NULL,
    fn_picture_path VARCHAR(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_phone_id INT;
BEGIN
    PERFORM 1 FROM customers_accounts
    WHERE customer_id = fn_cust_id;
    IF FOUND THEN
        RAISE EXCEPTION
        USING MESSAGE = 'Customer already have an account';
    ELSE
        UPDATE customers
        SET
            customer_first_name = fn_cust_first_name,
            customer_last_name = fn_cust_last_name,
            customer_gender = fn_cust_gender,
            customer_birthdate = fn_cust_birthdate
        WHERE customer_id = fn_cust_id;


        SELECT customer_phone_id INTO fn_phone_id
        FROM customers_phones_list
        WHERE 
            customer_phone = fn_cust_phone
            AND customer_id = fn_cust_id;
        
        INSERT INTO customers_accounts(
        customer_id,
        customer_phone_id,
        customer_password,
        picture_path
        ) VALUES(
            fn_cust_id,
            fn_phone_id,
            fn_cust_password,
            fn_picture_path
        );

        PERFORM 1 FROM customers_addresses_list 
        WHERE customer_id = fn_cust_id;
        IF FOUND THEN
            UPDATE customers_addresses_list
            SET
                customer_address = fn_cust_address,
                customer_city = fn_cust_city,
                location_coordinates = fn_location_coordinates
            WHERE customer_id = fn_cust_id;
        ELSE
            INSERT INTO customers_addresses_list(
                customer_id,
                customer_address,
                customer_city,
                location_coordinates
            ) VALUES(
                fn_cust_id,
                fn_cust_address,
                fn_cust_city,
                fn_location_coordinates
            );
            RAISE NOTICE
            USING MESSAGE = 'Account created';
        END IF;
    END IF;
END;
$$;


-- EX: CALL pr_add_customer(
--     'ahmed',
--     'khalid',
--     'm',
--     '01124495648',
--     '1st aksjdkjl12skaj',
--     'cairo'
-- );

CREATE OR REPLACE PROCEDURE pr_add_customer(
    fn_cust_first_name VARCHAR(35),
    fn_cust_last_name VARCHAR(35),
    fn_cust_gender sex_type,
    fn_cust_phone VARCHAR(15),
    fn_cust_address VARCHAR(95),
    fn_cust_city VARCHAR(35) DEFAULT NULL,
    fn_location_coordinates POINT DEFAULT NULL,
    fn_cust_birthdate DATE DEFAULT NULL
)
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_cust_id INT;
    fn_phone_id INT;
BEGIN
    INSERT INTO customers(
        customer_first_name,
        customer_last_name,
        customer_gender,
        customer_birthdate)
        VALUES(
            fn_cust_first_name,
            fn_cust_last_name,
            fn_cust_gender,
            fn_cust_birthdate
        ) RETURNING customer_id INTO fn_cust_id;
    INSERT INTO customers_addresses_list(
        customer_id,
        customer_address,
        customer_city,
        location_coordinates
    ) VALUES(
        fn_cust_id,
        fn_cust_address,
        fn_cust_city,
        fn_location_coordinates
    );
    SELECT customer_phone_id INTO fn_phone_id 
    FROM customers_phones_list 
    WHERE customer_phone = fn_cust_phone;

    IF fn_phone_id IS NULL THEN
        INSERT INTO customers_phones_list(
            customer_id,
            customer_phone
        ) VALUES(
            fn_cust_id,
            fn_cust_phone
        ) RETURNING customer_phone_id INTO fn_phone_id;
    ELSE
        PERFORM 1 FROM customers_accounts 
        WHERE customer_phone_id = fn_phone_id;
        IF NOT FOUND THEN
            UPDATE customers_phones_list
            SET customer_id = fn_cust_id
            WHERE fn_phone_id = customer_phone_id;
        ELSE
            RAISE EXCEPTION 
            USING MESSAGE = 'This number is linked to an account',
            HINT = 'Change the number or recover the account';
        END IF;
    END IF;
    RAISE NOTICE USING MESSAGE = 'Customer added successfully';
END;
$$;


-- function to add address to existed customer
CREATE OR REPLACE PROCEDURE pr_add_customer_address(
    pr_cust_id INT,
    pr_cust_address VARCHAR(95),
	pr_cust_city VARCHAR(35) DEFAULT NULL,
	pr_location_coordinates POINT DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM customers
    WHERE customer_id = pr_cust_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer not exist';
    ELSE
        INSERT INTO customers_addresses_list(
            customer_id ,
            customer_address,
            customer_city ,
            location_coordinates 
        ) VALUES(
            pr_cust_id ,
            pr_cust_address ,
            pr_cust_city ,
            pr_location_coordinates
        );
        RAISE NOTICE 'Address added successfully';
    END IF;
END;
$$;



-- function to add phone to existed customer
-- CALL pr_add_customer_phone(2,'017255185884');
CREATE OR REPLACE PROCEDURE pr_add_customer_phone(
    pr_cust_id INT,
    pr_cust_phone VARCHAR(15)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM customers
    WHERE customer_id = pr_cust_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer not exist';
    ELSE
        INSERT INTO customers_phones_list(
            customer_id ,
            customer_phone
        ) VALUES(
            pr_cust_id ,
            pr_cust_phone
        );
        RAISE NOTICE 'Phone added successfully';
    END IF;
END;
$$;

-- function to add a friend request using id of accounts not id of customers
CREATE OR REPLACE PROCEDURE pr_add_friend_request(
    pr_sender_account_id INT,
    pr_receiver_account_id INT
)
LANGUAGE PLPGSQL
AS 
$$
BEGIN
    PERFORM 1 FROM customers_accounts
    WHERE account_id = pr_sender_account_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sender not exist';
    ELSE
        PERFORM 1 FROM customers_accounts
        WHERE account_id = pr_receiver_account_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Receiver not exist';
        ELSE
            INSERT INTO friends_requests(
                sender_account_id,
                receiver_account_id
            ) VALUES(
                pr_sender_account_id,
                pr_receiver_account_id
            );
            RAISE NOTICE 'Request added';
        END IF;
    END IF;
END;
$$;







CREATE OR REPLACE PROCEDURE pr_add_favorite(
    p_customer_id INT,
    p_item_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'Customer ID % does not exist', p_customer_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM menu_items WHERE item_id = p_item_id) THEN
        RAISE EXCEPTION 'Item ID % does not exist', p_item_id;
    END IF;

    INSERT INTO customers_favorites (customer_id, item_id)
    VALUES (p_customer_id, p_item_id)
    ON CONFLICT (customer_id, item_id) DO NOTHING;
END;
$$;

-- Procedure to add a rating
CREATE OR REPLACE PROCEDURE p_add_rating(
    p_customer_id INT,
    p_item_id INT,
    p_rating range_0_to_5 
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'Customer ID % does not exist', p_customer_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM menu_items WHERE item_id = p_item_id) THEN
        RAISE EXCEPTION 'Item ID % does not exist', p_item_id;
    END IF;

    INSERT INTO customers_ratings (customer_id, item_id, rating)
    VALUES (p_customer_id, p_item_id, p_rating)
    ON CONFLICT (customer_id, item_id) DO UPDATE
    SET rating = EXCLUDED.rating;
END;
$$;

-- SELECT * FROM customers;
-- SELECT * FROM customers_addresses_list;
-- SELECT * FROM customers_phones_list;
-- SELECT * FROM menu_items;
-- SELECT * FROM branches;
-- SELECT * FROM branches_menu;
-- SELECT * FROM customers_ratings;
-- SELECT * FROM customers_favorites;
