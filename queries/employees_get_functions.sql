CREATE OR REPLACE FUNCTION fn_get_branch_active_emlpoyees(fn_branch_id INT)
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
    RETURN QUERY
    SELECT *
    FROM vw_active_employee
    WHERE vw_active_employee.employee_branch = (SELECT branch_name FROM branches WHERE branch_id = fn_branch_id);
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
-- SELECT * FROM fn_get_branch_employees_schedule(2, '2024-04-11');
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
				employee_schedule.shift_start_time >= fn_date_from OR fn_date_from IS NULL
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL)
			ORDER BY employee_schedule.shift_start_time; 
	END IF;
END;
$$;

-- get attenance of one employee with specific range of time or not 
-- EX: SELECT * FROM fn_get_employee_attendance(1, '2024-04-10');
-- 	SELECT * FROM fn_get_employee_attendance(3);
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
-- SELECT * FROM fn_get_branch_employees_attenance(2, '2024-04-11');
-- SELECT * FROM fn_get_branch_employees_attenance(2);
-- SELECT * FROM fn_get_branch_employees_attenance(1);
CREATE OR REPLACE FUNCTION fn_get_branch_employees_attenance(
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
				employee_schedule.shift_start_time >= fn_date_from OR fn_date_from IS NULL
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL)
			ORDER BY employee_schedule.shift_start_time ASC;
	END IF;
END;
$$;