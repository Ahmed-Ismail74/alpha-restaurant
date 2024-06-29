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
        RETURN QUERY
        SELECT tab.table_id, tab.table_status, tab.capacity FROM branch_tables tab
        WHERE branch_id = fn_branch_id AND (tab.table_status = fn_table_status OR fn_table_status IS NULL)
        ORDER BY tab.table_id;
    END IF;
END;
$$;

-- get recipes of specific item 
-- SELECT * FROM fn_get_item_recipes(2);
DROP FUNCTION fn_get_item_recipes;
CREATE OR REPLACE FUNCTION fn_get_item_recipes(fn_item_id INT)
RETURNS TABLE(
    id INT,
    ingredient VARCHAR(35),
    quantity NUMERIC(8, 3),
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
            SELECT ing.ingredient_id, ing.ingredients_name, rec.quantity, ing.recipe_ingredients_unit, rec.recipe_status
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
            WHERE br.branch_id = fn_branch_id
            ORDER BY br.item_id;
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
            WHERE br_sec.branch_id = fn_branch_id
            ORDER BY br_sec.section_id;
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
            SELECT * FROM bookings bo WHERE bo.branch_id = fn_branch_id
            ORDER BY booking_id DESC;
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
            WHERE bo.branch_id = fn_branch_id AND bo.booking_status = fn_booking_status
            ORDER BY bo.booking_id DESC;
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
        (p_category_id IS NULL OR mi.category_id = p_category_id)
    ORDER BY mi.item_id;
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
    ORDER BY branch_id;
END;
$$;


CREATE OR REPLACE FUNCTION get_branch_performance(
    fn_branch_id INT DEFAULT NULL,
    days_input INT DEFAULT NULL
    )
RETURNS TABLE(
    branch INT,
    sales_date DATE,
    total_sales NUMERIC,
    total_orders BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.branch_id,
        o.order_date::DATE AS sales_date,
        COALESCE(SUM(o.order_total_price), 0) AS total_sales,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    WHERE o.branch_id = fn_branch_id OR fn_branch_id IS NULL
    AND (days_input IS NULL OR o.order_date >= CURRENT_DATE - INTERVAL '1 day' * days_input)
    GROUP BY branch_id, sales_date
    ORDER BY o.branch_id;
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


CREATE OR REPLACE FUNCTION get_branch_location_coordinates(p_branch_id INT DEFAULT NULL)
RETURNS TABLE(
    branch INT,
    coordinates POINT
) AS $$
DECLARE
    v_location_coordinates POINT;
BEGIN
    -- Retrieve the location coordinates of the branch
    RETURN QUERY
        SELECT branch_id, location_coordinates
        FROM branches
        WHERE branch_id = p_branch_id OR p_branch_id IS NULL;
    
        -- Check if the branch exists
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Branch not found for branch_id %', p_branch_id;
        END IF;
    
END;
$$ LANGUAGE plpgsql;





















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
        b.branch_id, b.branch_name, b.branch_address, b.branch_phone, b.branch_created_date, b.location_coordinates::TEXT, b.coverage, emp.employee_first_name, emp.employee_last_name, mang.manager_id
    ORDER BY b.branch_id;
END;
$$;









SELECT * FROM fn_get_sales(1);
SELECT * FROM fn_get_sales(
    f_branch_id =>1,
    f_start_date=> '2023-08-01',
    f_end_date=> '2024-12-01'
);


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


SELECT * FROM menu_items;
SELECT * FROM get_item_recommendations(4);
SELECT * FROM get_item_recommendations(6);

CREATE OR REPLACE FUNCTION get_item_recommendations(target_item INT)
RETURNS TABLE (consequent INT, lift FLOAT) AS $$
DECLARE
    main_items_limit INT := 4;
    additional_items_limit INT := 3;
BEGIN
    RETURN QUERY
    WITH recommended_items AS (
        SELECT 
            rc.consequent, 
            r.lift,
            CASE
                WHEN rc.consequent IN (1, 2, 3, 4, 5, 6, 7, 8, 12, 13, 14, 15, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 154, 155, 156, 157) THEN 'main'
                WHEN rc.consequent IN (9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 158) THEN 'additional'
            END AS item_type
        FROM 
            rules_fp_growth r
        JOIN 
            rule_antecedents ra ON r.rule_id = ra.rule_id
        JOIN 
            rule_consequents rc ON r.rule_id = rc.rule_id
        WHERE 
            ra.antecedent = target_item
    ),
    ordered_items AS (
        SELECT
            rec.consequent,
            rec.lift,
            rec.item_type,
            ROW_NUMBER() OVER (PARTITION BY item_type ORDER BY rec.lift DESC) AS rn
        FROM 
            recommended_items rec
    )
    SELECT 
        ord.consequent, 
        ord.lift
    FROM 
        ordered_items ord
    WHERE 
        (item_type = 'main' AND rn <= main_items_limit)
        OR (item_type = 'additional' AND rn <= additional_items_limit);
END;
$$ LANGUAGE plpgsql;



DROP FUNCTION get_orders;
CREATE OR REPLACE FUNCTION get_orders(
    p_employee_id INT DEFAULT NULL,
    p_order_type order_type DEFAULT NULL,
    p_branch_id INT DEFAULT NULL,
    p_in_delivered_orders BOOLEAN DEFAULT NULL,
    p_delivery_status delivery_status DEFAULT NULL
)
RETURNS TABLE(
    order_id INT,
    delivery_employee_id INT,
    arrival_date_by_customer timestamptz,
    arrival_date_by_employee timestamptz,
    delivering_status delivery_status,
    branch_id INT,
    customer_address VARCHAR(95),
    customer_city VARCHAR(35),
    location_coordinates POINT,
    customer_phone VARCHAR(15)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ord.order_id,
        delv.delivery_employee_id,
        delv.arrival_date_by_customer,
        delv.arrival_date_by_employee,
        delv.delivering_status,
        ord.branch_id,
        ad.customer_address,
        ad.customer_city,
        ad.location_coordinates,
        ph.customer_phone
    FROM
        orders ord
        LEFT JOIN delivered_orders delv ON ord.order_id = delv.order_id
        LEFT JOIN orders_connecting_details det ON det.order_id = ord.order_id
        LEFT JOIN customers cust ON cust.customer_id = ord.customer_id
        LEFT JOIN customers_addresses_list ad ON det.address_id = ad.address_id
        LEFT JOIN customers_phones_list ph ON det.customer_phone_id = ph.customer_phone_id
    WHERE
        (p_employee_id IS NULL OR delv.delivery_employee_id = p_employee_id)
        AND (p_order_type IS NULL OR ord.order_type = p_order_type)
        AND (p_branch_id IS NULL OR ord.branch_id = p_branch_id)
        AND (p_delivery_status IS NULL OR delv.delivering_status = p_delivery_status)
        AND (
            p_in_delivered_orders IS NULL 
        OR (p_in_delivered_orders IS TRUE AND delv.order_id IS NOT NULL) 
        OR (p_in_delivered_orders IS FALSE AND delv.order_id IS NULL AND ord.order_status != 'completed') 
        )
    ORDER BY ord.order_date DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_get_best_seller_in_each_category(
    f_branch_id INT DEFAULT NULL,
    f_start_date TIMESTAMPTZ DEFAULT NULL,
    f_end_date TIMESTAMPTZ DEFAULT NULL
) RETURNS TABLE (
    fn_category_id INT,
    fn_item_id INT
) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH category_sales AS (
        SELECT
            c.category_id,
            mi.item_id,
            ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY SUM(oi.quantity * oi.quote_price) DESC) AS rn
        FROM
            branches b
            JOIN orders o ON b.branch_id = o.branch_id
            JOIN non_virtual_orders_items oi ON o.order_id = oi.order_id
            JOIN menu_items mi ON oi.item_id = mi.item_id
            JOIN categories c ON mi.category_id = c.category_id
        WHERE
            (f_branch_id IS NULL OR b.branch_id = f_branch_id)
            AND (f_start_date IS NULL OR o.order_date >= f_start_date)
            AND (f_end_date IS NULL OR o.order_date <= f_end_date)
            AND c.category_name NOT IN ('Food extra', 'Drinks extra', 'extras')
        GROUP BY
            c.category_id, c.category_name, mi.item_id, mi.item_name
    )
    SELECT
        category_id,
        item_id
    FROM
        category_sales
    WHERE
        rn = 1;
END;
$$;
