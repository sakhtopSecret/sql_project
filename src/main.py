from py_scripts.extract_files import get_files_from_input, files2sql
from py_scripts.transform import stg2dwh
from py_scripts.report import dwh2report

# Загружаем данные из файлов в stg
print("Введите дату, за которые хотите загрузить файлы в формате ДДММГГГГ")
date = str(input())
files = get_files_from_input(date)
print("Чтение данных из файлов")
files2sql(files, date)
print()

# Загружаем данные в dwh
print("Трансформация файлов для DWH")
stg2dwh('terminals/select_stg_terminals.sql', 'terminals/upsert_dwh_terminals.sql')
stg2dwh('transactions/select_stg_transactions.sql', 'transactions/upsert_dwh_transactions.sql')
stg2dwh('passport_blacklist/select_stg_passport_blacklist.sql', 'passport_blacklist/update_dwh_passport_blacklist.sql')
print()

# Строим витрину
print("Построение витрины")
dwh2report()
