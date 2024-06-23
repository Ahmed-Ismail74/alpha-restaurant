--General employees information view
CREATE OR REPLACE VIEW vw_active_employee (
	employee_id,
	employee_name,
	employee_date_hired,
	employee_status,
	employee_branch,
	empolyee_section,
	employee_position
)
AS SELECT employees.employee_id, (employees.employee_first_name || ' ' || employees.employee_last_name) AS employee_name, employees.employee_date_hired, employees.employee_status, br.branch_name, sections.section_name, positions.position_name
FROM employees
LEFT JOIN branches_staff bs ON bs.employee_id = employees.employee_id
LEFT JOIN branches br ON br.branch_id = bs.branch_id
LEFT JOIN employees_position e_po ON e_po.employee_id = employees.employee_id
LEFT JOIN positions ON positions.position_id = e_po.position_id
LEFT JOIN branches_staff ON branches_staff.employee_id = employees.employee_id
LEFT JOIN sections ON sections.section_id = branches_staff.section_id
WHERE employees.employee_status != 'inactive'
;

CREATE OR REPLACE VIEW vw_inactive_employee (
	employee_id,
	employee_name,
	employee_date_hired,
	employee_status,
	employee_branch,
	empolyee_section,
	employee_position
)
AS SELECT employees.employee_id, (employees.employee_first_name || ' ' || employees.employee_last_name) AS employee_name, employees.employee_date_hired, employees.employee_status, br.branch_name, sections.section_name, positions.position_name
FROM employees
LEFT JOIN branches_staff bs ON bs.employee_id = employees.employee_id
LEFT JOIN branches br ON br.branch_id = bs.branch_id
LEFT JOIN employees_position e_po ON e_po.employee_id = employees.employee_id
LEFT JOIN positions ON positions.position_id = e_po.position_id
LEFT JOIN branches_staff ON branches_staff.employee_id = employees.employee_id
LEFT JOIN sections ON sections.section_id = branches_staff.section_id
WHERE employees.employee_status = 'inactive'
;



CREATE OR REPLACE VIEW vw_positions_changes(
	employee_id,
	employee_name,
	position_changer,
	previous_position,
	new_position,
	change_type,
	change_date
) AS
SELECT employees.employee_id, (employees.employee_first_name || ' ' || employees.employee_last_name) AS employee_name, (emp_changer.employee_first_name || ' ' || emp_changer.employee_last_name) AS changer_name , prev_pos.position_name, new_pos.position_name, positions_changes.position_change_type, positions_changes.position_change_date
FROM employees
LEFT JOIN employees_position ON employees_position.employee_id = employees.employee_id
INNER JOIN positions_changes ON positions_changes.employee_id = employees.employee_id
LEFT JOIN positions new_pos ON new_pos.position_id = positions_changes.new_position
LEFT JOIN positions prev_pos ON prev_pos.position_id = positions_changes.previous_position
LEFT JOIN employees emp_changer ON positions_changes.position_changer_id = emp_changer.employee_id
;


CREATE OR REPLACE VIEW vw_positions(
	position_id,
	position
) AS
SELECT position_id, position_name FROM positions;


--the employees who are 'assistant manager', 'branch manager', 'General Manager' even if they are not set as managers to a branch
CREATE OR REPLACE VIEW vw_manager_employees(
	id,
	name,
	branch,
	position
) AS
SELECT employees.employee_id, (employee_first_name || ' ' || employee_last_name) AS emp_name, branch_name, position_name
FROM employees
LEFT JOIN branches_managers ON manager_id = employees.employee_id
LEFT JOIN branches ON branches.branch_id = branches_managers.branch_id
INNER JOIN employees_position ON employees_position.employee_id = employees.employee_id
INNER JOIN positions ON positions.position_id = employees_position.position_id
WHERE 
	positions.position_name IN ('assistant manager', 'branch manager', 'General Manager')
	AND
	employees.employee_status != 'inactive';


