from py_scripts.db_functions import create_conn

def create_db():

    conn = create_conn()

    with conn.cursor() as cur:
        create_tables_stmt = open(r"src/sql_scripts/table_create.sql", "r", encoding='utf-8').read()
        cur.execute(create_tables_stmt)
        conn.commit()

        init_data_stmt = open(r"src/sql_scripts/init_data.sql", "r", encoding='utf-8').read()
        cur.execute(init_data_stmt)
        conn.commit()

        cur.close()
        
    conn.close()
