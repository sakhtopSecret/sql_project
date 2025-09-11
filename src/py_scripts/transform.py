import pandas as pd
from sqlalchemy import text

from db_functions import create_sqlalcheme_engine

conn = create_sqlalcheme_engine()
SQL_FOLDER = 'src/sql_scripts/transform/'
    
def stg2dwh(conn, select_file, upsert_file):
    select_stmt = text(open(SQL_FOLDER+select_file, "r", encoding='utf-8').read())
    upsert_stmt = text(open(SQL_FOLDER+upsert_file, "r", encoding='utf-8').read())

    with conn.begin() as con:
        insert_values = pd.read_sql(select_stmt, con).to_dict(orient='records')
        print(f"Extract {len(insert_values)} rows, loading to dwh...")
        con.execute(upsert_stmt, insert_values)
        print("Success load")
