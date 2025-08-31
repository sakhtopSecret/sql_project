import os
import pandas as pd

from db_functions import create_sqlalcheme_engine

conn = create_sqlalcheme_engine()

DATA_FOLDER = 'src/data/'
ARCHIVE_FOLDER = 'src/archive/'


def txt2sql(file_name: str, table, conn):
    path = DATA_FOLDER + file_name
    df = pd.read_csv(path, sep=';')
    rows_cnt = len(df)

    print(f"Read {rows_cnt} rows from {path}")
    print(f"loading to Database ...")

    df.to_sql(
        table,
        conn,
        if_exists='append',
        index=False,
        chunksize=500
    )

    print(f"Loaded {rows_cnt} to {table}")

    move2archive(file_name)

def excel2sql(file_name, table, conn):
    path = DATA_FOLDER + file_name
    df = pd.read_excel(path)
    rows_cnt = len(df)

    print(f"Read {rows_cnt} rows from {path}")
    print(f"loading to Database ...")

    df.to_sql(
        table,
        conn,
        if_exists='append',
        index=False,
        chunksize=500
    )

    print(f"Loaded {rows_cnt} to {table}")

    move2archive(file_name)

def move2archive(file_name):

    os.rename(DATA_FOLDER + file_name, ARCHIVE_FOLDER + file_name + '.backup')

    print(f"{file_name}\n has been moved to archieve in {ARCHIVE_FOLDER}")

# txt2sql(r'transactions_01032021.txt', 'stg_transactions', conn)
# excel2sql(r'terminals_01032021.xlsx', 'stg_terminals', conn)
# excel2sql(r'passport_blacklist_01032021.xlsx', 'stg_passport_blacklist', conn)
