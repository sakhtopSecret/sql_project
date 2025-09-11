## Создать виртуальное окружение и установить зависимости
`python -m venv .venv`
`.venv/Scripts/pip install -r requirements.txt`

## Вписать детали подключения в creds.json

## Создать БД
`.venv/Scripts/python ./src/py_scripts/create_db.py`

## Запустить скрипт
`.venv/Scripts/python ./src/main.py`

### На входе принимает дату и запускает обработку для файлов с ней
