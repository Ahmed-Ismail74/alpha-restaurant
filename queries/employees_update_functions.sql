CREATE OR REPLACE FUNCTION fn_update_employee_salary_position(
	fn_employee_id int,
	fn_changer_id int,
	fn_new_salary int,
	fn_new_position INT,
	fn_position_change_type position_change_type,
	fn_change_reason varchar(255) DEFAULT NULL

)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_current_salary INT;
	fn_previous_position_id INT DEFAULT NULL;
BEGIN
	SELECT employee_salary INTO fn_current_salary FROM employees WHERE employee_id =  fn_employee_id;
	
	IF FOUND THEN
		IF fn_current_salary <> fn_new_salary THEN
		
			INSERT INTO salary_changes (employee_id,change_made_by, old_salary,change_reason)
			VALUES (fn_employee_id, fn_changer_id, fn_current_salary, fn_change_reason);

			UPDATE employees 
			SET employee_salary = fn_new_salary
			WHERE employee_id = fn_employee_id;
		
		ELSE 
			RETURN 'New salary Is same current';
		END IF;
		
		IF fn_changer_id IN (SELECT employee_id FROM employees_position 
							 WHERE position_id IN (SELECT position_id FROM positions
												  WHERE position_name = 'hr' OR position_name = 'operation manager')) THEN
			SELECT position_id INTO fn_previous_position_id FROM employees_position WHERE fn_employee_id = employee_id;
			UPDATE employees_position
			SET position_id = fn_new_position
			WHERE employee_id = fn_employee_id;
			

			INSERT INTO positions_changes(employee_id, position_changer_id, previous_position, new_position, position_change_type)
			VALUES (fn_employee_id, fn_changer_id, fn_previous_position_id, fn_new_position, fn_position_change_type);

			RETURN 'Employee position and salary changed';
		ELSE
			RETURN 'Premission denied';
		END IF;
		
	ELSE
        RETURN 'Employee with id % not found', fn_employee_id;
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_update_employee_address(
	fn_employee_id INT,
	fn_employee_address VARCHAR(255)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS 
$$
BEGIN
	SELECT employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF FOUND THEN
		UPDATE employees 
		SET employee_address = fn_employee_address
		WHERE employee_id = fn_employee_id;
		RETURN 'address changed';
	ELSE
		RETURN 'employee not found';
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_update_employee_phone(
	fn_employee_id INT,
	fn_employees_phone VARCHAR(15)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS 
$$
BEGIN
	SELECT employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF FOUND THEN
		IF fn_employees_phone IN (SELECT employees_phone FROM employees_call_list WHERE employee_id = fn_employee_id) THEN
			UPDATE employees_call_list 
			SET employees_phone = fn_employees_phone
			WHERE employee_id = fn_employee_id;
			RETURN 'phone changed';
		ELSE
			RETURN 'Phone not existed';
		END IF;
	ELSE
		RETURN 'employee not found';
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_employee_transfer(
	fn_employee_id INT ,
	fn_new_branch_id INT ,
	fn_transfer_made_by INT ,
	fn_transfer_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	fn_transfer_reason varchar(250) DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS
$$
DECLARE
	fn_old_branch_id INT;
BEGIN
	SELECT employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF FOUND THEN
		SELECT branch_id FROM branches WHERE fn_new_branch_id = branch_id;
		IF FOUND THEN
			UPDATE branches_staff
			SET branch_id = fn_new_branch_id
			WHERE employee_id = fn_employee_id
			RETURNING old.branch_id INTO fn_old_branch_id;
			
			INSERT INTO employees_transfers(employee_id, new_branch_id, old_branch_id, transfer_made_by, transfer_date, transfer_reason)
			VALUES (fn_employee_id, fn_new_branch_id, fn_old_branch_id, fn_transfer_made_by, fn_transfer_date, fn_transfer_reason);
			RETURN 'employee transfered';
		ELSE
			RETURN 'Branch not exist';
		END IF;
	ELSE
		RETURN 'Employee not exist';
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION fn_change_salary(
    fn_employee_id INT,
    fn_changer_id INT,
    fn_new_salary INT,
    fn_change_reason VARCHAR(255) DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_current_salary INT;
BEGIN
    SELECT employee_salary INTO fn_current_salary FROM employees WHERE employee_id = fn_employee_id;

    IF FOUND THEN
        IF fn_current_salary <> fn_new_salary THEN
            INSERT INTO salary_changes (employee_id, change_made_by, old_salary, change_reason)
            VALUES (fn_employee_id, fn_changer_id, fn_current_salary, fn_change_reason);

            UPDATE employees 
            SET employee_salary = fn_new_salary
            WHERE employee_id = fn_employee_id;

            RETURN 'Salary Changed';
        ELSE 
            RETURN FORMAT ('New salary is same as the current', fn_employee_id);
        END IF;
    ELSE
        RETURN FORMAT ('Employee with id %s not found', fn_employee_id);
    END IF;
END;
$$;



-- Function to change employee position
CREATE OR REPLACE FUNCTION fn_change_employee_position(
	fn_employee_id INT,
	fn_position_changer_id INT,
	fn_new_position INT,
	fn_position_change_type position_change_type
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
DECLARE
	fn_previous_position_id INT DEFAULT NULL;
BEGIN
	IF EXISTS(SELECT 1 FROM employees WHERE fn_employee_id = employee_id) THEN

		IF fn_position_changer_id IN (SELECT employee_id FROM employees_position WHERE position_id IN (1, 2)) THEN
			SELECT position_id INTO fn_previous_position_id FROM employees_position WHERE fn_employee_id = employee_id;
			UPDATE employees_position
			SET position_id = fn_new_position
			WHERE employee_id = fn_employee_id;


			INSERT INTO positions_changes(employee_id, position_changer_id, previous_position, new_position, position_change_type)
			VALUES (fn_employee_id, fn_position_changer_id, fn_previous_position_id, fn_new_position, fn_position_change_type);

			RETURN 'Employee position changed';
		ELSE
			RETURN 'Premission denied';
		END IF;
	ELSE
		RETURN 'Employee not Exist';
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_delete_employee(
	fn_employee_id INT
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS
$$
BEGIN
	PERFORM employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF FOUND THEN
		UPDATE employees
		SET employee_status = 'inactive'
		WHERE employee_id = fn_employee_id;
		RETURN 'employee has been deleted';
	ELSE
		RETURN 'employee not found';
	END IF;
END;
$$;
