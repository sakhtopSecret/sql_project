SELECT
	transaction_id::int8,
	transaction_date,
	card_num,
	oper_type,
	REPLACE(amount, ',', '.')::float as amount,
	oper_result,
	terminal AS terminal_id
FROM
	final_project.stg_transactions;
