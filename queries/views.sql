-- View to show supply companies employees
CREATE OR REPLACE VIEW vw_supply_employees(
	supply_company,
	company_type,
	employee_name,
	employee_phone
)
AS
SELECT (sup.supplier_first_name || ' ' || sup.supplier_last_name) as comp_name, sup.supplier_type, (supply_emp_first_name || ' ' || supply_emp_last_name) as supplier, emp.supply_emp_phone FROM suppliers sup
LEFT JOIN supply_companies_employees emp ON emp.supply_company_id = sup.supplier_id;




-- View to show ingredient suppliers
CREATE OR REPLACE VIEW vw_ingredient_suppliers(
	ingredient_name,
	supply_company,
	company_type
)
AS
SELECT ing.ingredients_name, (sup.supplier_first_name || ' ' || sup.supplier_last_name) as supply_company, sup.supplier_type
FROM ingredients ing
LEFT JOIN ingredients_suppliers ing_supp ON ing_supp.ingredient_id = ing.ingredient_id
LEFT JOIN suppliers sup ON sup.supplier_id = ing_supp.supplier_id;











