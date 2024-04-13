--branches details view  
CREATE OR REPLACE VIEW vw_branches (
	branch_id,
	branch_name,
	manager_name,
	branch_phone,
	branch_address,
    tables_number,
    tables_capacity
)
AS 
    SELECT br.branch_id, br.branch_name, (employees.employee_first_name || ' ' || employees.employee_last_name) AS manager_name, br.branch_phone, br.branch_address, COUNT(tab.branch_id), SUM(tab.capacity)
    FROM branches br
    LEFT JOIN branches_managers ON br.branch_id = branches_managers.branch_id
    LEFT JOIN employees ON branches_managers.manager_id = employees.employee_id
    LEFT JOIN branch_tables tab ON tab.branch_id = br.branch_id
    GROUP BY 
        br.branch_id, 
        br.branch_name, 
        employees.employee_first_name, 
        employees.employee_last_name, 
        br.branch_phone, 
        br.branch_address;

--categories details view  
CREATE OR REPLACE VIEW vw_categories(
	category_name,
	section_name,
	category_description
)
AS 
    SELECT categories.category_name, sections.section_name, categories.category_description
    FROM categories
    JOIN sections ON sections.section_id = categories.section_id;




-- View to show recipes information of all menu items 
CREATE OR REPLACE VIEW vw_recipes(
	item_id ,
	item_name ,
	ingredient_name,
	ingredient_unit ,
	quantity ,
	recipe_status 
)
AS 
    SELECT mi.item_id, mi.item_name, ing.ingredients_name, ing.recipe_ingredients_unit, rec.quantity, rec.recipe_status FROM menu_items mi
    LEFT JOIN recipes rec ON rec.item_id = mi.item_id 
    LEFT JOIN ingredients  ing ON ing.ingredient_id = rec.ingredient_id
    ORDER BY item_id;


-- VIEW to show all general menu not of specific branch
CREATE OR REPLACE VIEW vw_general_menu(
    id,
    name,
    description,
    preparation_time,
    category
) AS
    SELECT item_id, item_name, item_description, preparation_time, category_name
    FROM menu_items menu
    LEFT JOIN categories cat ON menu.category_id = cat.category_id;



CREATE OR REPLACE VIEW vw_branch_price_changes(
    id,
    item,
    branch,
    changed_by,
    change_type,
    new_value,
    previous_value
)AS 
    SELECT ch.cost_change_id, it.item_name, br.branch_name, (emp.employee_first_name || ' ' || emp.employee_last_name) as emp_name, ch.change_type, ch.new_value, ch.previous_value
    FROM items_price_changes ch
    LEFT JOIN branches br ON br.branch_id = ch.branch_id
    LEFT JOIN employees emp ON emp.employee_id = ch.item_cost_changed_by
    LEFT JOIN menu_items it ON it.item_id = ch.item_id;

