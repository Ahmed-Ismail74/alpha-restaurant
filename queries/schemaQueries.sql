	-- SELECT * FROM pg_indexes where table_name = 'customers';

	-- CREATE INDEX idx_text ON customers USING HASH (custfirstname);
	-- drop index idx_text;

	-- EXPLAIN SELECT * FROM customers WHERE custfirstname LIKE 'a%';

	-- Delete all Tables
	DO $$ 
	DECLARE 
		tableName TEXT; 
	BEGIN 
		FOR tableName IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' and table_type = 'BASE TABLE' LOOP 
			EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tableName) || ' CASCADE'; 
		END LOOP;
		
	END $$;


	-- Employees Tables
	CREATE TABLE IF NOT EXISTS employees(
		employee_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY ,
		employee_ssn CHAR(14) UNIQUE NOT NULL,
		employee_first_name VARCHAR(35) NOT NULL,
		employee_last_name VARCHAR(35) NOT NULL,
		employee_birthdate DATE,
		employee_address VARCHAR(255),
		employee_date_hired timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
		employee_status employee_status_type NOT NULL,
		employee_gender sex_type NOT NULL,
		employee_salary INT NOT NULL CHECK (employee_salary > 3000)
	);
	CREATE TABLE IF NOT EXISTS employees_accounts(
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		employee_email varchar(254) NOT NULL UNIQUE,
		employee_password varchar(60) NOT NULL,
		account_created_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
		picture_path varchar(255),

		PRIMARY KEY (employee_id)
	);

	CREATE TABLE IF NOT EXISTS salary_changes(
		salary_change_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		change_made_by INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		change_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
		old_salary int NOT NULL CHECK (old_salary > 3000),
		change_reason varchar(250)
	);

	CREATE TABLE IF NOT EXISTS employees_transfers(
		transfer_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		old_branch_id INT,
		new_branch_id INT , -- Foreign key altered after create branch table
		transfer_made_by INT ,
		transfer_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
		transfer_reason varchar(250)
	);

	CREATE TABLE IF NOT EXISTS employees_call_list(
		employee_phone_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		employee_phone VARCHAR(15) NOT NULL CHECK (employee_phone ~ '^[0-9]+$') UNIQUE
	);


	-- CREATE TABLE IF NOT EXISTS employees_addresses_list(
	-- 	employee_address_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	-- 	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	-- 	employees_address VARCHAR(95) NOT NULL,
	-- 	city varchar(35),
	-- 	location_coordinates point
	-- );

	CREATE TABLE IF NOT EXISTS employee_vacations(
		vacation_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		vacation_start_date TIMESTAMPTZ NOT NULL,
		vacation_end_date TIMESTAMPTZ NOT NULL,
		vacation_reason varchar(255) NOT NULL
	);

	CREATE TABLE IF NOT EXISTS employee_schedule(
		schedule_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		shift_start_time TIMESTAMPTZ,
		shift_end_time TIMESTAMPTZ NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  employee_attendance(
		schedule_id INT REFERENCES employee_schedule ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		date_in TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
		date_out TIMESTAMPTZ DEFAULT NULL,
		PRIMARY KEY (schedule_id, employee_id)
	);

	CREATE TABLE IF NOT EXISTS positions(
		position_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		position_name varchar(25) NOT NULL UNIQUE,
		job_description varchar(255),
		emp_role roles_type DEFAULT 'no role'
	);
	CREATE TABLE IF NOT EXISTS positions_changes(
		position_change_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		position_changer_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		previous_position INT REFERENCES positions (position_id),
		new_position INT REFERENCES positions (position_id),
		position_change_type position_change_type NOT NULL,
		position_change_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS  employees_position(
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		position_id INT REFERENCES positions ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		PRIMARY KEY (employee_id, position_id)
	);

	-- Clients Tables
	CREATE TABLE IF NOT EXISTS customers(
		customer_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		customer_first_name VARCHAR(35) NOT NULL,
		customer_last_name VARCHAR(35) NOT NULL,
		customer_gender sex_type NOT NULL,
		customer_birthdate DATE
	);

	CREATE TABLE IF NOT EXISTS  customers_addresses_list(
		address_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_address VARCHAR(95) NOT NULL,
		customer_city VARCHAR(35),
		location_coordinates POINT
	);
	CREATE TABLE IF NOT EXISTS  customers_phones_list(
		customer_phone_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_phone VARCHAR(15) NOT NULL CHECK (customer_phone ~ '^[0-9]+$')	
	);


	CREATE TABLE IF NOT EXISTS customers_accounts(
		account_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_phone_id INT REFERENCES customers_phones_list ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_password varchar(60) NOT NULL,
		account_created_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
		picture_path varchar(255)
	);

	CREATE TABLE IF NOT EXISTS  friends_requests(
		friendship_request_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		sender_account_id INT REFERENCES customers_accounts (account_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		receiver_account_id INT REFERENCES customers_accounts (account_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		friend_request_status friend_request_type DEFAULT 'pending' ,
		request_reply_time TIMESTAMP DEFAULT NULL
	);

	CREATE TABLE IF NOT EXISTS  friendships(
		friendship_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		account_id_sender INT REFERENCES customers_accounts(account_id) NOT NULL,
		account_id_receiver	INT REFERENCES customers_accounts(account_id) NOT NULL,
		friendship_request_id INT REFERENCES friends_requests NOT NULL,
		since TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
	);




	-- Orgnization Tables

	CREATE TABLE IF NOT EXISTS  sections(
		section_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		section_name VARCHAR(35) UNIQUE NOT NULL,
		section_description VARCHAR(254)
	);

	CREATE TABLE IF NOT EXISTS  categories(
		category_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		section_id INT REFERENCES sections ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		category_name VARCHAR(35) UNIQUE NOT NULL,
		category_description VARCHAR(254)
	);

	CREATE TABLE IF NOT EXISTS  branches(
		branch_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		branch_name VARCHAR(35) UNIQUE NOT NULL,
		branch_address VARCHAR(95) NOT NULL,
		branch_phone VARCHAR(15) CHECK (branch_phone  ~ '^[0-9]+$') UNIQUE,
		branch_created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
		location_coordinates POINT NOT NULL,
		coverage SMALLINT DEFAULT 10
	);

	CREATE TABLE IF NOT EXISTS  branches_managers(
		branch_id INT REFERENCES branches (branch_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		manager_id INT REFERENCES employees (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
		PRIMARY KEY(branch_id, manager_id)
		
	);

	ALTER TABLE employees_transfers ADD CONSTRAINT  employees_transfers_manager_id_fkey
	FOREIGN KEY (old_branch_id, transfer_made_by) 
	REFERENCES branches_managers(branch_id, manager_id) ON DELETE RESTRICT ON UPDATE CASCADE;


	ALTER TABLE employees_transfers ADD CONSTRAINT  employees_transfers_new_branch_id_fkey
	FOREIGN KEY (new_branch_id) 
	REFERENCES branches(branch_id) ON DELETE RESTRICT ON UPDATE CASCADE;


	CREATE TABLE IF NOT EXISTS  storages(
		storage_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		storage_name VARCHAR(35) NOT NULL UNIQUE,
		manager_id INT REFERENCES employees (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
		storage_address VARCHAR(95) NOT NULL
	);


	CREATE TABLE IF NOT EXISTS  ingredients(
		ingredient_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		ingredients_name VARCHAR(35),
		recipe_ingredients_unit ingredients_unit_type ,
		shipment_ingredients_unit	ingredients_unit_type
	);


	CREATE TABLE IF NOT EXISTS  branch_sections(
		branch_id INT REFERENCES branches NOT NULL,
		section_id INT REFERENCES sections NOT NULL,
		manager_id INT REFERENCES employees (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
		PRIMARY KEY (branch_id, section_id)
	);
	-- create Index


	CREATE TABLE IF NOT EXISTS  branch_tables(
		branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		table_id INT NOT NULL ,
		table_status table_status_type,
		capacity SMALLINT CHECK (capacity >= 0) NOT NULL,
		PRIMARY KEY (branch_id, table_id)
	);


	-- Create a sequence for table_id specific to each branch
	CREATE OR REPLACE FUNCTION create_branch_table_sequence() RETURNS TRIGGER AS $$
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM pg_sequences WHERE sequencename = 'branch_' || NEW.branch_id || '_table_id_seq') THEN
			EXECUTE 'CREATE SEQUENCE branch_' || NEW.branch_id || '_table_id_seq';
		END IF;
		RETURN NULL;
	END;
	$$ LANGUAGE plpgsql;

	-- CREATE OR REPLACE FUNCTION delete_branch_table_sequences() RETURNS VOID AS $$
	-- DECLARE
	--     seq_record RECORD;
	-- BEGIN
	--     FOR seq_record IN 
	--         SELECT sequencename 
	--         FROM pg_sequences 
	--         WHERE sequencename LIKE 'branch\_%\_table\_id\_seq' ESCAPE '\'
	--     LOOP
	--         EXECUTE 'DROP SEQUENCE ' || seq_record.sequencename;
	--     END LOOP;
	-- END;
	-- $$ LANGUAGE plpgsql;

	-- SELECT delete_branch_table_sequences();

	CREATE TRIGGER create_branch_table_sequence_trigger
	AFTER INSERT ON branches
	FOR EACH ROW EXECUTE FUNCTION create_branch_table_sequence();


	-- create Index

	CREATE TABLE IF NOT EXISTS  branches_stock(
		branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredients_quantity NUMERIC(12, 3) CHECK (ingredients_quantity >= 0)
	);

	CREATE TABLE IF NOT EXISTS  menu_items	(
		item_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		item_name VARCHAR(35) NOT NULL UNIQUE,
		category_id INT REFERENCES categories ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_description VARCHAR(254) NOT NULL,
		preparation_time INTERVAL,
		picture_path varchar(255),
		vegetarian BOOLEAN DEFAULT FALSE NOT NULL,
		healthy BOOLEAN DEFAULT FALSE NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  branches_menu(
		branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_status menu_item_type,
		item_discount NUMERIC(4, 2) check (item_discount >= 0) DEFAULT 0 NOT NULL,
		item_price NUMERIC(10, 2) check (item_price > 0) NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  items_price_changes(
		cost_change_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULl,
		item_cost_changed_by INT REFERENCES employees(employee_id) NOT NULL,
		change_type varchar(10) CHECK (change_type IN ('discount','price')),
		new_value NUMERIC(10, 2) CHECK (new_value >= 0) NOT NULL,
		previous_value NUMERIC(10, 2) CHECK (previous_value >= 0) NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  seasons(
		season_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		season_name VARCHAR(35) NOT NULL,
		season_description VARCHAR(254)
	);

	CREATE TABLE IF NOT EXISTS  items_seasons(
		season_id INT REFERENCES seasons ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		PRIMARY KEY (season_id, item_id)
	);
	CREATE TABLE IF NOT EXISTS  items_type_day_time(
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_type item_day_type NOT NULL,
		PRIMARY KEY (item_id, item_type)
	);
	-- create Index

	CREATE TABLE IF NOT EXISTS  recipes(
		recipe_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		quantity NUMERIC(5, 3) NOT NULL,
		recipe_status recipe_type NOT NULL
	);
	CREATE TABLE IF NOT EXISTS  storages_stock(
		storage_id INT REFERENCES storages ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		in_stock_quantity	smallint NOT NULL,
		primary key (storage_id, ingredient_id)
	);

	CREATE TABLE IF NOT EXISTS  branches_staff(
		employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		branch_id INT NOT NULL,
		section_id INT ,
		FOREIGN KEY (branch_id, section_id) REFERENCES branch_sections (branch_id, section_id) ON DELETE RESTRICT ON UPDATE CASCADE,
		PRIMARY KEY (employee_id, branch_id)
	);



	-- create Index

	-- Shipmnets Tables
	CREATE TABLE IF NOT EXISTS  suppliers(
		supplier_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		supplier_first_name VARCHAR(35) NOT NULL,
		supplier_last_name VARCHAR(35),
		supplier_type VARCHAR(10) CHECK (supplier_type IN ('commodity', 'private label','online'))
	);

	CREATE TABLE IF NOT EXISTS  supply_companies_employees(
		supply_empolyee_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		supply_company_id INT REFERENCES suppliers (supplier_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		supply_emp_first_name VARCHAR(35) NOT NULL,
		supply_emp_last_name VARCHAR(35),
		supply_emp_phone VARCHAR(15) NOT NULL CHECK (supply_emp_phone ~ '^[0-9]+$') UNIQUE,
		supply_emp_gender sex_type
		
	);

	CREATE TABLE IF NOT EXISTS  suppliers_call_list(
		supplier_phone_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		supplier_phone_number VARCHAR(15) NOT NULL CHECK (supplier_phone_number ~ '^[0-9]+$') UNIQUE 
	);

	CREATE TABLE IF NOT EXISTS  supplier_addresses_list(
		supplier_address_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		supplier_address VARCHAR(95) NOT NULL,
		city VARCHAR(35), 
		location_coordinates point
	);
	CREATE TABLE IF NOT EXISTS  stock_orders_details(
		stock_order_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		storage_id INT REFERENCES storages ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		quantity SMALLINT NOT NULL CHECK (quantity > 0),
		arrival_time TIMESTAMPTZ,
		ingredient_order_status order_status_type
	);

	CREATE TABLE IF NOT EXISTS  branches_stock_orders(
		stock_order_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ordered_employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		request_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  ingredients_suppliers(
		supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		primary key (supplier_id, ingredient_id)
	);

	-- create Index
	CREATE TABLE IF NOT EXISTS  ingredients_shipments(
		shipment_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		ordered_employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		storage_id INT REFERENCES storages ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		request_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  shipments_details(
		shipment_id INT REFERENCES ingredients_shipments ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		ingredient_quantity NUMERIC(12, 2) CHECK (ingredient_quantity > 0) NOT NULL,
		price_per_unit NUMERIC(10,2) NOT NULL,
		arrival_time TIMESTAMPTZ,
		ingredient_shipment_status order_status_type
	);
	-- orders Tables
	CREATE TABLE IF NOT EXISTS orders(
		order_id  INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		customer_id  INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
		ship_date TIMESTAMPTZ DEFAULT NULL,
		order_type order_type NOT NULL,
		order_status order_status_type NOT NULL,
		order_total_price NUMERIC(10,2) CHECK (order_total_price > 0) NOT NULL,
		order_customer_discount NUMERIC(4,2) CHECK (order_customer_discount >= 0) DEFAULT 0 NOT NULL,
		order_payment_method payment_method_type NOT NULL,
		virtual_room BOOLEAN NOT NULL DEFAULT FALSE
	);

	CREATE TABLE IF NOT EXISTS orders_connecting_details(
		order_id INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		address_id INT REFERENCES customers_addresses_list ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_phone_id INT REFERENCES customers_phones_list ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL
	);

	CREATE TABLE IF NOT EXISTS  orders_credit_details(
		order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		credit_card_number varchar(16) NOT NULL,
		credit_card_exper_month SMALLINT NOT NULL CHECK (credit_card_exper_month >= 1 AND credit_card_exper_month <= 12),
		credit_card_exper_day SMALLINT NOT NULL ,
		name_on_card VARCHAR(35) NOT NULL,
		PRIMARY KEY (order_id)
		
	);
	CREATE TABLE IF NOT EXISTS  virtual_orders_credit_details(
		order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		credit_card_number varchar(16) NOT NULL,
		credit_card_exper_month SMALLINT NOT NULL CHECK (credit_card_exper_month >= 1 AND credit_card_exper_month <= 12),
		credit_card_exper_year SMALLINT NOT NULL ,
		name_on_card VARCHAR(35) NOT NULL,
		PRIMARY KEY (order_id, customer_id)
	);
	-- oreders that are form virtual room or single order from one person
	CREATE TABLE IF NOT EXISTS  virtual_orders_items(
		order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		customer_id  INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		quantity SMALLINT CHECK (quantity > 0) NOT NULL,
		quote_price NUMERIC(6,2) CHECK (quote_price > 0) NOT NULL,
		PRIMARY KEY (order_id, customer_id, item_id)
	);

	-- create Index
	CREATE TABLE IF NOT EXISTS  non_virtual_orders_items(
		order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		quantity SMALLINT CHECK (quantity > 0) NOT NULL,
		quote_price NUMERIC(6,2) CHECK (quote_price > 0),
		PRIMARY KEY (order_id, item_id)
	);
	-- create Index

	CREATE TABLE IF NOT EXISTS  lounge_orders(
		order_id  INT NOT NULL ,
		branch_id INT NOT NULL,
		table_id INT NOT NULL,
		FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT ON UPDATE CASCADE ,
		FOREIGN KEY (branch_id,table_id) REFERENCES branch_tables(branch_id,table_id) ON DELETE RESTRICT ON UPDATE CASCADE,
		PRIMARY KEY (order_id, table_id)
	);

	-- create Index
	CREATE TABLE IF NOT EXISTS  delivered_orders(
		order_id  INT REFERENCES orders NOT NULL,
		delivery_employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		arrival_date_by_customer timestamptz,
		arrival_date_by_employee timestamptz,
		PRIMARY KEY (order_id)
	);

	-- Bookings Tables
	CREATE TABLE IF NOT EXISTS  bookings(
		booking_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		table_id INT ,
		branch_id INT ,
		booking_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
		booking_start_time TIMESTAMPTZ NOT NULL,
		booking_end_time TIMESTAMPTZ NOT NULL,
		booking_status order_status_type,

		FOREIGN KEY (branch_id, table_id) REFERENCES branch_tables(branch_id, table_id)
	);

	CREATE TABLE IF NOT EXISTS  bookings_orders(
		booking_id INT REFERENCES bookings ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL, 
		order_id INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		PRIMARY KEY (booking_id, order_id)
	);
	-- create Index










	-- Tables of recommend usage 

	CREATE TABLE IF NOT EXISTS customers_favorites(
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		PRIMARY KEY (customer_id, item_id)
	);

	CREATE TABLE IF NOT EXISTS customers_ratings(
		customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL,
		rating range_0_to_5 NOT NULL,
		PRIMARY KEY (customer_id, item_id)
	);