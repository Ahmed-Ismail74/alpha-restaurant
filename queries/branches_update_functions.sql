-- change price or discount of item in branch menu
-- SELECT * FROM fn_change_item_price(1,1,1, 'discount', 30);

CREATE OR REPLACE PROCEDURE pr_change_item_price(
    fn_item_id INT,
    fn_branch_id INT,
    fn_changer INT,
    fn_change_type varchar(10),
    fn_new_value NUMERIC(10, 2)
)
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









CREATE OR REPLACE PROCEDURE pr_change_branch_manager(
    fn_branch_id INT,
    fn_new_manager_id INT,
    fn_position_changer_id INT
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    fn_previous_position_id INT;
    branch_manager_position_id INT;
BEGIN
    -- Get the position_id for 'branch manager'
    SELECT position_id INTO branch_manager_position_id 
    FROM positions 
    WHERE position_name = 'branch manager';

    -- Check if the branch exists
    IF EXISTS(SELECT 1 FROM branches WHERE branch_id = fn_branch_id) THEN

        -- Check if the position changer has the correct permissions
        IF fn_position_changer_id IN (
            SELECT employee_id FROM employees_position 
            WHERE position_id IN (
                SELECT position_id FROM positions
                WHERE position_name IN ('hr', 'operation manager')
            )
        ) THEN

            -- Get the current position of the new manager
            SELECT position_id INTO fn_previous_position_id 
            FROM employees_position 
            WHERE employee_id = fn_new_manager_id;

            -- If the new manager does not have the 'branch manager' position, promote them
            IF fn_previous_position_id != branch_manager_position_id THEN
                INSERT INTO employees_position (employee_id, position_id)
                VALUES (fn_new_manager_id, branch_manager_position_id)
                ON CONFLICT (employee_id, position_id) DO UPDATE
                SET position_id = EXCLUDED.position_id;
                
                -- Insert the change into positions_changes table
                INSERT INTO positions_changes(employee_id, position_changer_id, previous_position, new_position, position_change_type)
                VALUES (fn_new_manager_id, fn_position_changer_id, fn_previous_position_id, branch_manager_position_id, 'promot');
            END IF;

            -- Update the branch manager
            UPDATE branches_managers
            SET manager_id = fn_new_manager_id
            WHERE branch_id = fn_branch_id;

            RAISE NOTICE 'Branch manager changed';
        ELSE
            RAISE EXCEPTION 'Permission denied';
        END IF;
    ELSE
        RAISE EXCEPTION 'Branch does not exist';
    END IF;
END;
$$;









CREATE OR REPLACE PROCEDURE pr_change_section_manager(
    fn_branch_id INT,
    fn_section_id INT,
    fn_new_manager_id INT,
    fn_position_changer_id INT
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    fn_previous_position_id INT;
BEGIN
    -- Check if the branch and section exist
    IF EXISTS(SELECT 1 FROM branch_sections WHERE branch_id = fn_branch_id AND section_id = fn_section_id) THEN

        -- Check if the position changer has the correct permissions
        IF fn_position_changer_id IN (
            SELECT employee_id FROM employees_position 
            WHERE position_id IN (
                SELECT position_id FROM positions
                WHERE position_name IN ('hr', 'operation manager')
            )
        ) THEN

            -- Get the current position of the new manager
            SELECT position_id INTO fn_previous_position_id 
            FROM employees_position 
            WHERE employee_id = fn_new_manager_id;

            -- Update the section manager
            UPDATE branch_sections
            SET manager_id = fn_new_manager_id
            WHERE branch_id = fn_branch_id AND section_id = fn_section_id;

            RAISE NOTICE 'Section manager changed';
        ELSE
            RAISE EXCEPTION 'Permission denied';
        END IF;
    ELSE
        RAISE EXCEPTION 'Branch or section does not exist';
    END IF;
END;
$$;

