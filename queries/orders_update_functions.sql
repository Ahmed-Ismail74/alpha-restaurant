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
