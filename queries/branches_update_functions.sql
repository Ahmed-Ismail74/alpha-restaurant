-- change price or discount of item in branch menu
-- SELECT * FROM fn_change_item_price(1,1,1, 'discount', 30);
CREATE OR REPLACE FUNCTION fn_change_item_price(
    fn_item_id INT,
    fn_branch_id INT,
    fn_changer INT,
    fn_change_type varchar(10),
    fn_new_value NUMERIC(10, 2)
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
DECLARE 
    fn_previous_value INT;
BEGIN
    PERFORM 1 FROM employees WHERE employee_id = fn_changer;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee not found';
    ELSE
        PERFORM 1 FROM branches_menu 
        WHERE branch_id = fn_branch_id AND item_id = fn_item_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'item not found in branch menu';
        ELSE
            EXECUTE format('SELECT item_%I FROM branches_menu WHERE branch_id = $1 AND item_id = $2', fn_change_type)
            INTO fn_previous_value
            USING fn_branch_id, fn_item_id;

            EXECUTE format('UPDATE branches_menu 
                            SET item_%I = $1
                            WHERE branch_id = $2 AND item_id = $3', fn_change_type)
            USING fn_new_value, fn_branch_id, fn_item_id;

            INSERT INTO items_price_changes(branch_id, item_id, item_cost_changed_by, change_type, new_value, previous_value)
            VALUES(fn_branch_id, fn_item_id, fn_changer, fn_change_type, fn_new_value, fn_previous_value);
        END IF;
    END IF;
END;
$$;




-- Function to change stock quantity of ingredient if exist 
-- if ingerdient not exist will add it to the stock using pr_add_ingredient_to_branch_stock
-- SELECT * FROM fn_update_stock(1,3,500);
CREATE OR REPLACE FUNCTION fn_update_stock
(
    fn_branch_id INT,
    fn_ingredient_id INT,
    fn_quantity NUMERIC(12, 3)
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM branches WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'branch no found';
    ELSE
        PERFORM 1 FROM branches_stock 
        WHERE branch_id = fn_branch_id AND ingredient_id = fn_ingredient_id;
        IF FOUND THEN
            UPDATE branches_stock
            SET ingredients_quantity = ingredients_quantity + fn_quantity
            WHERE branch_id = fn_branch_id AND ingredient_id = fn_ingredient_id;
            RAISE NOTICE 'ingerdient updated at stock';
        ELSE
            CALL pr_add_ingredient_to_branch_stock(fn_branch_id, fn_ingredient_id, fn_quantity);
            RAISE NOTICE 'ingerdient added to stock';
        END IF;
    END IF;
END;
$$;

