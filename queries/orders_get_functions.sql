-- get orders of 
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
    order_payment_method payment_method_type
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
            ord.order_payment_method FROM orders ord

            LEFT JOIN branches br ON br.branch_id = ord.branch_id
            
            WHERE customer_id = fn_customer_id
            ORDER BY ord.order_date DESC
            LIMIT fn_limit;
    END IF;
END;
$$;





-- SELECT * FROM fn_get_customer_orders(2,2);
CREATE OR REPLACE FUNCTION fn_get_order_details(
    fn_order_id INT,
)
RETURNS TABLE(
    
)
LANGUAGE PLPGSQL
AS $$
BEGIN

END;
$$