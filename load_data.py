import pandas as pd
import mysql.connector
from sqlalchemy import create_engine

# Step 1 - Test connection
conn = mysql.connector.connect(
    host='localhost',
    port=3306,
    user='root',
    password='Anju@2006',
    database='hospital_analytics'
)
print("Connected successfully!")

# Step 2 - Load CSV
df = pd.read_csv(r'C:\Users\anjal\OneDrive\Desktop\train_data.csv')
df.columns = df.columns.str.strip().str.replace(' ', '_')
print(f"CSV loaded! Rows: {len(df)}")

# Step 3 - Insert data
engine = create_engine(
    "mysql+mysqlconnector://",
    creator=lambda: mysql.connector.connect(
        host='localhost',
        port=3306,
        user='root',
        password='Anju@2006',
        database='hospital_analytics'
    )
)

df.to_sql('train_data', con=engine, if_exists='replace', index=False)
print(f"Done! {len(df)} rows loaded successfully!")