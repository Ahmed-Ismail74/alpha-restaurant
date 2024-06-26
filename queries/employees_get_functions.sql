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
		WHERE vw_positions_changes.employee_id = fn_employee_id
		ORDER BY change_date DESC;
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
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL)
				ORDER BY employee_schedule.shift_start_time; 
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
				AND (employee_schedule.shift_start_time <= fn_date_to OR fn_date_to IS NULL)
				ORDER BY employee_schedule.shift_start_time; 
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







CREATE OR REPLACE FUNCTION fn_get_employees_transfers(
    p_employee_id INT DEFAULT NULL,
    p_transfer_made_by INT DEFAULT NULL,
    p_old_branch_id INT DEFAULT NULL,
    p_new_branch_id INT DEFAULT NULL
)
RETURNS TABLE(
    transfer_id INT,
    employee_id INT,
    old_branch_id INT,
    new_branch_id INT,
    transfer_made_by INT,
    transfer_date TIMESTAMPTZ,
    transfer_reason VARCHAR(250)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tr.transfer_id,
        tr.employee_id,
        tr.old_branch_id,
        tr.new_branch_id,
        tr.transfer_made_by,
        tr.transfer_date,
        tr.transfer_reason
    FROM employees_transfers tr
    WHERE 
        (p_employee_id IS NULL OR tr.employee_id = p_employee_id) AND
        (p_transfer_made_by IS NULL OR tr.transfer_made_by = p_transfer_made_by) AND
        (p_old_branch_id IS NULL OR tr.old_branch_id = p_old_branch_id) AND
        (p_new_branch_id IS NULL OR tr.new_branch_id = p_new_branch_id)
    ORDER BY tr.transfer_date DESC;
END;
$$ LANGUAGE plpgsql;








CREATE OR REPLACE FUNCTION fn_get_employees_data(
    f_branch_id INT DEFAULT NULL,
    f_optional_status employee_status_type DEFAULT NULL,
	f_employee_role roles_type DEFAULT NULL
) RETURNS TABLE (
    fn_employee_id INT,
    fn_employee_first_name VARCHAR,
    fn_employee_last_name VARCHAR,
    fn_employee_ssn CHAR(14),
    fn_employee_status employee_status_type,
    fn_employee_gender sex_type,
    fn_employee_date_hired timestamptz,
    fn_position_name varchar(25),
    fn_role  roles_type,
    fn_section_name VARCHAR(35),
    fn_branch_id INT
) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.employee_id,
        e.employee_first_name,
        e.employee_last_name,
        e.employee_ssn,
        e.employee_status,
        e.employee_gender,
        e.employee_date_hired,
        pos.position_name,
        pos.emp_role,
        sec.section_name,
        bs.branch_id
    FROM
        employees e
        LEFT JOIN branches_staff bs ON e.employee_id = bs.employee_id
        LEFT JOIN employees_position e_p ON e.employee_id = e_p.employee_id
        LEFT JOIN positions pos ON e_p.position_id = pos.position_id
        LEFT JOIN sections sec ON bs.section_id = sec.section_id
    
    WHERE
        (f_branch_id IS NULL OR bs.branch_id = f_branch_id)
        AND (f_optional_status IS NULL OR e.employee_status = f_optional_status)
        AND (f_employee_role IS NULL OR pos.emp_role = f_employee_role)
	ORDER BY e.employee_id;
END;
$$;




CREATE OR REPLACE FUNCTION get_employee_orders(
    p_employee_id INT,
    p_status delivery_status DEFAULT NULL
)
RETURNS TABLE(
    order_id INT,
    delivery_employee_id INT,
    arrival_date_by_customer timestamptz,
    arrival_date_by_employee timestamptz,
    delivering_status delivery_status
) AS $$
BEGIN
	PERFORM 1 FROM employees WHERE employee_id = p_employee_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Employee Not found id: %', p_employee_id;
	ELSE
        RETURN QUERY
        SELECT
            ord.order_id,
            ord.delivery_employee_id,
            ord.arrival_date_by_customer,
            ord.arrival_date_by_employee,
            ord.delivering_status
        FROM
            delivered_orders ord
        WHERE
            ord.delivery_employee_id = p_employee_id
            AND (ord.delivering_status = p_status OR p_status IS NULL);
    END IF;
END;
$$ LANGUAGE plpgsql;
