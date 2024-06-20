CREATE OR REPLACE FUNCTION fn_get_branch_active_employees(fn_branch_id INT)
RETURNS TABLE (
    employee_id INT,
	employee_name TEXT,
	employee_date_hired timestamptz,
	employee_status employee_status_type ,
	employee_branch VARCHAR(35),
	empolyee_section VARCHAR(35),
	employee_position VARCHAR(25)
)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM 1 FROM branches WHERE branch_id = fn_branch_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 
		USING MESSAGE = 'Branch not found',
		HINT = 'Try to list branches and get id of one of them';
	ELSE 
		RETURN QUERY
		SELECT *
		FROM vw_active_employee
		WHERE vw_active_employee.employee_branch = (SELECT branch_name FROM branches WHERE branch_id = fn_branch_id);
	END IF;
END;
$$;



CREATE OR REPLACE FUNCTION fn_get_employee_positions_changes(fn_employee_id INT)
RETURNS Table(
	employee_id INT ,
	employee_name TEXT,
	position_changer TEXT,
	previous_position varchar(25),
	new_position varchar(25),
	change_type position_change_type,
	change_date TIMESTAMPTZ
)
LANGUAGE PLPGSQL
AS
$$
BEGIN 
	RETURN QUERY
		SELECT * FROM vw_positions_changes
		WHERE vw_positions_changes.employee_id = fn_employee_id;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_employee_phones(fn_employee_id INT)
RETURNS TABLE(
	phone_id INT,
	phone VARCHAR(15)
)
LANGUAGE PLPGSQL
AS 
$$
BEGIN
	PERFORM employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee not found';
	ELSE
		RETURN QUERY
			SELECT employee_phone_id, employee_phone
			FROM employees_call_list emp_call WHERE employee_id = fn_employee_id;
	END IF;
END;
$$;

-- get schedule of one employee with specific range of time or not 
-- EX: SELECT * FROM fn_get_employee_schedule(1, '2024-04-10');
-- 	SELECT * FROM fn_get_employee_schedule(3, '2024-04-09', '2024-04-11');
-- 	SELECT * FROM fn_get_employee_schedule(3, '2024-04-10 08:00:00', '2024-04-11 08:00:00');
CREATE OR REPLACE FUNCTION fn_get_employee_schedule(
	fn_employee_id INT,
	fn_date_from DATE DEFAULT NULL,
	fn_date_to DATE DEFAULT NULL
	)
RETURNS TABLE(
	id INT,
	shift_start_time TIMESTAMPTZ,
	shift_end_time TIMESTAMPTZ
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee not found';
	ELSE
		RETURN QUERY
			SELECT schedule_id, employee_schedule.shift_start_time, employee_schedule.shift_end_time FROM employee_schedule 
			WHERE 
				employee_id = fn_employee_id 
				AND (employee_schedule.shift_start_time >= fn_date_from OR fn_date_from IS NULL)
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL); 
	END IF;
END;
$$;

-- get work schedule of all employees of branch in specific range of time or not 
-- SELECT * FROM fn_get_branch_employees_schedule(2, '2024-04-1');
-- SELECT * FROM fn_get_branch_employees_schedule(2);
CREATE OR REPLACE FUNCTION fn_get_branch_employees_schedule(
	fn_branch_id INT,
	fn_date_from DATE DEFAULT NULL,
	fn_date_to DATE DEFAULT NULL
	)
RETURNS TABLE(
	employee TEXT,
	shift_start_time TIMESTAMPTZ,
	shift_end_time TIMESTAMPTZ
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM fn_branch_id FROM branches WHERE branch_id = fn_branch_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Branch not found';
	ELSE
		RETURN QUERY
			SELECT (employee_first_name || ' ' || employee_last_name) AS emp_name , employee_schedule.shift_start_time, employee_schedule.shift_end_time FROM employee_schedule
			LEFT JOIN employees ON employee_schedule.employee_id = employees.employee_id
			INNER JOIN branches_staff ON branch_id = fn_branch_id AND employees.employee_id = branches_staff.employee_id
			WHERE 
				(employee_schedule.shift_start_time >= fn_date_from OR fn_date_from IS NULL)
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL)
			ORDER BY employee_schedule.shift_start_time; 
	END IF;
END;
$$;

-- get attenance of one employee with specific range of time or not 
-- EX: SELECT * FROM fn_get_employee_attendance(1, '2024-04-1', '2024-04-5');
-- 	SELECT * FROM fn_get_employee_attendance(1);
CREATE OR REPLACE FUNCTION fn_get_employee_attendance(
	fn_employee_id INT,
	fn_date_from DATE DEFAULT NULL,
	fn_date_to DATE DEFAULT NULL
	)
RETURNS TABLE(
	schedule_id INT,
	shift_start_time TIMESTAMPTZ,
	attendance_in TIMESTAMPTZ,
	shift_end_time TIMESTAMPTZ,
	attendance_out TIMESTAMPTZ
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM employee_id FROM employees WHERE employee_id = fn_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee not found';
	ELSE
		RETURN QUERY
			SELECT employee_schedule.schedule_id, employee_schedule.shift_start_time, att.date_in, employee_schedule.shift_end_time, att.date_out
			FROM employee_schedule
			LEFT JOIN employee_attendance att ON att.employee_id = fn_employee_id
			WHERE 
				employee_schedule.employee_id = fn_employee_id 
				AND (employee_schedule.shift_start_time >= fn_date_from OR fn_date_from IS NULL)
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL); 
	END IF;
END;
$$;



-- get work attenance of all employees of branch in specific range of time or not 
-- SELECT * FROM fn_get_branch_employees_attendance(2, '2024-04-11');
-- SELECT * FROM fn_get_branch_employees_attendance(2);
-- SELECT * FROM fn_get_branch_employees_attendance(1);
CREATE OR REPLACE FUNCTION fn_get_branch_employees_attendance(
	fn_branch_id INT,
	fn_date_from DATE DEFAULT NULL,
	fn_date_to DATE DEFAULT NULL
	)
RETURNS TABLE(
	employee TEXT,
	shift_start_time TIMESTAMPTZ,
	attendance_in TIMESTAMPTZ,
	shift_end_time TIMESTAMPTZ,
	attendance_out TIMESTAMPTZ
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM fn_branch_id FROM branches WHERE branch_id = fn_branch_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Branch not found';
	ELSE
		RETURN QUERY
			SELECT (employee_first_name || ' ' || employee_last_name) AS emp_name ,  employee_schedule.shift_start_time, att.date_in, employee_schedule.shift_end_time, att.date_out
			FROM employee_schedule
			LEFT JOIN employees ON employee_schedule.employee_id = employees.employee_id
			INNER JOIN branches_staff ON branch_id = fn_branch_id AND employees.employee_id = branches_staff.employee_id
			LEFT JOIN employee_attendance att ON att.employee_id = branches_staff.employee_id
			WHERE 
				(employee_schedule.shift_start_time >= fn_date_from OR fn_date_from IS NULL)
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL)
			ORDER BY employee_schedule.shift_start_time ASC;
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_employee_hash(
	fn_employee_email varchar(254)
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM 1 FROM employees_accounts
	WHERE employee_email = fn_employee_email;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Email not Exist';
	ELSE
		RETURN (
			SELECT employee_password FROM employees_accounts
			WHERE employee_email = fn_employee_email
			);
	END IF;
END;
$$;


CREATE OR REPLACE FUNCTION fn_get_employee_sign_in_info(
	fn_employee_email varchar(254)
)
RETURNS TABLE(
    employee_id INT ,
	employee_first_name VARCHAR(35),
	employee_last_name VARCHAR(35),
	employee_status employee_status_type ,
	
	employee_position varchar(25) ,
	employee_role roles_type,
	
	employee_branch_name VARCHAR(35),
	employee_branch_id INT,
	branch_section_id INT,
	section_name VARCHAR(35),

	picture_path varchar(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    fn_employee_id INT;
BEGIN
	SELECT acc.employee_id FROM employees_accounts acc INTO fn_employee_id
	WHERE acc.employee_email = fn_employee_email;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Email not Exist';
	ELSE
		RETURN QUERY(
			SELECT emp.employee_id,
			emp.employee_first_name,
			emp.employee_last_name,
			emp.employee_status,

			pos.position_name,
			pos.emp_role,

			br.branch_name,
			staff.branch_id ,
			staff.section_id ,
			sec.section_name,
			acc.picture_path

			FROM employees emp

			LEFT JOIN employees_accounts acc ON acc.employee_id = emp.employee_id
			LEFT JOIN employees_position emp_pos ON emp_pos.employee_id = emp.employee_id
			LEFT JOIN positions pos ON pos.position_id = emp_pos.position_id
			LEFT JOIN branches_staff staff ON staff.employee_id = emp.employee_id
			LEFT JOIN branches br ON br.branch_id = staff.branch_id
			LEFT JOIN sections sec ON staff.section_id = sec.section_id
			WHERE emp.employee_id = fn_employee_id
			);
	END IF;
END;
$$;
