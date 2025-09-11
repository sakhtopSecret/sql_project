import pandas as pd
from sqlalchemy import text

from py_scripts.db_functions import create_sqlalcheme_engine

conn = create_sqlalcheme_engine()
SQL_FOLDER = 'src/sql_scripts/report/'

def dwh2report():
    select_stmt = text(open(SQL_FOLDER+'query_report.sql', "r", encoding='utf-8').read())

    with conn.begin() as con:
        report_df = pd.read_sql(select_stmt, con)
        print(f"Extract {len(report_df)} rows, loading to report...")

        con.execute(text("TRUNCATE TABLE rep_fraud"))
        report_df.to_sql(
            'rep_fraud',
            con,
            if_exists='append',
            index=False,
            chunksize=500
        )
        print("Success load")
