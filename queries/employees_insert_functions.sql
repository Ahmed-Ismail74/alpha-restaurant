-- Procedure to add position
CREATE OR REPLACE PROCEDURE pr_add_position(
	f_position_name varchar(25) ,
	p_emp_role roles_type, 
	f_job_description varchar(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM positions WHERE position_name = f_position_name) THEN
		RAISE EXCEPTION 'Position already exist';
	ELSE
		INSERT INTO positions(position_name, job_description, emp_role)
		VALUES (f_position_name, f_job_description, p_emp_role);
		RAISE NOTICE 'position added';
	END IF;
END;
$$;

-- FUNCTION to ADD employee
CREATE OR REPLACE FUNCTION fn_add_employee(
	ssn CHAR(14),
	first_name VARCHAR(35),
	last_name VARCHAR(35) ,
	gender sex_type,
	salary INT,
	f_position_id INT ,
	status employee_status_type DEFAULT 'pending',
	f_branch_id INT DEFAULT NULL,
	f_section_id INT DEFAULT NULL,
	birthdate DATE DEFAULT NULL,
	address VARCHAR(255) DEFAULT NULL,
	date_hired timestamptz DEFAULT CURRENT_TIMESTAMP
)
RETURNS VARCHAR	
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_employee_id INT;
BEGIN 
	IF EXISTS (SELECT 1 FROM employees WHERE ssn = employee_ssn) THEN
		RETURN 'SSN existed';
	ELSE
		INSERT INTO employees(
			employee_ssn,
			employee_first_name,
			employee_last_name,
			employee_birthdate,
			employee_address,
			employee_date_hired,
			employee_salary,
			employee_status,
			employee_gender
		) VALUES (
			ssn,
			first_name,
			last_name,
			birthdate,
			address,
			date_hired,
			salary,
			status,
			gender
		) RETURNING employee_id INTO f_employee_id;
		
		IF f_branch_id IS NOT NULL AND f_section_id IS NOT NULL  THEN 
			INSERT INTO branches_staff(employee_id, branch_id, section_id)
			VALUES (f_employee_id, f_branch_id, f_section_id);
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM positions WHERE position_id = f_position_id) THEN
			RETURN 'employee added but position not existed';
		ELSE
			INSERT INTO employees_position(employee_id, position_id)
			VALUES(f_employee_id, f_position_id);
		END IF;
		
		RETURN 'Employee added';
	END IF;
END;
$$;


-- PROCEDURE to insert data into employees account using id 
DROP PROCEDURE pr_insert_employee_account;
CREATE OR REPLACE PROCEDURE pr_insert_employee_account(
    p_employee_id INT,
    p_email varchar(254),
    p_password varchar(512),
	picture_path varchar(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = p_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee Not exist';
	ELSE
		PERFORM 1 FROM employees_accounts WHERE employee_id = p_employee_id;
		IF FOUND THEN
			RAISE EXCEPTION 'Account existed';
		ELSE
			INSERT INTO employees_accounts (
				employee_id,
				employee_email,
				employee_password,
				picture_path
			) VALUES (
				p_employee_id,
				p_email,
				p_password,
				picture_path
			);
			RAISE NOTICE 'Account added';
		END IF;
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_add_employee_vacation(
	fn_employee_id INT,
	fn_vacation_start_date TIMESTAMPTZ,
	fn_vacation_end_date TIMESTAMPTZ,
	fn_vacation_reason varchar(255)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS
$$
BEGIN
	Perform 1 FROM employees WHERE employee_id = fn_employee_id;
	IF FOUND THEN
		INSERT INTO employee_vacations(employee_id, vacation_start_date, vacation_end_date, vacation_reason)
		VALUES (fn_employee_id, fn_vacation_start_date, fn_vacation_end_date, fn_vacation_reason);
		RETURN 'Employee vacation added';
	ELSE
		RETURN 'Employee not exist';
	END IF;
END;
$$;


-- add a one schedule day work for an employee
-- ex SELECT * FROM fn_add_employee_schedule(2, '2024-04-11 08:00:00', '2024-04-12 08:00:00');
CREATE OR REPLACE FUNCTION fn_add_employee_schedule(
	fn_employee_id INT ,	
	fn_shift_start_time TIMESTAMPTZ,
	fn_shift_end_time TIMESTAMPTZ
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS
$$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = fn_employee_id;
	IF FOUND THEN
		INSERT INTO employee_schedule(employee_id, shift_start_time, shift_end_time)
		VALUES (fn_employee_id, fn_shift_start_time, fn_shift_end_time);
		RETURN 'Work day added';
	ELSE
		RETURN 'Employee not exist';
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_add_employee_phone(
	fn_employee_id INT,
	fn_employee_phone VARCHAR(15)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = fn_employee_id;
	IF NOT FOUND THEN
		RETURN 'Employee Not found';
	ELSE
		PERFORM employee_phone FROM employees_call_list WHERE fn_employee_phone = employee_phone;
		IF FOUND THEN
			RETURN 'Phone number is already exist';
		ELSE
			INSERT INTO employees_call_list(employee_id, employee_phone)
			VALUES(fn_employee_id, fn_employee_phone);
			RETURN 'Phone added';
		END IF;
	END IF;
END;
$$;








CREATE OR REPLACE PROCEDURE check_in_employee(IN pr_employee_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    current_schedule_id INT;
    shift_start TIMESTAMPTZ;
BEGIN
    -- Find the schedule for today
    SELECT schedule_id, shift_start_time INTO current_schedule_id, shift_start
    FROM employee_schedule
    WHERE employee_id = pr_employee_id
      AND shift_start_time::DATE = CURRENT_DATE;

    IF current_schedule_id IS NULL THEN
        RAISE EXCEPTION 'No scheduled shift for today.';
    END IF;

    -- Check if the current time is within 4 hours from the start shift time
    IF CURRENT_TIMESTAMP > shift_start + INTERVAL '4 hours' THEN
        RAISE EXCEPTION 'Check-in time has expired. You can only check-in within 4 hours from the start of your shift.';
        
    END IF;

    -- Check if already checked in
    IF EXISTS (SELECT 1 FROM employee_attendance WHERE schedule_id = current_schedule_id AND employee_id = pr_employee_id) THEN
        RAISE EXCEPTION 'Already checked in for today.';
        
    END IF;

    -- Insert check-in record
    INSERT INTO employee_attendance (schedule_id, employee_id, date_in)
    VALUES (current_schedule_id, pr_employee_id, CURRENT_TIMESTAMP);

    RAISE NOTICE 'Checked in successfully.';
END;
$$;






CREATE OR REPLACE PROCEDURE check_out_employee(IN pr_employee_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    current_schedule_id INT;
    shift_start TIMESTAMPTZ;
    shift_end TIMESTAMPTZ;
BEGIN
    -- Find the schedule for today
    SELECT schedule_id, shift_start_time, shift_end_time INTO current_schedule_id, shift_start, shift_end
    FROM employee_schedule
    WHERE employee_id = pr_employee_id
      AND shift_start_time::DATE = CURRENT_DATE;

    IF current_schedule_id IS NULL THEN
        RAISE EXCEPTION 'No scheduled shift for today.';
        
    END IF;

    -- Check if already checked in
    IF NOT EXISTS (SELECT 1 FROM employee_attendance WHERE schedule_id = current_schedule_id AND employee_id = pr_employee_id) THEN
        RAISE EXCEPTION 'Not checked in for today.';
        
    END IF;

    -- Check if the current time is before 4 hours from the end shift time or after 8 hours from the start shift time
    IF CURRENT_TIMESTAMP > shift_end - INTERVAL '4 hours' AND CURRENT_TIMESTAMP < shift_start + INTERVAL '8 hours' THEN
        RAISE EXCEPTION 'Check-out is only allowed before 4 hours from the end of your shift or after 8 hours from the start of your shift.';
        
    END IF;

    -- Update check-out time
    UPDATE employee_attendance
    SET date_out = CURRENT_TIMESTAMP
    WHERE schedule_id = current_schedule_id AND employee_id = pr_employee_id;

    RAISE NOTICE 'Checked out successfully.';
END;
$$;



CREATE OR REPLACE PROCEDURE assign_order_to_delivery(
	pr_order_id INT[],
	pr_delivery_employee_id INT
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    p_order_id INT;
    existing_employee_id INT;
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = pr_delivery_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee Not found id: %', pr_delivery_employee_id;
	ELSE
		FOREACH p_order_id IN ARRAY pr_order_id
		LOOP
			BEGIN
				INSERT INTO delivered_orders (
					order_id,
					delivery_employee_id
				) VALUES (
					p_order_id,
					pr_delivery_employee_id
					);
			EXCEPTION
			WHEN unique_violation THEN
				-- Get the existing employee ID for the conflicting order
				SELECT delivery_employee_id
				INTO existing_employee_id
				FROM delivered_orders ord
				WHERE ord.order_id = p_order_id;
				RAISE EXCEPTION 'Order ID % already delivered by employee ID %', p_order_id, existing_employee_id;
				END;
		END LOOP;
	END IF;
END;
$$



TODO: make item recomendations based on main dishes only not extra dishes 
