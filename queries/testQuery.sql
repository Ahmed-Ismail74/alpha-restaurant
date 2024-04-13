SELECT fn_add_position('hr', 'Manages recruitment, training, and development of employees across the company. Implements HR policies and procedures, including compensation, benefits, and performance management');
SELECT fn_add_position('operation manager', 'Oversees overall operations of the company, including restaurant branches, production facilities, and distribution centers. Develops and implements operational policies, procedures, and performance metrics.');
SELECT fn_add_position('logistics coordinator', 'Coordinates transportation and logistics activities, including scheduling deliveries and managing routes. Communicates with suppliers, carriers, and internal teams to ensure timely delivery of goods.');
SELECT fn_add_position('head bar', 'oversees the outlet bar operations and other bartenders work to ensure that they provide positive customer experience. He/She ensures the smooth running of the bar.');
SELECT fn_add_position('barista', 'mixes drinks, and serves beverages according to established recipes and customer preferences. Maintains cleanliness and organization of the bar area, including stocking supplies and cleaning equipment.');
SELECT fn_add_position('head waiter', 'Takes orders from customers, serves food and beverages, and provides excellent customer service. Answers questions about menu items, takes payments, and ensures a positive dining experience.');
SELECT fn_add_position('dish washer', 'Cleans and sanitizes dishes, utensils, and kitchen equipment. Assists with maintaining cleanliness and organization in the kitchen.');
SELECT fn_add_position('delivery driver', 'Delivers food orders to customers  homes or offices. Ensures timely and accurate delivery, collects payments, and provides excellent customer service.');
SELECT fn_add_position('chief', 'Responsible for planning menus, preparing and cooking food, and maintaining food quality and presentation. Supervises kitchen staff, manages inventory, and ensures compliance with health and safety regulations.');
SELECT fn_add_position('cashier', 'The cashier runs the cash register, processes payments, and interacts with customers. Sometimes a cashier also takes orders from guests.');
SELECT fn_add_position('kitchen manager', 'A kitchen manager helps manage the back of house team, including prep and clean up. They help ensure all sanitation standards are met. They often are responsible for ordering ingredients and replacing or adding equipment within a budget.');
SELECT fn_add_position('assistant manager', 'Researching new wholesale food suppliers and negotiating prices
Calculating future needs in kitchenware and equipment and placing orders, as needed
Managing and storing vendors contracts and invoices');
SELECT fn_add_position('branch manager', 'responsible for hiring applicants, letting employees go, training new hires, overseeing general restaurant activities, and working on marketing and community outreach strategies. They may also help to set menu prices and purchase supplies.');
SELECT * FROM positions;

---------------------------------------------------------------------------------------
SELECT fn_add_branch('New Cairo', 'Southern Ninety, First District, New Cairo, Cairo Governorate', f_branch_phone => '01013476117',f_location_coordinates => POINT(30.0174349, 31.412102));
SELECT fn_add_branch('Shubra', '212 Shubra, Asaad, Al Sahel, Cairo Governorate', f_branch_phone => '01215452545',f_location_coordinates => POINT(30.0937835,31.2458379), f_coverage => cast(20 AS SMALLINT));
SELECT fn_add_branch('Zamalek', 'ormer Montazah St, 16 Kamal Al Tawil, Zamalek, Cairo Governorate', f_branch_phone => '01275055555',f_location_coordinates => POINT(30.0706968,31.1399415), f_coverage => cast(20 AS SMALLINT));
SELECT * FROM branches;
SELECT * FROM branch_tables;
CALL fn_add_ta
---------------------------------------------------------------------------------------
SELECT fn_add_general_section('takeout counter', 'A designated area or counter for handling takeout, delivery, or to-go orders.');
SELECT fn_add_general_section('patisserie Section', 'A section dedicated to baking bread, pastries, and other baked goods in-house.');
SELECT fn_add_general_section('dessert station', 'An area within the restaurant dedicated to showcasing and preparing desserts, often featuring a display of sweet treats.');
SELECT fn_add_general_section('soup section', 'This individual or team is responsible for preparing all soups offered on the menu.');
SELECT fn_add_general_section('grill cook:', 'This cook is typically responsible for grilling or searing meats, poultry, seafood, and vegetables. They ensure that proteins are cooked to the desired level of doneness and often work closely with the sauté cook for coordination.');
SELECT fn_add_general_section('bartender station', 'This is the central workspace where bartenders prepare and serve drinks. ');
SELECT fn_add_general_section('managing section', 'Managing sections involves assigning servers, bartenders, and other personnel to their respective sections based on factors such as experience, skill level, and workload.');
SELECT * FROM sections;
---------------------------------------------------------------------------------------
SELECT fn_add_branch_sections(1, 2);
SELECT fn_add_branch_sections(1, 3);
SELECT fn_add_branch_sections(1, 4);
SELECT fn_add_branch_sections(1, 7);
SELECT fn_add_branch_sections(2, 5);
SELECT fn_add_branch_sections(2, 6);
SELECT fn_add_branch_sections(2, 7);
SELECT * FROM branch_sections;
---------------------------------------------------------------------------------------
SELECT fn_add_employee('3000123123123', 'ahmed', 'ismail', 'm', '6000', f_position_id => 1, f_branch_id => 1, f_section_id => 4);
SELECT fn_add_employee('3000548745123', 'ahmed', 'ehab', 'm', '8000', f_position_id => 12, f_branch_id => 2, f_section_id => 5);
SELECT fn_add_employee('30000351482365', 'ahmed', 'khalid', 'm', 12000, f_position_id => 1, address => '8 Nile Valley, Mit Okba Island, Agouza District, Giza Governorate');
SELECT * FROM employees;
SELECT * FROM employees_position;
SELECT * FROM branches_staff;

SELECT fn_change_employee_position(3, 1, 2, 'promote');
SELECT * FROM positions_changes;
SELECT * FROM vw_employee;

---------------------------------------------------------------------------------------
CALL  pr_add_storage('Al-Sahel', 'Minyat Al-Serj, Al-Sahel, Cairo Governorate');
SELECT * FROM storages;
---------------------------------------------------------------------------------------
CALL pr_add_ingredient('salt', 'gram', 'kilogram');
CALL pr_add_ingredient('corn oil', 'milliliter', 'liter');
CALL pr_add_ingredient('olive oil', 'milliliter', 'liter');
CALL pr_add_ingredient('vegetable oil', 'milliliter', 'liter');
CALL pr_add_ingredient('shea butter', 'gram', 'kilogram');
CALL pr_add_ingredient('margarine ', 'gram', 'kilogram');
CALL pr_add_ingredient('ghee ', 'gram', 'kilogram');
CALL pr_add_ingredient('ocet', 'milliliter', 'liter');
SELECT * FROM ingredients;
---------------------------------------------------------------------------------------
CALL pr_add_ingredient_to_branch_stock(1, 1, 100);
CALL pr_add_ingredient_to_branch_stock(2, 1, 100);
CALL pr_add_ingredient_to_branch_stock(1, 2, 50);
CALL pr_add_ingredient_to_branch_stock(2, 2, 30);

---------------------------------------------------------------------------------------
CALL pr_add_category(1, 'salads', 'a wide variety of dishes including: green salads; vegetable salads; long beans; salads of pasta, legumes, or grains; mixed salads incorporating meat, poultry, or seafood; and fruit salads. They often include vegetables and fruits.');
SELECT * FROM categories;
---------------------------------------------------------------------------------------
CALL pr_menu_item('coleslaw', 'is a side dish consisting primarily of finely shredded raw cabbage[2] with a salad dressing or condiment, commonly either vinaigrette or mayonnaise.', 1, '5 minutes'::interval)
CALL pr_menu_item('baba ghanoush', 'is a Levantine appetizer consisting of finely chopped roasted eggplant, olive oil, lemon juice, various seasonings, and tahini.', 1, '40 minutes'::interval)
SELECT * FROM menu_items;
---------------------------------------------------------------------------------------
CALL pr_add_item_branch_menu(1, 1, 45);
CALL pr_add_item_branch_menu(1, 1, 60);
CALL pr_add_item_branch_menu(2, 1, 50);
CALL pr_add_item_branch_menu(2, 1, 60);
SELECT * FROM branches_menu;
---------------------------------------------------------------------------------------
-- CALL pr_add_supplier('saeed', 'kamal','online','01124587564', '1st ali ali sds');
-- CALL pr_add_supplier('light ing', 'co.','commodity','01215482456', '2st mohamed el ghazaly', 'cairo');
-- SELECT * FROM suppliers;
-- SELECT * FROM suppliers_call_list;
-- SELECT * FROM supplier_addresses_list;
---------------------------------------------------------------------------------------
-- CALL pr_add_supply_employee(8, 'mohsen', 'shaker','012155454');
-- CALL pr_add_supply_employee(9, 'samera', 'asaad','012154855','f');
-- SELECT * FROM supply_companies_employees;
---------------------------------------------------------------------------------------
-- CALL pr_add_ingredient_supplier(p_supplier_id => 8, p_ingredient_id => 9);
-- CALL pr_add_ingredient_supplier(p_supplier_id => 8, p_ingredient_id => 10);
-- CALL pr_add_ingredient_supplier(p_supplier_id => 9, p_ingredient_id => 13);
-- CALL pr_add_ingredient_supplier(p_supplier_id => 8, p_ingredient_id => 13);
-- SELECT * FROM ingredients_suppliers;
---------------------------------------------------------------------------------------
-- SELECT * FROM recipes;
---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
