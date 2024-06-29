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
            SELECT * FROM bookings bo 
            WHERE bo.customer_id = fn_customer_id
            ORDER BY booking_date DESC;
    END IF;
END;
$$;


-- get orders of customer
-- SELECT * FROM fn_get_customer_orders(125,2,'completed');

CREATE OR REPLACE FUNCTION fn_get_customer_orders(
    fn_customer_id INT,
    fn_limit INT,
    fn_orders_status order_status_type DEFAULT NULL
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
            
            WHERE customer_id = fn_customer_id AND (ord.order_status = fn_orders_status OR fn_orders_status IS NULL)
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

CREATE OR REPLACE FUNCTION fn_get_order_items_by_section(
    f_section_id INT,
    f_branch_id INT,
    f_optional_status order_status_type DEFAULT NULL
) RETURNS TABLE (
    fn_order_id INT,
    fn_customer_id INT,
    fn_item_id INT,
    fn_section_id INT,
    fn_item_status order_status_type,
    fn_order_date TIMESTAMPTZ,
    fn_order_type order_type,
    fn_virtual_room BOOLEAN,
    fn_quantity SMALLINT,
    fn_quote_price NUMERIC(6,2)
) LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if there are any matching orders
    IF NOT EXISTS (
        SELECT 1
        FROM order_items_sections
        WHERE section_id = f_section_id
        AND (f_optional_status IS NULL OR item_status = f_optional_status)
    ) THEN
        RAISE EXCEPTION 'No orders found for section_id % with status %', f_section_id, f_optional_status;
    END IF;
    
    RETURN QUERY
    SELECT
        sec.order_id,
        sec.customer_id,
        sec.item_id,
        sec.section_id,
        sec.item_status,
        
        ord.order_date,
        ord.order_type,
        ord.virtual_room,
        CASE 
            WHEN ord.virtual_room THEN voi.quantity
            ELSE nvoi.quantity
        END AS fn_quantity,
        CASE 
            WHEN ord.virtual_room THEN voi.quote_price
            ELSE nvoi.quote_price
        END AS fn_quote_price
    FROM
        order_items_sections sec
    JOIN orders ord ON sec.order_id = ord.order_id AND ord.branch_id = f_branch_id
    LEFT JOIN virtual_orders_items voi ON sec.order_id = voi.order_id AND ord.virtual_room = true AND sec.item_id = voi.item_id
    LEFT JOIN non_virtual_orders_items nvoi ON sec.order_id = nvoi.order_id AND ord.virtual_room = false AND sec.item_id = nvoi.item_id
    WHERE
        sec.section_id = f_section_id
        AND (f_optional_status IS NULL OR sec.item_status = f_optional_status)
		
	ORDER BY ord.order_id DESC;
END;
$$;





CREATE OR REPLACE FUNCTION fn_get_order_items_status(
    f_order_id INT,
    f_optional_status order_status_type DEFAULT NULL
) RETURNS TABLE (
    fn_customer_id INT,
    fn_item_id INT,
    fn_section_id INT,
    fn_item_status order_status_type
) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        sec.customer_id,
        sec.item_id,
        sec.section_id,
        sec.item_status
    FROM
        order_items_sections sec
    WHERE
        sec.order_id = f_order_id
        AND (f_optional_status IS NULL OR sec.item_status = f_optional_status)
		
	ORDER BY sec.item_id;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_orders(
    f_branch_id INT DEFAULT NULL,
    f_order_type order_type DEFAULT NULL
) RETURNS TABLE (
    fn_order_id INT,
    fn_customer_id INT,
    fn_branch_id INT,
    fn_order_date TIMESTAMPTZ,
    fn_ship_date TIMESTAMPTZ,
    fn_order_type order_type,
    fn_order_status order_status_type,
    fn_order_total_price NUMERIC(10,2),
    fn_order_customer_discount NUMERIC(4,2),
    fn_order_payment_method payment_method_type,
    fn_virtual_room BOOLEAN
) LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
    SELECT 
    order_id ,
    customer_id ,
    branch_id ,
    order_date ,
    ship_date ,
    order_type ,
    order_status ,
    order_total_price ,
    order_customer_discount ,
    order_payment_method ,
    virtual_room
    
    FROM orders
    
    WHERE (branch_id = f_branch_id OR f_branch_id IS NULL)
    AND (order_type = f_order_type OR f_order_type IS NULL);
END;
$$;