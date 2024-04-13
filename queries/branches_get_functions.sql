-- function to get tables of specific branch 
-- SELECT * FROM fn_get_branch_tables(1);
CREATE OR REPLACE FUNCTION fn_get_branch_tables(fn_branch_id INT)
RETURNS TABLE(
    table_id INT,
    table_status table_status_type,
    capacity SMALLINT
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM branch_id FROM branches WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Branch not found';
    ELSE
        RETURN QUERY
            SELECT tab.table_id, tab.table_status, tab.capacity FROM branch_tables tab
            WHERE branch_id = fn_branch_id;
    END IF;
END;
$$;


-- get recipes of specific item 
-- SELECT * FROM fn_get_item_recipes(2);
CREATE OR REPLACE FUNCTION fn_get_item_recipes(fn_item_id INT)
RETURNS TABLE(
    ingredient VARCHAR(35),
    quantity NUMERIC(5, 3),
    unit ingredients_unit_type,
    recipe_status recipe_type
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM item_id FROM menu_items WHERE item_id = fn_item_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item not found';
    ELSE
        RETURN QUERY
            SELECT ing.ingredients_name, rec.quantity, ing.recipe_ingredients_unit, rec.recipe_status
            FROM recipes rec
            LEFT JOIN ingredients ing ON ing.ingredient_id = rec.ingredient_id
            WHERE item_id = fn_item_id;
    END IF;
END;
$$;


-- function to get all menu of specific branch
-- SELECT * FROM fn_get_branch_menu(2)
CREATE OR REPLACE FUNCTION fn_get_branch_menu(fn_branch_id INT)
RETURNS TABLE(
    id INT,
    Item VARCHAR(35),
    item_status menu_item_type,
    item_discount NUMERIC(4, 2),
    item_price NUMERIC(10, 2),
    preparation_time INTERVAL,
    category VARCHAR(35)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM branch_id FROM branches WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'branch not found';
    ELSE
        RETURN QUERY
            SELECT br.item_id, menu.item_name, br.item_status, br.item_discount, br.item_price, menu.preparation_time, category_name
            FROM branches_menu br
            LEFT JOIN menu_items menu ON menu.item_id = br.item_id
            LEFT JOIN categories ON menu.category_id  = categories.category_id
            WHERE br.branch_id = fn_branch_id;
    END IF;
END;
$$;

-- Function to get branch menu by item time
-- SELECT * FROM fn_get_branch_menu_by_time(2,'lunch');
CREATE OR REPLACE FUNCTION fn_get_branch_menu_by_time(
    fn_branch_id INT,
    fn_time_type item_day_type
)
RETURNS TABLE(
    id INT,
    Item VARCHAR(35),
    item_status menu_item_type,
    item_discount NUMERIC(4, 2),
    item_price NUMERIC(10, 2),
    preparation_time INTERVAL,
    category VARCHAR(35)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM fn_get_branch_menu(fn_branch_id) menu
        WHERE menu.id IN (
            SELECT item_id FROM items_type_day_time 
            WHERE item_type = fn_time_type
        );
END;
$$;

-- Function to get price or discount changes of item in all branches 
-- SELECT * FROM fn_get_item_price_changes(1);
CREATE OR REPLACE FUNCTION fn_get_item_price_changes(
    fn_item_id INT
)
RETURNS TABLE(
    id INT,
    branch VARCHAR(35),
    changed_by TEXT,
    change_type varchar(10),
    new_value NUMERIC(10, 2),
    previous_value NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM menu_items 
    WHERE item_id = fn_item_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'item not found';
    ELSE
        RETURN QUERY
            SELECT vw.id, vw.branch, vw.changed_by, vw.change_type, vw.new_value, vw.previous_value
            FROM vw_branch_price_changes vw
            WHERE item = (SELECT item_name FROM menu_items WHERE item_id = fn_item_id);
    END IF;
END;
$$;



-- Function to get price or discount changes of all menu in one branch  
-- SELECT * FROM fn_get_branch_item_price_changes(1);
CREATE OR REPLACE FUNCTION fn_get_branch_item_price_changes(
    fn_branch_id INT
)
RETURNS TABLE(
    id INT,
    item VARCHAR(35),
    changed_by TEXT,
    change_type varchar(10),
    new_value NUMERIC(10, 2),
    previous_value NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM branches 
    WHERE fn_branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'branch not found';
    ELSE
        RETURN QUERY
            SELECT vw.id, vw.item, vw.changed_by, vw.change_type, vw.new_value, vw.previous_value
            FROM vw_branch_price_changes vw
            WHERE vw.branch = (SELECT branch_name FROM branches WHERE branch_id = fn_branch_id);
    END IF;
END;
$$;


-- get the stock of specific branch
-- SELECT * FROM fn_get_stock_branch(2);
CREATE OR REPLACE FUNCTION fn_get_stock_branch(fn_branch_id INT)
RETURNS TABLE(
    id INT,
    ingredient VARCHAR(35),
    quantity NUMERIC(12, 3),
    shipment_unit ingredients_unit_type,
    recipe_unit ingredients_unit_type
    
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM branches WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'branch no found';
    ELSE
        RETURN QUERY
            SELECT ing.ingredient_id, ing.ingredients_name, st.ingredients_quantity, ing.shipment_ingredients_unit, ing.recipe_ingredients_unit
            FROM branches_stock st
            LEFT JOIN ingredients ing ON ing.ingredient_id = st.ingredient_id
            WHERE st.branch_id = fn_branch_id;
    END IF;
END;
$$;

-- Function to get sections of specific branch 
-- SELECT * FROM fn_get_branch_sections(2);
CREATE OR REPLACE FUNCTION fn_get_branch_sections(fn_branch_id INT)
RETURNS TABLE(
    id INT,
    name VARCHAR(35),
    manager TEXT,
    section_description VARCHAR(254)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM 1 FROM branches WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Branch not found';
    ELSE
        RETURN QUERY
            SELECT br_sec.section_id, sec.section_name, (emp.employee_first_name || ' ' || emp.employee_last_name) AS emp_name , sec.section_description
            FROM branch_sections br_sec
            LEFT JOIN sections sec ON sec.section_id = br_sec.section_id
            LEFT JOIN employees emp ON emp.employee_id = br_sec.manager_id
            WHERE br_sec.branch_id = fn_branch_id;
    END IF; 
END;
$$;



