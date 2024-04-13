-- Procedure to add new storage 
CREATE OR REPLACE PROCEDURE pr_add_storage(
	pr_storage_name VARCHAR(35),
	pr_storage_address VARCHAR(95),
	pr_manager_id INT DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM storages WHERE storage_name = pr_storage_name;
	IF FOUND THEN
		RETURN;
	ELSE
		INSERT INTO storages (storage_name, storage_address, manager_id)
		VALUES (pr_storage_name, pr_storage_address, pr_manager_id);
	END IF;
END;
$$;






-- Procedure to Insert supplier
CREATE OR REPLACE PROCEDURE pr_add_supplier(
	p_supplier_first_name VARCHAR(35),
	p_supplier_last_name VARCHAR(35),
	p_supplier_type VARCHAR(10),
	p_supplier_phone_number VARCHAR(15),
	p_supplier_address VARCHAR(95),
	p_city VARCHAR(35) DEFAULT NULL, 
	p_location_coordinates point DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
DECLARE
	p_supp_id INT;
BEGIN
	INSERT INTO suppliers(supplier_first_name, supplier_last_name, supplier_type)
	VALUES (p_supplier_first_name, p_supplier_last_name, p_supplier_type)
	RETURNING supplier_id INTO p_supp_id;
	
	INSERT INTO suppliers_call_list(supplier_id, supplier_phone_number)
	VALUES(p_supp_id, p_supplier_phone_number);
	
	INSERT INTO supplier_addresses_list(supplier_id, supplier_address, city, location_coordinates)
	VALUES (p_supp_id, p_supplier_address, p_city, p_location_coordinates);
END;
$$;


--Procedure to add supplier company employee info
CREATE OR REPLACE PROCEDURE pr_add_supply_employee(
	p_supply_company_id INT ,
	p_supply_emp_first_name VARCHAR(35),
	p_supply_emp_last_name VARCHAR(35),
	p_supply_emp_phone varchar(15),
	p_supply_emp_gender sex_type DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM suppliers WHERE supplier_id = p_supply_company_id;
	IF FOUND THEN
		INSERT INTO supply_companies_employees(supply_company_id, supply_emp_first_name, supply_emp_last_name, supply_emp_phone, supply_emp_gender)
		VALUES (p_supply_company_id, p_supply_emp_first_name, p_supply_emp_last_name, p_supply_emp_phone, p_supply_emp_gender);
	END IF;
END;
$$;
		
-- Procedure to add ingredient supplier
CREATE OR REPLACE PROCEDURE pr_add_ingredient_supplier(
	p_supplier_id INT,
	p_ingredient_id INT
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM suppliers WHERE supplier_id = p_supplier_id;
	IF FOUND THEN
		PERFORM 1 FROM ingredients WHERE ingredient_id = p_ingredient_id;
		IF FOUND THEN
			INSERT INTO ingredients_suppliers(supplier_id, ingredient_id)
			VALUES (p_supplier_id, p_ingredient_id);
		END IF;
	END IF;
END;
$$;



