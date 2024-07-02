from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
from sqlalchemy import create_engine
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import MinMaxScaler

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Database connection details
username = 'ahmed'
password = 'ahmed123'
host = 'alpha.ctwk2g2o61b8.us-east-1.rds.amazonaws.com'
port = '5432'  # default PostgreSQL port is 5432
database = 'restaurant_db'
ssl_cert_path = 'D:/Coding/git_repos/4th year Project/queries/insert data/us-east-1-bundle.crt'

# Create the connection string with SSL parameters
connection_string = f'postgresql://{username}:{password}@{host}:{port}/{database}?sslmode=require&sslrootcert={ssl_cert_path}'

# Create the engine
engine = create_engine(connection_string)

# Load data from the database
def load_data():
    query_items = "SELECT item_id, item_description FROM menu_items;"
    query_ratings = """
    SELECT 
        customer_id, 
        item_id, 
        CASE rating
            WHEN '0' THEN 0
            WHEN '1' THEN 1
            WHEN '2' THEN 2
            WHEN '3' THEN 3
            WHEN '4' THEN 4
            WHEN '5' THEN 5
        END AS rating
    FROM 
        customers_ratings;
    """
    query_sales = """
    SELECT 
        item_id, 
        SUM(total_sales) AS total_sales
    FROM (
        -- Sales from virtual orders
        SELECT 
            voi.item_id, 
            SUM(voi.quantity) AS total_sales
        FROM 
            virtual_orders_items voi
        GROUP BY 
            voi.item_id

        UNION ALL

        -- Sales from non-virtual orders
        SELECT 
            noi.item_id, 
            SUM(noi.quantity) AS total_sales
        FROM 
            non_virtual_orders_items noi
        GROUP BY 
            noi.item_id
    ) AS combined_sales
    GROUP BY 
        item_id;
    """

    with engine.connect() as connection:
        items_df = pd.read_sql(query_items, connection)
        ratings_df = pd.read_sql(query_ratings, connection)
        sales_df = pd.read_sql(query_sales, connection)
    
    return items_df, ratings_df, sales_df

items_df, ratings_df, sales_df = load_data()

# Normalize sales data
scaler = MinMaxScaler()
sales_df['sales_normalized'] = scaler.fit_transform(sales_df[['total_sales']])

# TF-IDF Vectorization of item descriptions
vectorizer = TfidfVectorizer()
item_descriptions_tfidf = vectorizer.fit_transform(items_df['item_description'])

# Calculate content-based similarity using cosine similarity
content_similarity = cosine_similarity(item_descriptions_tfidf)
content_similarity_df = pd.DataFrame(content_similarity, index=items_df['item_id'], columns=items_df['item_id'])

# Create user-item matrix for collaborative filtering
user_item_matrix = ratings_df.pivot_table(index='customer_id', columns='item_id', values='rating', aggfunc='mean', fill_value=0)

# Calculate collaborative similarity using cosine similarity based on ratings
collab_similarity_ratings = cosine_similarity(user_item_matrix.T)
collab_similarity_ratings_df = pd.DataFrame(collab_similarity_ratings, index=user_item_matrix.columns, columns=user_item_matrix.columns)

# Weighted combination of similarities
alpha = 0.4  # Weight for content similarity
beta = 0.4   # Weight for collaborative similarity
gamma = 0.2  # Weight for sales similarity

combined_similarity = (alpha * content_similarity_df + 
                       beta * collab_similarity_ratings_df + 
                       gamma * sales_df.set_index('item_id')['sales_normalized'].values.reshape(-1, 1))

combined_similarity_df = pd.DataFrame(combined_similarity, index=items_df['item_id'], columns=items_df['item_id'])

# Function to get recommendations for a user
def recommend_items_for_user(user_id, user_item_matrix, combined_similarity_df, top_n=5):
    if user_id in user_item_matrix.index:
        user_ratings = user_item_matrix.loc[user_id]
        user_interacted_items = user_ratings[user_ratings > 0].index.tolist()
        
        # Calculate the weighted sum of similarities for the items the user has interacted with
        similar_items = combined_similarity_df[user_interacted_items].sum(axis=1)
        
        # Filter out items the user has already interacted with
        similar_items = similar_items[~similar_items.index.isin(user_interacted_items)]
        
        # Recommend top N items
        recommendations = similar_items.sort_values(ascending=False).head(top_n)
    else:
        # Recommend top N items based on popularity and content similarity
        popularity_based = sales_df.sort_values(by='sales_normalized', ascending=False).head(top_n)['item_id']
        recommendations = content_similarity_df.loc[popularity_based.index].sum(axis=0).sort_values(ascending=False).head(top_n)
    
    return recommendations

@app.route('/recommend', methods=['POST'])
def recommend():
    data = request.get_json()
    customer_id = data.get('customer_id')
    
    recommendations = recommend_items_for_user(customer_id, user_item_matrix, combined_similarity_df)
    return jsonify(recommendations.to_dict())

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
