import pandas as pd
from sqlalchemy import text

from db_functions import create_sqlalcheme_engine

conn = create_sqlalcheme_engine()
SQL_FOLDER = 'src/sql_scripts/transform/'

def read_file(select_file):
    file_path = SQL_FOLDER + select_file
    return open(file_path, "r", encoding='utf-8').read()

    
def stg2dwh(conn, select_file, upsert_file):
    select_stmt = text(read_file(select_file))
    upsert_stmt = text(read_file(upsert_file))

    with conn.begin() as con:
        insert_values = pd.read_sql(select_stmt, con).to_dict(orient='records')
        print(f"Extract {len(insert_values)} rows, loading to dwh...")
        con.execute(upsert_stmt, insert_values)
        print("Success load")
        
stg2dwh(
    conn, 
    'terminals/select_stg_terminals.sql',
    'terminals/upsert_dwh_terminals.sql'    
)
