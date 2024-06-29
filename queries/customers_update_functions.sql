-- SELECT * FROM friends_requests;
CREATE OR REPLACE PROCEDURE pr_update_friend_request(
    pr_request_id INT,
    pr_request_status friend_request_type
)
LANGUAGE PLPGSQL
AS
$$
DECLARE 
    user1 INT;
    user2 INT;
BEGIN
    PERFORM 1 FROM friends_requests
    WHERE friendship_request_id = pr_request_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Friend request not exist';
    ELSE
        SELECT sender_account_id, receiver_account_id
        INTO user1, user2
        FROM friends_requests
        WHERE friendship_request_id = pr_request_id;

        IF pr_request_status = 'accepted' THEN
            UPDATE friends_requests
            SET friend_request_status = pr_request_status
            WHERE friendship_request_id = pr_request_id;
            INSERT INTO friendships(
                account_id_sender,
                account_id_receiver,
                friendship_request_id
            ) VALUES(
                user1,
                user2,
                pr_request_id
            );
            RAISE NOTICE 'Request accepted';
        ELSIF pr_request_status = 'rejected' THEN
            UPDATE friends_requests
            SET 
                friend_request_status = pr_request_status,
                request_reply_time = CURRENT_TIMESTAMP
            WHERE friendship_request_id = pr_request_id;

            RAISE EXCEPTION 'Request rejected';
            
        END IF;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE pr_update_customer_address(
	fn_customer_id INT,
    fn_address_id INT,
	fn_customer_address VARCHAR(255),
    fn_customer_city VARCHAR(35) DEFAULT NULL,
	fn_location_coordinates POINT DEFAULT NULL
)
LANGUAGE PLPGSQL
AS 
$$
BEGIN
	PERFORM 1 FROM customers 
    WHERE customer_id = fn_customer_id;
	IF FOUND THEN
		UPDATE customers_addresses_list 
		SET 
            customer_address = fn_customer_address ,
            customer_city = fn_customer_city ,
            location_coordinates = fn_location_coordinates 
		WHERE 
            fn_address_id = address_id AND
            fn_customer_id = customer_id ;
		RAISE NOTICE 'address changed';
	ELSE
		RAISE EXCEPTION 'Customer not found';
	END IF;
END;
$$;








DROP PROCEDURE change_customer_password;
CREATE OR REPLACE PROCEDURE change_customer_password(
    p_customer_id INT,
    p_new_password VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if the customer account exists
    IF NOT EXISTS (
        SELECT 1
        FROM customers_accounts
        WHERE customer_id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Customer not found for customer_id %', p_customer_id;
    END IF;

    -- Update the customer password
    UPDATE customers_accounts
    SET customer_password = p_new_password
    WHERE customer_id = p_customer_id;

    -- Raise a notice for successful update
    RAISE NOTICE 'Customer password updated successfully for customer_id %', p_customer_id;

END;
$$;









CREATE OR REPLACE PROCEDURE change_customer_picture(
    p_customer_id INT,
    p_picture_path VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if the customer exists
    PERFORM 1 FROM customers_accounts WHERE customer_id = p_customer_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer not found for customer_id %', p_customer_id;
    END IF;

    -- Update the customer picture
    UPDATE customers_accounts
    SET picture_path = p_picture_path
    WHERE customer_id = p_customer_id;

    -- Raise a notice for successful update
    RAISE NOTICE 'Customer Picture updated successfully for customer_id %', p_customer_id;

END;
$$;