INSERT INTO dwh_fact_transactions (
	transaction_id,
	transaction_date,
	card_num,
	oper_type,
	amount,
	oper_result,
	terminal_id
) VALUES
(	
	:transaction_id, :transaction_date, :card_num, :oper_type, 
	:amount, :oper_result, :terminal_id
)
ON CONFLICT ON CONSTRAINT dwh_fact_transactions_pkey
DO NOTHING;
