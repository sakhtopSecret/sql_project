/*
	STG
*/

CREATE TABLE IF NOT EXISTS stg_terminals(
	terminal_id varchar,
	terminal_type varchar,
	terminal_city varchar,
	terminal_address varchar,
	file_date timestamp
);

CREATE TABLE IF NOT EXISTS stg_transactions(
	transaction_id varchar,
	transaction_date timestamp,
	card_num varchar,
	oper_type varchar,
	amount varchar,
	oper_result varchar,
	terminal varchar,
	file_date timestamp
);

CREATE TABLE IF NOT EXISTS stg_passport_blacklist(
	date date,
	passport varchar,
	file_date timestamp
);


/*
	DWH
*/

CREATE TABLE IF NOT EXISTS dwh_dim_clients(
    client_id varchar(128) primary key not null, 
    last_name varchar(128), 
    first_name varchar(128), 
    patronymic varchar(128), 
    date_of_birth date, 
    passport_num varchar(128), 
    passport_valid_to date, 
    phone varchar(128),
    create_dt date, 
    update_dt date
);

CREATE TABLE  IF NOT EXISTS dwh_dim_accounts(
	account varchar(128) primary key not null, 
	valid_to date, 
	client_id varchar(128) references dwh_dim_clients (client_id),
	create_dt date, 
	update_dt date
);


CREATE TABLE  IF NOT EXISTS dwh_dim_cards(
	card_num varchar(128) unique not null, 
	account varchar(128) references dwh_dim_accounts (account), 
	create_dt date,
	update_dt date
);

CREATE TABLE IF NOT EXISTS dwh_dim_terminals(
	terminal_id varchar not null,
	terminal_type varchar,
	terminal_city varchar,
	terminal_address varchar,
	date timestamp,
	create_dt timestamp default current_timestamp,
	update_dt timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS dwh_fact_transactions(
	transaction_id bigint primary key not null,
	transaction_date timestamp,
	card_num varchar references dwh_dim_cards (card_num),
	oper_type varchar,
	amount numeric,
	oper_result varchar,
	terminal_id varchar
);

CREATE TABLE IF NOT EXISTS dwh_fact_passport_blacklist(
	id serial primary key not null,
	client_id varchar references dwh_dim_clients (client_id),
	effective_from timestamp,
	effective_to timestamp default ('5999-12-23 23:59:59'::timestamp),
	deleted_flag boolean default false
);

CREATE TABLE IF NOT EXISTS rep_fraud(
	event_dt timestamp,
	passport_num varchar(128),
	fio varchar(400),
	phone varchar(64),
	event_type varchar(255),
	report_dt timestamp default current_timestamp
)
