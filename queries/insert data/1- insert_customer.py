import psycopg2
import csv

# Function to connect to PostgreSQL
def connect():
    conn = psycopg2.connect(
        dbname="restaurant_db",
        user="ahmed",
        password="ahmed123",
        host="alpha.ctwk2g2o61b8.us-east-1.rds.amazonaws.com",
        port="5432",
        sslmode="require",
        sslrootcert='insert data/us-east-1-bundle.crt'
    )
    return conn

# Function to insert data using the procedure
def insert_data(conn, cursor, data):
    cursor.execute("CALL pr_add_customer(%s, %s, %s, %s, %s, %s, %s, %s)", data)
    conn.commit()

# Main function to read CSV and insert data
def main():
    conn = connect()
    cursor = conn.cursor()

    with open('egyptian_customers_basic.csv', 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip header row
        for row in reader:
            # Extract data from CSV row
            fn_cust_first_name = row[0]
            fn_cust_last_name = row[1]
            fn_cust_gender = row[2]  # Assuming gender is already formatted correctly in the CSV
            fn_cust_phone = row[3]
            fn_cust_address = row[4]
            fn_cust_city = row[5] if len(row) > 5 else None
            fn_location_coordinates = None
            if len(row) > 6 and row[6]:
                # If fn_location_coordinates is not empty, parse it as a Point
                coordinates = row[6].split(',')
                fn_location_coordinates = Point(float(coordinates[0]), float(coordinates[1]))
            fn_cust_birthdate = row[7] if len(row) > 7 else None

            # Call procedure to insert data
            insert_data(conn, cursor, (fn_cust_first_name, fn_cust_last_name, fn_cust_gender,
                                       fn_cust_phone, fn_cust_address, fn_cust_city,
                                       fn_location_coordinates, fn_cust_birthdate))

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()