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

    INSERT INTO customers_accounts(
        customer_id,
        customer_phone_id,
        customer_password
    ) VALUES(
        fn_cust_id,
        fn_phone_id,
        fn_cust_password
    );
    RAISE NOTICE USING MESSAGE = 'Account created successfully';
END;
$$;



-- procedure to create customer account if already have customer data
-- maybe change the data also 
CALL pr_add_account_to_customer(
    11,
    'kareem',
    'sayed',
    'm',
    '01000015545',
    'ahsjdhajsdhjashdjhasjd',
    '1sh ali hesssen'
)
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
    fn_cust_birthdate DATE DEFAULT NULL
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
            fn_cust_phone = customer_phone
            AND customer_id = fn_cust_id;
        
        INSERT INTO customers_accounts(
        customer_id,
        customer_phone_id,
        customer_password
        ) VALUES(
            fn_cust_id,
            fn_phone_id,
            fn_cust_password
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