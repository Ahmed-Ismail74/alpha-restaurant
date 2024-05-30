SELECT fn_add_branch(
    f_branch_name:='sidi beshr',
    f_branch_address:='544 El Geish Avenue, Sidi Bishr',
    f_location_coordinates:=POINT(31.2628465,29.9857017),
    f_branch_phone:='01221995932'
);

SELECT fn_add_branch(
    f_branch_name:='el gomhoureya',
    f_branch_address:='23rd Of July St. intersection of el gomhoureya st',
    f_location_coordinates:=POINT(31.2565738,32.3733426),
    f_branch_phone:='0663208845'
);

SELECT fn_add_branch(
    f_branch_name:='maadi',
    f_branch_address:='29 Corniche El Nil Holiday Inn Cairo Maadi',
    f_location_coordinates:=POINT(29.9608822,31.2890247),
    f_branch_phone:='0225260642'
);

SELECT * FROM branches;

SELECT fn_add_table(1,5);
SELECT fn_add_table(1,5);
SELECT fn_add_table(1,4);
SELECT fn_add_table(1,2);
SELECT fn_add_table(1,2);
SELECT fn_add_table(1,10);
SELECT fn_add_table(1,8);

SELECT fn_add_table(2,10);
SELECT fn_add_table(2,5);
SELECT fn_add_table(2,8);
SELECT fn_add_table(2,4);
SELECT fn_add_table(2,2);
SELECT fn_add_table(2,2);


SELECT fn_add_table(3,6);
SELECT fn_add_table(3,6);
SELECT fn_add_table(3,4);
SELECT fn_add_table(3,2);
SELECT fn_add_table(3,2);
SELECT fn_add_table(3,10);
SELECT fn_add_table(3,8);

SELECT * FROM branch_tables;


---- Insert main menu data
-- Add Kitchen breakfast section
SELECT fn_add_general_section(
    'Kitchen breakfast', 
    'Section dedicated to preparing a variety of breakfast dishes including eggs, pancakes, waffles, and breakfast sandwiches.'
);

-- Add Bar section
SELECT fn_add_general_section(
    'Bar', 
    'Section dedicated to preparing and serving a wide range of beverages, including cocktails, mocktails, beer, and wine.'
);

-- Add Salad Bar section
SELECT fn_add_general_section(
    'Salad Bar', 
    'Section dedicated to preparing fresh and healthy salads, featuring a variety of greens, vegetables, fruits, nuts, and dressings.'
);

-- Add Kitchen section
SELECT fn_add_general_section(
    'Kitchen', 
    'General kitchen section for various preparations including appetizers, main courses, and side dishes, using diverse cooking techniques.'
);

-- Add Barbecue kitchen section
SELECT fn_add_general_section(
    'Barbecue kitchen', 
    'Section dedicated to preparing barbecue dishes, including smoked and grilled meats, such as ribs, brisket, chicken, and sausages, often accompanied by traditional barbecue sauces and sides.'
);

-- Add Seafood kitchen section
SELECT fn_add_general_section(
    'Seafood kitchen', 
    'Section dedicated to preparing seafood dishes, including grilled fish, shellfish, seafood stews, and sushi, ensuring the use of fresh and high-quality ingredients.'
);

-- Add Italian kitchen section
SELECT fn_add_general_section(
    'Italian kitchen', 
    'Section dedicated to preparing Italian cuisine, including pasta dishes, pizzas, risottos, and classic Italian desserts like tiramisu and panna cotta.'
);

-- Add Dessert kitchen section
SELECT fn_add_general_section(
    'Dessert kitchen', 
    'Section dedicated to preparing a variety of desserts, including cakes, pastries, ice creams, and other sweet treats, focusing on presentation and taste.'
);

SELECT * FROM sections;

SELECT fn_add_branch_sections(1,1);
SELECT fn_add_branch_sections(1,2);
SELECT fn_add_branch_sections(1,3);
SELECT fn_add_branch_sections(1,4);
SELECT fn_add_branch_sections(1,5);
SELECT fn_add_branch_sections(1,6);
SELECT fn_add_branch_sections(1,7);
SELECT fn_add_branch_sections(1,8);
SELECT fn_add_branch_sections(2,1);
SELECT fn_add_branch_sections(2,2);
SELECT fn_add_branch_sections(2,3);
SELECT fn_add_branch_sections(2,4);
SELECT fn_add_branch_sections(2,5);
SELECT fn_add_branch_sections(2,6);
SELECT fn_add_branch_sections(2,7);
SELECT fn_add_branch_sections(2,8);
SELECT fn_add_branch_sections(3,1);
SELECT fn_add_branch_sections(3,2);
SELECT fn_add_branch_sections(3,3);
SELECT fn_add_branch_sections(3,4);
SELECT fn_add_branch_sections(3,5);
SELECT fn_add_branch_sections(3,6);
SELECT fn_add_branch_sections(3,7);
SELECT fn_add_branch_sections(3,8);



CALL pr_add_category(1, 'Middle Eastern', 'Cuisine from the Middle Eastern region featuring traditional dishes.');
CALL pr_add_category(3, 'Salads', 'Fresh and healthy salad options.');
CALL pr_add_category(4, 'Appetizers', 'Small dishes served before the main course.');
CALL pr_add_category(4, 'Soup', 'Warm and comforting soup varieties.');
CALL pr_add_category(4, 'Food extra', 'Additional food items to complement meals.');
CALL pr_add_category(5, 'Chicken main dishes', 'Main courses featuring chicken.');
CALL pr_add_category(5, 'Beef main dishes', 'Main courses featuring beef.');
CALL pr_add_category(6, 'Fish main dishes', 'Main courses featuring fish.');
CALL pr_add_category(6, 'Seafood Sandwiches', 'A variety of sandwich options.');
CALL pr_add_category(5, 'Barbecue Sandwiches', 'A variety of sandwich options.');
CALL pr_add_category(7, 'Pasta', 'Traditional and innovative pasta dishes.');
CALL pr_add_category(7, 'Pizza', 'A variety of pizzas with different toppings.');
CALL pr_add_category(2, 'Hot drinks', 'A selection of hot beverages.');
CALL pr_add_category(2, 'Fresh juices', 'Freshly squeezed juice options.');
CALL pr_add_category(2, 'Drinks extra', 'Additional drink options to complement meals.');
CALL pr_add_category(8, 'Desserts', 'A variety of sweet treats to end your meal.');

SELECT * FROM categories;