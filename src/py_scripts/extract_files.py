import os
from datetime import datetime

import pandas as pd

from py_scripts.db_functions import create_sqlalcheme_engine

conn = create_sqlalcheme_engine()

DATA_FOLDER = 'src/data/'
ARCHIVE_FOLDER = 'src/archive/'

def get_files_from_input(date):

    file_list = []
    for file in os.listdir(DATA_FOLDER):
        if date in file:
            file_list.append(file)

    return file_list

def files2sql(file_list, date):
    for file in file_list:
        table = 'stg_' + '_'.join(file.split('_')[0:-1]) 
        if file.endswith(".txt"):
            txt2sql(file, table, conn, date)

        elif file.endswith(".xlsx"):
            excel2sql(file, table, conn, date)

        else:
            print("Ошибка чтения, неподходящий формат")

def txt2sql(file_name: str, table, conn, date):
    path = DATA_FOLDER + file_name
    df = pd.read_csv(path, sep=';')
    rows_cnt = len(df)

    print(f"Read {rows_cnt} rows from {path}")
    print(f"loading to Database ...")

    df["file_date"] = datetime.strptime(date, "%d%m%Y").strftime("%Y-%m-%d")
    df.to_sql(
        table,
        conn,
        if_exists='append',
        index=False,
        chunksize=500
    )

    print(f"Loaded {rows_cnt} to {table}")

    move2archive(file_name)

def excel2sql(file_name, table, conn, date):
    path = DATA_FOLDER + file_name
    df = pd.read_excel(path)
    rows_cnt = len(df)

    print(f"Read {rows_cnt} rows from {path}")
    print(f"loading to Database ...")

    df["file_date"] = datetime.strptime(date, "%d%m%Y").strftime("%Y-%m-%d")
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
