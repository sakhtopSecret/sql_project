import json

import psycopg2
from sqlalchemy import create_engine


with open(r"src/creds.json", "r") as f:
    cred = json.load(f)

def create_conn():

    conn = psycopg2.connect(
        database=cred['database'],
        user=cred['user'],
        host=cred['host'],
        password=cred['password'],
        port=cred['port'],
        options='-c search_path=' + cred['schema']
    )

    return conn

def create_sqlalcheme_engine():

    return create_engine(
        f"postgresql://"
        f"{cred['user']}:"
        f"{cred['password']}@"
        f"{cred['host']}:"
        f"{cred['port']}/"
        f"{cred['database']}",
        connect_args={'options': f"-csearch_path={cred['schema']}"},
    )
