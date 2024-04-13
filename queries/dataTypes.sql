DO
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'sex_type') THEN
        CREATE TYPE sex_type AS ENUM ('m', 'f');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ingredients_unit_type') THEN
        CREATE TYPE ingredients_unit_type AS ENUM ('gram', 'milliliter', 'liter', 'piece','kilogram');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'friend_request_type') THEN
        CREATE TYPE friend_request_type AS ENUM ('pending', 'accepted', 'rejected');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'position_change_type') THEN
        CREATE TYPE position_change_type AS ENUM ('promote', 'demote');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employee_status_type') THEN
        CREATE TYPE employee_status_type AS ENUM ('active', 'inactive', 'pending');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'table_status_type') THEN
        CREATE TYPE table_status_type AS ENUM ('available', 'booked');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'menu_item_type') THEN
        CREATE TYPE menu_item_type AS ENUM ('active', 'inactive', 'not enough ingredients');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'recipe_type') THEN
        CREATE TYPE recipe_type AS ENUM ('optional','required');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status_type') THEN
        CREATE TYPE order_status_type AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_type') THEN
        CREATE TYPE order_type AS ENUM ('delivey','dine-in','take away');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_method_type') THEN
        CREATE TYPE payment_method_type AS ENUM ('cash','when recieving','credit');
    END IF;
	
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'item_day_type') THEN
        CREATE TYPE item_day_type AS ENUM ('breakfast','lunch','dinner', 'brunch', 'supper', 'midnight snack');
    END IF;
END
$$;