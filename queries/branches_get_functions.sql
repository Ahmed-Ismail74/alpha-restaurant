-- function to get tables of specific branch 
-- SELECT * FROM fn_get_branch_tables(1);
CREATE OR REPLACE FUNCTION fn_get_branch_tables(
    fn_branch_id INT,
    fn_table_status table_status_type DEFAULT NULL
    )
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
        IF fn_table_status IS NULL THEN 
            RETURN QUERY
                SELECT tab.table_id, tab.table_status, tab.capacity FROM branch_tables tab
                WHERE branch_id = fn_branch_id;
        ELSE
            RETURN QUERY
                SELECT tab.table_id, tab.table_status, tab.capacity FROM branch_tables tab
                WHERE branch_id = fn_branch_id AND tab.table_status = fn_table_status;
        END IF;
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
-- SELECT * FROM fn_get_branch_menu(5)
CREATE OR REPLACE FUNCTION fn_get_branch_menu(fn_branch_id INT)
RETURNS TABLE(
    id INT,
    Item VARCHAR(35),
    item_status menu_item_type,
    item_discount NUMERIC(4, 2),
    item_price NUMERIC(10, 2),
    preparation_time INTERVAL,
    category VARCHAR(35),
    picture_path VARCHAR(255)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    PERFORM branch_id FROM branches WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'branch not found';
    ELSE
        RETURN QUERY
            SELECT br.item_id, menu.item_name, br.item_status, br.item_discount, br.item_price, menu.preparation_time, category_name, menu.picture_path
            FROM branches_menu br
            LEFT JOIN menu_items menu ON menu.item_id = br.item_id
            LEFT JOIN categories ON menu.category_id  = categories.category_id
            WHERE br.branch_id = fn_branch_id;
    END IF;
END;
$$;

-- Function to get price or discount changes of item in all branches 
-- SELECT * FROM fn_get_item_price_changes(100);
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
        RAISE EXCEPTION SQLSTATE '23503' 
        USING MESSAGE = 'Item not found', 
        HINT = 'try to list items and get id of one of them';
    ELSE
        RETURN QUERY
            SELECT vw.id, vw.branch, vw.changed_by, vw.change_type, vw.new_value, vw.previous_value
            FROM vw_branch_price_changes vw
            WHERE item = (SELECT item_name FROM menu_items WHERE item_id = fn_item_id);
    END IF;
END;
$$;



-- Function to get price or discount changes of all menu in one branch  
-- SELECT * FROM fn_get_branch_item_price_changes(200);
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
    WHERE branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION SQLSTATE '23503' 
        USING MESSAGE = 'Branch not found', 
        HINT = 'try to list branches and get id of one of them';
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






CREATE OR REPLACE FUNCTION fn_get_branch_bookings(
    fn_branch_id INT
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
    PERFORM 1 FROM branches br WHERE br.branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Branch not exist';
    ELSE
        RETURN QUERY
            SELECT * FROM bookings bo WHERE bo.branch_id = fn_branch_id;
    END IF;
END;
$$;



-- SELECT * FROM fn_get_bookings_by_status(1,'confirmed');
-- 'pending', 'confirmed', 'cancelled', 'completed'
CREATE OR REPLACE FUNCTION fn_get_bookings_by_status(
    fn_branch_id INT,
    fn_booking_status order_status_type
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
    PERFORM 1 FROM branches br WHERE br.branch_id = fn_branch_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Branch not exist';
    ELSE
        RETURN QUERY
            SELECT * FROM bookings bo 
            WHERE bo.branch_id = fn_branch_id AND bo.booking_status = fn_booking_status;
    END IF;
END;
$$;






CREATE OR REPLACE FUNCTION fn_get_branch_menu_by_time_and_season(
fn_branch_id INT,
fn_time_type item_day_type,
fn_season_id INT
)
RETURNS TABLE(
    id INT,
    Item VARCHAR(35),
    item_status menu_item_type,
    item_discount NUMERIC(4, 2),
    item_price NUMERIC(10, 2),
    preparation_time INTERVAL,
    category VARCHAR(35),
    picture_path VARCHAR(255)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN QUERY
        SELECT menu.id,
            menu.Item,
            menu.item_status ,
            menu.item_discount ,
            menu.item_price ,
            menu.preparation_time ,
            menu.category,
            menu.picture_path 
        FROM fn_get_branch_menu(fn_branch_id) menu
        LEFT JOIN items_type_day_time tp ON menu.id = tp.item_id
        JOIN items_seasons seas 
        ON seas.season_id = fn_season_id AND seas.item_id = tp.item_id
        WHERE tp.item_type = fn_time_type;
END;
$$;


-- get branch menu and filtter it OR get General branch 
-- SELECT * FROM filter_menu_items(1);
CREATE OR REPLACE FUNCTION filter_menu_items(
    p_branch_id INT,
    p_season_id INT DEFAULT NULL ,
    p_item_type item_day_type DEFAULT NULL ,
    p_category_id INT DEFAULT NULL,
    p_item_status menu_item_type DEFAULT NULL,
    p_vegetarian BOOLEAN DEFAULT NULL,
    p_healthy BOOLEAN DEFAULT NULL
)
RETURNS TABLE (
    item_id INT,
    item_name VARCHAR(35),
    category_id INT,
    item_description VARCHAR(254),
    preparation_time INTERVAL,
    picture_path VARCHAR(255),
    vegetarian BOOLEAN,
    healthy BOOLEAN,
    item_status menu_item_type,
    discount NUMERIC(4, 2),
    price NUMERIC(10, 2),
    average_rating NUMERIC(3, 2),
    raters_number INT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mi.item_id,
        mi.item_name,
        mi.category_id,
        mi.item_description,
        mi.preparation_time,
        mi.picture_path,
        mi.vegetarian,
        mi.healthy,
        br_menu.item_status,
        br_menu.item_discount,
        br_menu.item_price,
        rat.average_rating,
        rat.raters_number
    FROM 
        branches_menu br_menu
    LEFT JOIN
        menu_items mi ON mi.item_id = br_menu.item_id
    LEFT JOIN 
        items_seasons iss ON mi.item_id = iss.item_id
    LEFT JOIN 
        seasons s ON iss.season_id = s.season_id
    LEFT JOIN 
        items_type_day_time itd ON mi.item_id = itd.item_id
    LEFT JOIN 
        average_ratings rat ON mi.item_id = rat.item_id
    WHERE 
        br_menu.branch_id = p_branch_id AND
        (p_item_status IS NULL OR br_menu.item_status = p_item_status) AND


        (p_vegetarian IS NULL OR mi.vegetarian = p_vegetarian) AND
        (p_healthy IS NULL OR mi.healthy = p_healthy) AND


        (p_season_id IS NULL OR s.season_id = p_season_id) AND
        (p_item_type IS NULL OR itd.item_type = p_item_type) AND
        (p_category_id IS NULL OR mi.category_id = p_category_id);
END;
$$;



CREATE OR REPLACE FUNCTION compare_branches()
RETURNS TABLE(
    branch_id INT,
    branch_name VARCHAR(35),
    total_sales NUMERIC,
    total_orders BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.branch_id,
        b.branch_name,
        COALESCE(SUM(o.order_total_price), 0) AS total_sales,
        COUNT(o.order_id) AS total_orders
    FROM branches b
    LEFT JOIN orders o ON o.branch_id = b.branch_id
    GROUP BY b.branch_id, b.branch_name
    ORDER BY total_sales DESC;
END;
$$;

CREATE OR REPLACE FUNCTION get_branch_performance(fn_branch_id INT)
RETURNS TABLE(
    sales_date DATE,
    total_sales NUMERIC,
    total_orders BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.order_date::DATE AS sales_date,
        COALESCE(SUM(o.order_total_price), 0) AS total_sales,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    WHERE o.branch_id = fn_branch_id
    GROUP BY sales_date
    ORDER BY sales_date DESC
    LIMIT 30;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION get_overall_performance()
RETURNS TABLE(
    sales_date DATE,
    total_sales NUMERIC,
    total_orders BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.order_date::DATE AS sales_date,
        COALESCE(SUM(o.order_total_price), 0) AS total_sales,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    GROUP BY sales_date
    ORDER BY sales_date DESC
    LIMIT 30;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_section_overview(fn_section_id INT)
RETURNS TABLE(
    total_sales NUMERIC,
    total_orders BIGINT,
    num_employees BIGINT
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        COALESCE(SUM(o.order_total_price), 0) AS total_sales,
        COUNT(o.order_id) AS total_orders,
        COUNT(DISTINCT e.employee_id) AS num_employees
    FROM orders o
    JOIN branches b ON o.branch_id = b.branch_id
    JOIN branch_sections bs ON b.branch_id = bs.branch_id
    JOIN branches_staff eb ON eb.branch_id = b.branch_id
    JOIN employees e ON e.employee_id = eb.employee_id
    WHERE bs.section_id = fn_section_id;
END;
$$ LANGUAGE plpgsql;

