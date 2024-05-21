
-- -- delivery EX
-- CALL add_non_virtual_order(
--     pr_customer_id := 2,
--     pr_branch_id := 1,
--     pr_order_type := 'delivery',
--     pr_order_status := 'pending',
--     pr_total_price := 100.00,
--     pr_payment_method := 'cash',
--     pr_order_items := '[{"item_id": 31, "quantity": 2, "quote_price": 10.00}, {"item_id": 32, "quantity": 1, "quote_price": 15.00}]',
--     pr_address_id := 4,
--     pr_customer_phone_id := 2
-- );
CREATE OR REPLACE PROCEDURE add_non_virtual_order(
    -- order main info
    pr_customer_id INT,
    pr_branch_id INT,
    pr_order_type order_type,
    pr_order_status order_status_type,
    pr_total_price NUMERIC(10,2),
    pr_payment_method payment_method_type,
    -- order items
    pr_order_items JSON,
    -- optional parameters
    pr_additional_discount NUMERIC(4,2) DEFAULT 0,
    -- credit_details if exist
    pr_credit_card_number varchar(16) DEFAULT NULL,
	pr_credit_card_exper_month SMALLINT DEFAULT NULL,
	pr_credit_card_exper_day SMALLINT DEFAULT NULL,
	pr_name_on_card VARCHAR(35) DEFAULT NULL,
    -- lounge details if offline order in branch
    pr_table_id INT DEFAULT NULL,
    -- order connectiong info if delivery order
    pr_address_id INT DEFAULT NULL,
    pr_customer_phone_id INT DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    pr_order_id INT;
BEGIN
    PERFORM 1 FROM customers
    WHERE pr_customer_id = customer_id;
    IF FOUND THEN
        PERFORM 1 FROM branches
        WHERE pr_branch_id = branch_id;
        IF FOUND THEN
            INSERT INTO orders(
                customer_id ,
                branch_id ,
                order_type ,
                order_status ,
                order_total_price,
                order_customer_discount ,
                order_payment_method
            )
            VALUES(
                pr_customer_id ,
                pr_branch_id ,
                pr_order_type ,
                pr_order_status ,
                pr_total_price,
                pr_additional_discount,
                pr_payment_method
            ) RETURNING order_id INTO pr_order_id;
            -- lounge order or Delive
            IF pr_order_type = 'delivery' THEN
                PERFORM 1 FROM customers_addresses_list
                WHERE pr_address_id = address_id;
                IF FOUND THEN
                    PERFORM 1 FROM customers_phones_list
                    WHERE pr_customer_phone_id = customer_phone_id;
                    IF FOUND THEN
                        INSERT INTO orders_connecting_details
                        (order_id, address_id, customer_phone_id)
                        VALUES (pr_order_id, pr_address_id, pr_customer_phone_id);
                    ELSE
                        RAISE EXCEPTION 'Phone not found';
                    END IF;
                    
                ELSE
                    RAISE EXCEPTION 'Address not found';
                END IF;
            ELSIF pr_order_type = 'dine-in' THEN
                PERFORM 1 FROM branch_tables
                WHERE branch_id = pr_branch_id
                AND table_id = pr_table_id;
                IF FOUND THEN
                    INSERT INTO lounge_orders
                    (order_id, branch_id, table_id)
                    VALUES (pr_order_id, pr_branch_id, pr_table_id);
                ELSE
                    RAISE EXCEPTION 'Table not found';
                END IF;
            END IF;

            -- order details
            IF pr_order_items IS NOT NULL THEN
                INSERT INTO non_virtual_orders_items 
                    (order_id, item_id, quantity, quote_price)
                SELECT 
                    pr_order_id,
                    (item_data ->> 'item_id')::INT,
                    (item_data ->> 'quantity')::SMALLINT,
                    (item_data ->> 'quote_price')::NUMERIC
                FROM 
                    json_array_elements(pr_order_items) AS item_data;
            ELSE
                RAISE EXCEPTION 'Order items is empty';
            END IF;


            --credit card add 
            IF pr_credit_card_number IS NOT NULL AND
            pr_credit_card_exper_month IS NOT NULL AND
            pr_credit_card_exper_day IS NOT NULL AND
            pr_name_on_card IS NOT NULL THEN
                INSERT INTO orders_credit_details
                (order_id, credit_card_number, credit_card_exper_month, credit_card_exper_day, name_on_card)
                VALUES (pr_order_id, pr_credit_card_number, pr_credit_card_exper_month, pr_credit_card_exper_day, pr_name_on_card);
            END IF;
        ELSE
            RAISE EXCEPTION 'Branch not exist';
        END IF;

    ELSE
        RAISE EXCEPTION 'Customer not exist';
    END IF;
END;
$$;



-- -- delivery EX
-- CALL add_virtual_order(
--     pr_customer_id := 2,
--     pr_branch_id := 1,
--     pr_order_type := 'delivery',
--     pr_order_status := 'pending',
--     pr_total_price := 100.00,
--     pr_payment_method := 'cash',
--     pr_order_items := '[{"item_id": 31,"customer_id": 2, "quantity": 2, "quote_price": 10.00}, {"item_id": 32,"customer_id": 4, "quantity": 1, "quote_price": 15.00}]',
--     pr_address_id := 4,
--     pr_customer_phone_id := 2
-- );
SELECT * FROM customers
CREATE OR REPLACE PROCEDURE add_virtual_order(
    -- order main info
    pr_customer_id INT,
    pr_branch_id INT,
    pr_order_type order_type,
    pr_order_status order_status_type,
    pr_total_price NUMERIC(10,2),
    pr_payment_method payment_method_type,
    -- order items
    pr_order_items JSON,
    -- optional parameters
    pr_additional_discount NUMERIC(4,2) DEFAULT 0,
    -- credit_details if exist
    pr_credit_card_number varchar(16) DEFAULT NULL,
	pr_credit_card_exper_month SMALLINT DEFAULT NULL,
	pr_credit_card_exper_day SMALLINT DEFAULT NULL,
	pr_name_on_card VARCHAR(35) DEFAULT NULL,
    -- lounge details if offline order in branch
    pr_table_id INT DEFAULT NULL,
    -- order connectiong info if delivery order
    pr_address_id INT DEFAULT NULL,
    pr_customer_phone_id INT DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    pr_order_id INT;
BEGIN
    PERFORM 1 FROM customers
    WHERE pr_customer_id = customer_id;
    IF FOUND THEN
        PERFORM 1 FROM branches
        WHERE pr_branch_id = branch_id;
        IF FOUND THEN
            INSERT INTO orders(
                customer_id ,
                branch_id ,
                order_type ,
                order_status ,
                order_total_price,
                order_customer_discount ,
                order_payment_method
            )
            VALUES(
                pr_customer_id ,
                pr_branch_id ,
                pr_order_type ,
                pr_order_status ,
                pr_total_price,
                pr_additional_discount,
                pr_payment_method
            ) RETURNING order_id INTO pr_order_id;
            -- lounge order or Delive
            IF pr_order_type = 'delivery' THEN
                PERFORM 1 FROM customers_addresses_list
                WHERE pr_address_id = address_id;
                IF FOUND THEN
                    PERFORM 1 FROM customers_phones_list
                    WHERE pr_customer_phone_id = customer_phone_id;
                    IF FOUND THEN
                        INSERT INTO orders_connecting_details
                        (order_id, address_id, customer_phone_id)
                        VALUES (pr_order_id, pr_address_id, pr_customer_phone_id);
                    ELSE
                        RAISE EXCEPTION 'Phone not found';
                    END IF;
                    
                ELSE
                    RAISE EXCEPTION 'Address not found';
                END IF;
            ELSIF pr_order_type = 'dine-in' THEN
                PERFORM 1 FROM branch_tables
                WHERE branch_id = pr_branch_id
                AND table_id = pr_table_id;
                IF FOUND THEN
                    INSERT INTO lounge_orders
                    (order_id, branch_id, table_id)
                    VALUES (pr_order_id, pr_branch_id, pr_table_id);
                ELSE
                    RAISE EXCEPTION 'Table not found';
                END IF;
            END IF;

            -- order details
            IF pr_order_items IS NOT NULL THEN
                INSERT INTO virtual_orders_items 
                    (order_id, item_id, customer_id, quantity, quote_price)
                SELECT 
                    pr_order_id,
                    (item_data ->> 'item_id')::INT,
                    (item_data ->> 'customer_id')::INT,
                    (item_data ->> 'quantity')::SMALLINT,
                    (item_data ->> 'quote_price')::NUMERIC
                FROM 
                    json_array_elements(pr_order_items) AS item_data;
            ELSE
                RAISE EXCEPTION 'Order items is empty';
            END IF;
        ELSE
            RAISE EXCEPTION 'Branch not exist';
        END IF;

    ELSE
        RAISE EXCEPTION 'Customer not exist';
    END IF;
END;
$$;


