
-- FUNCTION to add new branch
CREATE OR REPLACE FUNCTION fn_add_branch(
	f_branch_name VARCHAR(35),
	f_branch_address VARCHAR(95) ,
	f_location_coordinates POINT ,
	f_coverage SMALLINT DEFAULT 10,
	f_branch_phone VARCHAR(15) DEFAULT NULL,
	f_manager_id INT DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_branch_id INT;
BEGIN
	IF NOT EXISTS (SELECT 1 FROM branches WHERE f_branch_name = branch_name) THEN

		INSERT INTO branches(branch_name,branch_address,branch_phone, location_coordinates, coverage)
		VALUES(f_branch_name,f_branch_address,f_branch_phone, f_location_coordinates, f_coverage)
		RETURNING branch_id INTO f_branch_id;
		
		IF f_manager_id IS NOT NULL THEN
			INSERT INTO branches_managers VALUES(f_branch_id, f_manager_id);
		END IF;
		RETURN 'Branch added';
	ELSE
		RETURN 'Branch Existed';
	END IF;
END;
$$;



-- FUNCTION to add new table
CREATE OR REPLACE FUNCTION fn_add_table(
	f_branch_id INT,
	f_capacity INT,
	f_table_status table_status_type DEFAULT 'available'
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO branch_tables(branch_id,capacity, table_id, table_status)
	VALUES (f_branch_id,
			f_capacity,
			nextval('branch_' || f_branch_id || '_table_id_seq'),
			f_table_status);
END;
$$;

-- FUNCTION to add new general section
CREATE OR REPLACE FUNCTION fn_add_general_section(
	f_section_name VARCHAR(35),
	f_section_description VARCHAR(254)
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO sections (section_name, section_description)VALUES (f_section_name, f_section_description);
END;
$$;

-- Funtion to add section to branch
CREATE OR REPLACE FUNCTION fn_add_branch_sections(
	fn_branch_id INT,
	fn_section_id INT,
	fn_manager_id INT DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO branch_sections(branch_id,section_id,manager_id)
	VALUES(fn_branch_id,fn_section_id,fn_manager_id);
	RETURN 'section added to branch';
END;
$$;

-- FUNCTION to add new category 
CREATE OR REPLACE PROCEDURE pr_add_category(
	f_section_id INT,
	f_category_name VARCHAR(35),
	f_category_description VARCHAR(254)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO categories (section_id, category_name, category_description)
	VALUES (f_section_id, f_category_name, f_category_description);
END;
$$;


-- Procedure to add new ingredient
CREATE OR REPLACE PROCEDURE pr_add_ingredient(
	pr_ingredients_name VARCHAR(35),
	pr_recipe_ingredients_unit ingredients_unit_type ,
	pr_shipment_ingredients_unit	ingredients_unit_type
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM ingredients WHERE pr_ingredients_name = ingredients_name;
	IF FOUND THEN
		RETURN;
	ELSE
		INSERT INTO ingredients(ingredients_name, recipe_ingredients_unit, shipment_ingredients_unit)
		VALUES (pr_ingredients_name, pr_recipe_ingredients_unit, pr_shipment_ingredients_unit);
	END IF;
END;
$$;
	
-- Procedure to add new ingredient to the branch stock
CREATE OR REPLACE PROCEDURE pr_add_ingredient_to_branch_stock(
	p_branch_id INT,
	p_ingredient_id INT,
	p_ingredients_quantity NUMERIC(12, 3)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM branches_stock WHERE branch_id = p_branch_id AND ingredient_id = p_ingredient_id;
	IF FOUND THEN
		RAISE EXCEPTION 'Ingredient already exist';
	ELSE
		INSERT INTO branches_stock(branch_id, ingredient_id, ingredients_quantity)
		VALUES (p_branch_id, p_ingredient_id, p_ingredients_quantity);
	END IF;
END;
$$;
-- Procedure to add new menu item
CREATE OR REPLACE PROCEDURE pr_add_menu_item(
	p_item_name VARCHAR(35),
	p_item_description VARCHAR(254),
	p_category_id INT,
	p_preparation_time INTERVAL DEFAULT NULL,
	p_picture_path varchar(255) DEFAULT NULL,
	p_vegetarian BOOLEAN DEFAULT FALSE,
	p_healthy BOOLEAN DEFAULT FALSE
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM menu_items WHERE p_item_name = item_name;
	IF FOUND THEN
		RAISE EXCEPTION 'Item already exist';
	ELSE
		INSERT INTO menu_items(item_name, item_description, category_id, preparation_time, picture_path, vegetarian, healthy)
		VALUES (p_item_name, P_item_description, p_category_id, p_preparation_time, p_picture_path, p_vegetarian, p_healthy);
        RAISE NOTICE 'Item added';
	END IF;
END;
$$;

-- Procedure to add an item to a branch menu
CREATE OR REPLACE PROCEDURE pr_add_item_branch_menu(
	p_branch_id INT ,
	p_item_id INT,
	p_item_price NUMERIC(10, 2),
	p_item_status menu_item_type DEFAULT 'active',
	p_item_discount NUMERIC(4, 2) DEFAULT 0
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM branches WHERE p_branch_id = branch_id;
	IF FOUND THEN
		PERFORM 1 FROM menu_items WHERE p_item_id = item_id;
		IF FOUND THEN
            PERFORM 1 FROM branches_menu 
            WHERE branch_id = p_branch_id AND item_id = p_item_id;
            IF FOUND THEN
                RAISE EXCEPTION 'Item already added to branch menu';
            ELSE
                INSERT INTO branches_menu(branch_id, item_id, item_status, item_price, item_discount)
			    VALUES (p_branch_id, p_item_id, p_item_status, p_item_price, p_item_discount);
            END IF;
			
		ELSE
			RAISE EXCEPTION 'Item not found';
		END IF;
	ELSE
		RAISE EXCEPTION 'branch not found';
	END IF;
END;
$$;


-- FUNCTION to recipes of menu item
-- SELECT * FROM fn_add_recipes(2, 1, 5, 'optional');

CREATE OR REPLACE PROCEDURE pr_add_recipes(
	p_item_id INT,
	p_ingredient_id INT,
	p_quantity NUMERIC(5, 3) ,
	p_recipe_status recipe_type DEFAULT 'required'
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM ingredients WHERE ingredient_id = p_ingredient_id;
	IF FOUND THEN
		PERFORM 1 FROM menu_items WHERE item_id = p_item_id;
		IF FOUND THEN
			INSERT INTO recipes(ingredient_id, item_id, quantity, recipe_status)
			VALUES(p_ingredient_id, p_item_id, p_quantity, p_recipe_status);
            RAISE NOTICE 'Recipe added';
        ELSE
            RAISE EXCEPTION 'item not found';
		END IF;
	END IF;
END;
$$;

SELECT setting
FROM pg_settings
WHERE name = 'client_min_messages';

-- Function to add item time type breakfast, lunch, ....
-- SELECT * FROM fn_add_item_time(1,'lunch');
-- SELECT * FROM fn_add_item_time(2,'brunch');
CREATE OR REPLACE FUNCTION fn_add_item_time(
	fn_item_id INT,
	fn_type item_day_type
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM menu_items WHERE item_id = fn_item_id;
	IF NOT FOUND THEN 
		RAISE EXCEPTION 'Item not found in menu';
	ELSE
		PERFORM 1 FROM items_type_day_time 
		WHERE item_id = fn_item_id AND item_type = fn_type;
		IF FOUND THEN
			RAISE EXCEPTION 'Item spicified to this type before';
		ELSE
			INSERT INTO items_type_day_time
			VALUES(fn_item_id, fn_type);
		END IF;
	END IF;
END;
$$;

-- Function to add seasons which resturant serve a meals in them
-- SELECT * FROM fn_add_season('Ramadan', 'During Ramadan, restaurants adapt their menus to offer iftar buffets and suhoor menus, providing a wide variety of traditional dishes to accommodate fasting individuals and promote communal dining experiences.')
CREATE OR REPLACE FUNCTION fn_add_season(
	fn_season_name VARCHAR(35),
	fn_season_description VARCHAR(254)
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM seasons
	WHERE season_name = fn_season_name;
	IF FOUND THEN
		RAISE EXCEPTION 'Season already exist';
	ELSE
		INSERT INTO seasons(season_name, season_description)
		VALUES (fn_season_name, fn_season_description);
		RAISE NOTICE 'Season added';
	END IF;
END;
$$;


-- Function to add item to specific season
-- SELECT * FROM fn_add_item_time(1,1);
CREATE OR REPLACE FUNCTION fn_add_item_season(
	fn_item_id INT,
	fn_season_id INT
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM menu_items WHERE item_id = fn_item_id;
	IF NOT FOUND THEN 
		RAISE EXCEPTION 'Item not found in menu';
	ELSE
		PERFORM 1 FROM items_seasons 
		WHERE fn_season_id = season_id AND item_id = fn_item_id;
		IF FOUND THEN
			RAISE EXCEPTION 'Item spicified to this season before';
		ELSE
			INSERT INTO items_seasons(season_id, item_id)
			VALUES(fn_season_id, fn_item_id);
		END IF;
	END IF;
END;
$$;
