CREATE OR REPLACE PROCEDURE pr_update_employee_salary_position(
	fn_employee_id int,
	fn_changer_id int,
	fn_new_salary int,
	fn_new_position INT,
	fn_position_change_type position_change_type,
	fn_change_reason varchar(255) DEFAULT NULL

)
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
			RAISE EXCEPTION 'New salary Is same current';
		END IF;
		
		IF fn_changer_id IN (SELECT employee_id FROM employees_position 
							 WHERE position_id IN (SELECT position_id FROM positions
							WHERE position_name = 'hr' OR position_name = 'operation manager')) THEN
			-- Check if the employee already has a position
			SELECT position_id INTO fn_previous_position_id FROM employees_position WHERE employee_id = fn_employee_id;

			IF fn_previous_position_id IS NULL THEN
				-- Insert new position if the employee does not have one
				INSERT INTO employees_position (employee_id, position_id)
				VALUES (fn_employee_id, fn_new_position);
			ELSE
				-- Update position if the employee already has one
				UPDATE employees_position
				SET position_id = fn_new_position
				WHERE employee_id = fn_employee_id;
			END IF;
			

			INSERT INTO positions_changes(employee_id, position_changer_id, previous_position, new_position, position_change_type)
			VALUES (fn_employee_id, fn_changer_id, fn_previous_position_id, fn_new_position, fn_position_change_type);

			RAISE NOTICE 'Employee position and salary changed';
		ELSE
			RAISE EXCEPTION 'Premission denied';
		END IF;
		
	ELSE
        RAISE EXCEPTION 'Employee with id % not found', fn_employee_id;
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
	PERFORM 1 FROM employees WHERE employee_id = fn_employee_id;
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

CREATE OR REPLACE PROCEDURE pr_update_employee_phone(
	pr_employee_id INT,
	pr_employees_phone VARCHAR(15),
	pr_new_phone VARCHAR(15)
)
LANGUAGE PLPGSQL
AS 
$$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = pr_employee_id;
	IF FOUND THEN
		PERFORM 1 employee_phone FROM employees_call_list 
		WHERE employee_id = pr_employee_id
		AND employee_phone = pr_employees_phone;
		IF FOUND THEN
			UPDATE employees_call_list 
			SET employee_phone = pr_new_phone
			WHERE employee_id = pr_employee_id AND employee_phone = pr_employees_phone;
			RAISE NOTICE 'phone changed';
		ELSE
			RAISE EXCEPTION 'Phone not existed';
		END IF;
	ELSE
		RAISE EXCEPTION 'employee not found';
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_employee_transfer(
    fn_employee_id INT,
    fn_new_branch_id INT,
    fn_transfer_made_by INT,
    fn_transfer_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    fn_transfer_reason VARCHAR(250) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_old_branch_id INT;
BEGIN
    -- Check if the employee exists
    PERFORM 1 FROM employees WHERE employee_id = fn_employee_id;
    IF FOUND THEN
        -- Check if the new branch exists
        PERFORM 1 FROM branches WHERE branch_id = fn_new_branch_id;
        IF FOUND THEN
            -- Fetch the old branch ID before the update
            SELECT branch_id INTO fn_old_branch_id
            FROM branches_staff
            WHERE employee_id = fn_employee_id;
            
            IF fn_old_branch_id IS NOT NULL THEN
                -- Update the branch ID
                UPDATE branches_staff
                SET branch_id = fn_new_branch_id
                WHERE employee_id = fn_employee_id;
            ELSE
                -- Add the employee to the new branch staff
                INSERT INTO branches_staff (employee_id, branch_id)
                VALUES (fn_employee_id, fn_new_branch_id);
                
                -- Set the old branch ID to NULL as the employee was not previously assigned
                fn_old_branch_id := NULL;
            END IF;
            
            -- Insert into employees_transfers
            INSERT INTO employees_transfers(
                employee_id, 
                new_branch_id, 
                old_branch_id, 
                transfer_made_by, 
                transfer_date, 
                transfer_reason
            )
            VALUES (
                fn_employee_id, 
                fn_new_branch_id, 
                fn_old_branch_id, 
                fn_transfer_made_by, 
                fn_transfer_date, 
                fn_transfer_reason
            );
            
            RAISE NOTICE 'Employee transferred';
        ELSE
            RAISE EXCEPTION 'Branch does not exist';
        END IF;
    ELSE
        RAISE EXCEPTION 'Employee does not exist';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_change_salary(
    fn_employee_id INT,
    fn_changer_id INT,
    fn_new_salary INT,
    fn_change_reason VARCHAR(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS
$$
DECLARE
    fn_current_salary INT;
BEGIN
    SELECT employee_salary INTO fn_current_salary FROM employees WHERE employee_id = fn_employee_id;

    IF FOUND THEN
        IF fn_current_salary <> fn_new_salary THEN
			IF fn_changer_id IN (SELECT employee_id FROM employees_position 
							 WHERE position_id IN (SELECT position_id FROM positions
							WHERE position_name = 'hr' OR position_name = 'operation manager')) THEN

				INSERT INTO salary_changes (employee_id, change_made_by, old_salary, change_reason)
				VALUES (fn_employee_id, fn_changer_id, fn_current_salary, fn_change_reason);
			ELSE
				RAISE EXCEPTION 'Premission denied';
			END IF;

            UPDATE employees 
            SET employee_salary = fn_new_salary
            WHERE employee_id = fn_employee_id;

            RAISE NOTICE 'Salary Changed';
        ELSE 
            RAISE EXCEPTION 'New salary is same as the current';
        END IF;
    ELSE
        RAISE EXCEPTION 'Employee not found';
    END IF;
END;
$$;



-- PROCEDURE to change employee position
CREATE OR REPLACE PROCEDURE pr_change_employee_position(
	fn_employee_id INT,
	fn_position_changer_id INT,
	fn_new_position INT,
	fn_position_change_type position_change_type
)
LANGUAGE PLPGSQL
AS $$
DECLARE
	fn_previous_position_id INT DEFAULT NULL;
BEGIN
	IF EXISTS(SELECT 1 FROM employees WHERE fn_employee_id = employee_id) THEN

		IF fn_position_changer_id IN (SELECT employee_id FROM employees_position 
							 WHERE position_id IN (SELECT position_id FROM positions
							WHERE position_name = 'hr' OR position_name = 'operation manager')) THEN
			-- Check if the employee already has a position
			SELECT position_id INTO fn_previous_position_id FROM employees_position WHERE employee_id = fn_employee_id;

			IF fn_previous_position_id IS NULL THEN
				-- Insert new position if the employee does not have one
				INSERT INTO employees_position (employee_id, position_id)
				VALUES (fn_employee_id, fn_new_position);
			ELSE
				-- Update position if the employee already has one
				UPDATE employees_position
				SET position_id = fn_new_position
				WHERE employee_id = fn_employee_id;
			END IF;

			INSERT INTO positions_changes(employee_id, position_changer_id, previous_position, new_position, position_change_type)
			VALUES (fn_employee_id, fn_position_changer_id, fn_previous_position_id, fn_new_position, fn_position_change_type);

			RAISE NOTICE 'Employee position changed';
		ELSE
			RAISE EXCEPTION 'Premission denied';
		END IF;
	ELSE
		RAISE EXCEPTION 'Employee not Exist';
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_employee_status_change(
	pr_employee_id INT,
	pr_employee_status employee_status_type
)
LANGUAGE PLPGSQL
AS
$$
BEGIN
	PERFORM employee_id FROM employees WHERE employee_id = pr_employee_id;
	IF FOUND THEN
		UPDATE employees
		SET employee_status = pr_employee_status
		WHERE employee_id = pr_employee_id;
		RAISE NOTICE 'employee status has been updated';
	ELSE
		RAISE EXCEPTION 'employee not found';
	END IF;
END;
$$;






CREATE OR REPLACE PROCEDURE change_employee_password(
    p_employee_id INT,
    p_new_password VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if the employee exists
    IF NOT EXISTS (
        SELECT 1
        FROM employees_accounts
        WHERE employee_id = p_employee_id
    ) THEN
        RAISE EXCEPTION 'Employee not found for employee_id %', p_employee_id;
    END IF;

    -- Update the employee password
    UPDATE employees_accounts
    SET employee_password = p_new_password
    WHERE employee_id = p_employee_id;

    -- Raise a notice for successful update
    RAISE NOTICE 'Employee password updated successfully for employee_id %', p_employee_id;

END;
$$;




CREATE OR REPLACE PROCEDURE change_employee_picture(
    p_employee_id INT,
    p_picture_path VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if the employee exists
    PERFORM 1 FROM employees_accounts WHERE employee_id = p_employee_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee not found for employee_id %', p_employee_id;
    END IF;

    -- Update the employee picture
    UPDATE employees_accounts
    SET picture_path = p_picture_path
    WHERE employee_id = p_employee_id;

    -- Raise a notice for successful update
    RAISE NOTICE 'Employee Picture updated successfully for employee_id %', p_employee_id;

END;
$$;
