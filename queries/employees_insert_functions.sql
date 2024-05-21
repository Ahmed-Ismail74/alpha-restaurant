-- Funtion to add position
CREATE OR REPLACE FUNCTION fn_add_position(
	f_position_name varchar(25) ,
	f_job_description varchar(255) DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM positions WHERE position_name = f_position_name) THEN
		RETURN 'Position already exist';
	ELSE
		INSERT INTO positions(position_name, job_description)
		VALUES (f_position_name, f_job_description);
		RETURN 'position added';
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


-- Function to insert data into employees account using id 
-- Called using select -> select fn_insert_employee_account
CREATE OR REPLACE FUNCTION fn_insert_employee_account(
    f_employee_id INT,
    f_email varchar(254),
    f_password varchar(512),
	f_salt varchar(16)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM employees_accounts WHERE employee_email = f_email) THEN
		RETURN 'Account existed';
	ELSE
		INSERT INTO employees_accounts (
			employee_id,
			employee_email,
			employee_password,
			employee_salt
		) VALUES (
			f_employee_id,
			f_email,
			f_password,
			f_salt
		);
		RETURN 'Account added';
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


-- Add time in attendance to an employee
-- EX: SELECT * FROM fn_add_time_in_attendance(3,1);
CREATE OR REPLACE FUNCTION fn_add_time_in_attendance(
	fn_schedule_id INT,
	fn_employee_id INT,
	fn_time_in TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = fn_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee not found';
	ELSE
		PERFORM schedule_id FROM employee_schedule WHERE schedule_id = fn_schedule_id AND employee_id = fn_employee_id;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Employee Not authorized to attend';
		ELSE
			INSERT INTO employee_attendance(schedule_id, employee_id, date_in)
			VALUES (fn_schedule_id, fn_employee_id, fn_time_in);
			RAISE NOTICE 'Attendance has been registered successfully';
		END IF;
	END IF;
END;
$$;


-- Add time in attendance to an employee
-- EX: SELECT * FROM fn_add_time_out_attendance(3,1);
CREATE OR REPLACE FUNCTION fn_add_time_out_attendance(
	fn_schedule_id INT,
	fn_employee_id INT,
	fn_time_out TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = fn_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee not found';
	ELSE
		PERFORM schedule_id FROM employee_schedule WHERE schedule_id = fn_schedule_id AND employee_id = fn_employee_id;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Employee Not authorized to attend';
		ELSE
			UPDATE employee_attendance
			SET date_out = fn_time_out
			WHERE schedule_id = fn_schedule_id AND employee_id = fn_employee_id;
			RAISE NOTICE 'The checkout has been registered successfully';
		END IF;
	END IF;
END;
$$;

















--Note: add constraints on the time where employee can change attendance