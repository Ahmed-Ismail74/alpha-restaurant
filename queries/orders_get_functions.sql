CREATE OR REPLACE FUNCTION fn_get_customer_bookings(
    fn_customer_id INT
)
RETURNS TABLE(
    booking_id INT ,
	customer_id INT ,
	table_id INT ,
	branch_id INT ,
	booking_date TIMESTAMPTZ ,
	booking_start_time TIMESTAMPTZ  ,
	booking_end_time TIMESTAMPTZ  ,
	booking_status order_status_type
)
LANGUAGE PLPGSQL 
AS $$
BEGIN
    PERFORM 1 FROM customers cus WHERE cus.customer_id = fn_customer_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer not exist';
    ELSE
        RETURN QUERY
            SELECT * FROM bookings bo WHERE bo.customer_id = fn_customer_id;
    END IF;
END;
$$;


-- get orders of customer
-- SELECT * FROM fn_get_customer_orders(2,2);
CREATE OR REPLACE FUNCTION fn_get_customer_orders(
    fn_customer_id INT,
    fn_limit INT
)
RETURNS TABLE(
    order_id INT,
    branch_name VARCHAR(35),
    order_date TIMESTAMPTZ,
    ship_date TIMESTAMPTZ,
    order_type order_type,
    order_status order_status_type,
    order_total_price NUMERIC(10,2),
    order_customer_discount NUMERIC(4,2),
    order_payment_method payment_method_type,
    virtual_room BOOLEAN
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM customers WHERE fn_customer_id = customer_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer not found';
    ELSE
        RETURN QUERY
            SELECT ord.order_id, br.branch_name, ord.order_date, ord.ship_date,
            ord.order_type, ord.order_status, ord.order_total_price, ord.order_customer_discount,
            ord.order_payment_method, ord.virtual_room FROM orders ord

            LEFT JOIN branches br ON br.branch_id = ord.branch_id
            
            WHERE customer_id = fn_customer_id
            ORDER BY ord.order_date DESC
            LIMIT fn_limit;
    END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_virtual_order_details(
    fn_order_id INT
)
RETURNS TABLE(
    cust_name TEXT,
    item_name VARCHAR(35),
    quantity SMALLINT,
    quote_price NUMERIC(6,2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM orders WHERE order_id = fn_order_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not exist';
    ELSE
        RETURN QUERY
            SELECT 
            (cust.customer_first_name || ' ' || cust.customer_last_name) as cust_name,
            menu.item_name, vr_order.quantity, vr_order.quote_price
            FROM virtual_orders_items vr_order
            LEFT JOIN customers cust ON cust.customer_id = vr_order.customer_id
            LEFT JOIN menu_items menu ON menu.item_id = vr_order.item_id
            WHERE order_id = fn_order_id;
    END IF;
END;
$$;




CREATE OR REPLACE FUNCTION fn_get_non_virtual_order_details(
    fn_order_id INT
)
RETURNS TABLE(
    item_name VARCHAR(35),
    quantity SMALLINT,
    quote_price NUMERIC(6,2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM orders WHERE order_id = fn_order_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not exist';
    ELSE
        RETURN QUERY
            SELECT 
            menu.item_name, non_vr_order.quantity, non_vr_order.quote_price
            FROM non_virtual_orders_items non_vr_order
            LEFT JOIN menu_items menu ON menu.item_id = non_vr_order.item_id
            WHERE order_id = fn_order_id;
    END IF;
END;
$$;
