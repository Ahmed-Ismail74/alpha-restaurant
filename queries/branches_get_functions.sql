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

CREATE OR REPLACE FUNCTION compare_branches(days_input INT DEFAULT NULL)
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
    WHERE 
        days_input IS NULL OR o.order_date >= CURRENT_DATE - INTERVAL '1 day' * days_input
    GROUP BY b.branch_id, b.branch_name
    ORDER BY total_sales DESC;
END;
$$;

CREATE OR REPLACE FUNCTION get_branch_performance(fn_branch_id INT, days_input INT DEFAULT NULL)
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
    AND (days_input IS NULL OR o.order_date >= CURRENT_DATE - INTERVAL '1 day' * days_input)
    GROUP BY sales_date
    ORDER BY sales_date DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_overall_performance(days_input INT DEFAULT NULL)
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
    WHERE 
        days_input IS NULL OR o.order_date >= CURRENT_DATE - INTERVAL '1 day' * days_input
    GROUP BY sales_date
    ORDER BY sales_date DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_section_overview(
    section_id_input INT DEFAULT NULL,
    days_input INT DEFAULT NULL
)
RETURNS TABLE(
    section_id INT,
    section_name VARCHAR(35),
    total_orders BIGINT,
    total_items_ordered BIGINT,
    average_section_rating NUMERIC(3, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.section_id,
        s.section_name,
        COUNT(DISTINCT COALESCE(voi.order_id, nvoi.order_id)) AS total_orders,
        COUNT(COALESCE(voi.item_id, nvoi.item_id)) AS total_items_ordered,
        COALESCE(AVG(ar.average_rating), 0) AS average_section_rating
    FROM 
        sections s
        LEFT JOIN categories c ON s.section_id = c.section_id
        LEFT JOIN menu_items mi ON c.category_id = mi.category_id
        LEFT JOIN virtual_orders_items voi ON mi.item_id = voi.item_id
        LEFT JOIN non_virtual_orders_items nvoi ON mi.item_id = nvoi.item_id
        LEFT JOIN average_ratings ar ON mi.item_id = ar.item_id
        LEFT JOIN orders o ON COALESCE(voi.order_id, nvoi.order_id) = o.order_id
    WHERE 
        (section_id_input IS NULL OR s.section_id = section_id_input) AND
        (days_input IS NULL OR o.order_date >= CURRENT_DATE - INTERVAL '1 day' * days_input)
    GROUP BY 
        s.section_id, s.section_name
    ORDER BY 
        s.section_id;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION get_branch_location_coordinates(p_branch_id INT)
RETURNS POINT AS $$
DECLARE
    v_location_coordinates POINT;
BEGIN
    -- Retrieve the location coordinates of the branch
    SELECT location_coordinates
    INTO v_location_coordinates
    FROM branches
    WHERE branch_id = p_branch_id;
    
    -- Check if the branch exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Branch not found for branch_id %', p_branch_id;
    END IF;
    
    -- Return the location coordinates
    RETURN v_location_coordinates;
END;
$$ LANGUAGE plpgsql;
















CREATE OR REPLACE FUNCTION fn_get_employees_data(
    f_branch_id INT DEFAULT NULL,
    f_optional_status employee_status_type DEFAULT NULL
) RETURNS TABLE (
    fn_employee_id INT,
    fn_employee_first_name VARCHAR,
    fn_employee_last_name VARCHAR,
    fn_employee_ssn CHAR(14),
    fn_employee_status employee_status_type,
    fn_employee_gender sex_type,
    fn_employee_date_hired timestamptz,
    fn_position_name varchar(25),
    fn_role  roles_type,
    fn_section_name VARCHAR(35),

    fn_branch_id INT
) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.employee_id,
        e.employee_first_name,
        e.employee_last_name,
        e.employee_ssn,
        e.employee_status,
        e.employee_gender,
        e.employee_date_hired,
        pos.position_name,
        pos.emp_role,
        sec.section_name,

        bs.branch_id
    FROM
        employees e
        LEFT JOIN branches_staff bs ON e.employee_id = bs.employee_id
        LEFT JOIN employees_position e_p ON e.employee_id = e_p.employee_id
        LEFT JOIN positions pos ON e_p.position_id = pos.position_id
        LEFT JOIN sections sec ON bs.section_id = sec.section_id
    
    WHERE
        (f_branch_id IS NULL OR bs.branch_id = f_branch_id)
        AND (f_optional_status IS NULL OR e.employee_status = f_optional_status);
END;
$$;













CREATE OR REPLACE FUNCTION fn_get_branches(
    f_branch_id INT DEFAULT NULL
) RETURNS TABLE (
    fn_branch_id INT,
    fn_branch_name VARCHAR,
    fn_branch_address VARCHAR,
    fn_branch_phone VARCHAR,
    fn_branch_created_date TIMESTAMP,
    fn_location_coordinates POINT,
    fn_coverage SMALLINT,
    fn_manager_name TEXT,
    fn_manager_id INT,
    fn_branch_tables BIGINT
) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.branch_id,
        b.branch_name,
        b.branch_address,
        b.branch_phone,
        b.branch_created_date,
        b.location_coordinates,
        b.coverage,
        (emp.employee_first_name || ' ' || emp.employee_last_name) AS manager_name,
        mang.manager_id,
        COUNT(tab.table_id) AS tables_number
    FROM
        branches b
        LEFT JOIN branches_managers mang ON b.branch_id = mang.branch_id
        LEFT JOIN employees emp ON mang.manager_id = emp.employee_id
        LEFT JOIN branch_tables tab ON tab.branch_id = b.branch_id
    WHERE
        (f_branch_id IS NULL OR b.branch_id = f_branch_id)
    GROUP BY
        b.branch_id, b.branch_name, b.branch_address, b.branch_phone, b.branch_created_date, b.location_coordinates::TEXT, b.coverage, emp.employee_first_name, emp.employee_last_name, mang.manager_id;
END;
$$;











CREATE OR REPLACE FUNCTION fn_get_sales(
    f_branch_id INT DEFAULT NULL,
    f_item_id INT DEFAULT NULL,
    f_start_date TIMESTAMPTZ DEFAULT NULL,
    f_end_date TIMESTAMPTZ DEFAULT NULL
) RETURNS TABLE (
    fn_branch_id INT,
    fn_branch_name VARCHAR,
    fn_item_id INT,
    fn_item_name VARCHAR,
    fn_total_sales NUMERIC,
    fn_sales_count BIGINT
) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.branch_id,
        b.branch_name,
        mi.item_id,
        mi.item_name,
        SUM(oi.quantity * oi.quote_price) AS total_sales,
        COUNT(oi.item_id) AS sales_count
    FROM
        branches b
        JOIN orders o ON b.branch_id = o.branch_id
        JOIN non_virtual_orders_items oi ON o.order_id = oi.order_id
        JOIN menu_items mi ON oi.item_id = mi.item_id
    WHERE
        (f_branch_id IS NULL OR b.branch_id = f_branch_id)
        AND (f_item_id IS NULL OR mi.item_id = f_item_id)
        AND (f_start_date IS NULL OR o.order_date >= f_start_date)
        AND (f_end_date IS NULL OR o.order_date <= f_end_date)
    GROUP BY
        b.branch_id, b.branch_name, mi.item_id, mi.item_name;
END;
$$;