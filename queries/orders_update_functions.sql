-- CALL pr_update_booking_status(1,'confirmed')
CREATE OR REPLACE PROCEDURE pr_update_booking_status(
    fn_booking_id INT,
    fn_new_booking_status order_status_type
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM bookings WHERE booking_id = fn_booking_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not exist';
    ELSE
        UPDATE bookings
        SET booking_status = fn_new_booking_status
        WHERE booking_id = fn_booking_id;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE pr_change_order_status(
    fn_order_id INT,
    fn_order_status order_status_type
)
LANGUAGE PLPGSQL
AS $$
DECLARE
fn_old_status order_status_type;
BEGIN
    SELECT order_status INTO fn_old_status FROM orders WHERE order_id = fn_order_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not exist';
    ELSE
        IF fn_old_status != 'pending' AND fn_order_status = 'cancelled' THEN
            RAISE EXCEPTION 'Can not cancel confirmed orders';
        ELSE
            UPDATE orders
            SET order_status = fn_order_status
            WHERE order_id = fn_order_id AND NOT (fn_order_status = 'cancelled' AND order_status != 'pending');
        END IF;
    END IF;
END;
$$;
