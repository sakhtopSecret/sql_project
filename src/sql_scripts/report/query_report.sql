WITH cte_frod_transactions AS (SELECT 
	frod_transaction_id
	FROM (
		SELECT
			CASE
				WHEN
					-- Интервал между тремя транзакциями менее 20 минут
					(
					lead(transaction_date) OVER (PARTITION BY card_num ORDER BY transaction_date) -
					lag(transaction_date) OVER (PARTITION BY card_num ORDER BY transaction_date)
					) < '20 minutes'::interval 
					-- Только последняя операция должна быть успешной
					AND lead(oper_result) OVER (PARTITION BY card_num ORDER BY transaction_date) = 'SUCCESS'
					AND lag(oper_result) OVER (PARTITION BY card_num ORDER BY transaction_date) = 'REJECT'
					AND oper_result = 'REJECT'
					-- Последняя операция должна быть самой маленькой по сумме
					AND lag(amount) OVER (PARTITION BY card_num ORDER BY transaction_date) < amount
					AND lead(amount) OVER (PARTITION BY card_num ORDER BY transaction_date) > amount
				-- Возвращаем id последней транзакции в цепочке
				THEN lead(transaction_id) OVER (PARTITION BY card_num ORDER BY transaction_date)
			END AS "frod_transaction_id"
		FROM
			dwh_fact_transactions dft
		)
	WHERE frod_transaction_id IS NOT NULL
	)
SELECT 
	t1.transaction_date AS event_dt,
	t4.passport_num,
	concat(t4.last_name, ' ', t4.first_name, ' ', t4.patronymic) AS fio,
	t4.phone,
	'Подбор суммы' AS "event_type"
FROM dwh_fact_transactions t1
INNER JOIN dwh_dim_cards t2 ON t1.card_num = t2.card_num
INNER JOIN dwh_dim_accounts t3 ON t2.account = t3.account
INNER JOIN dwh_dim_clients t4 ON t3.client_id = t4.client_id
WHERE 1=1
	AND t1.transaction_id IN (SELECT frod_transaction_id FROM cte_frod_transactions)
	
UNION ALL 

SELECT
	t1.transaction_date AS event_dt,
	t4.passport_num,
	concat(t4.last_name, ' ', t4.first_name, ' ', t4.patronymic) AS fio,
	t4.phone,
	'Совершение операции при просроченном паспотре' AS "event_type"
FROM dwh_fact_transactions t1 
INNER JOIN dwh_dim_cards t2 ON t1.card_num = t2.card_num
INNER JOIN dwh_dim_accounts t3 ON t2.account = t3.account
INNER JOIN dwh_dim_clients t4 ON t3.client_id = t4.client_id
WHERE 1=1
	AND t4.passport_valid_to < t1.transaction_date

UNION ALL

SELECT
	t1.transaction_date AS event_dt,
	t4.passport_num,
	concat(t4.last_name, ' ', t4.first_name, ' ', t4.patronymic) AS fio,
	t4.phone,
	'Паспорт в черном списке' AS "event_type"
FROM dwh_fact_transactions t1 
INNER JOIN dwh_dim_cards t2 ON t1.card_num = t2.card_num
INNER JOIN dwh_dim_accounts t3 ON t2.account = t3.account
INNER JOIN dwh_dim_clients t4 ON t3.client_id = t4.client_id
INNER JOIN dwh_fact_passport_blacklist t5 
	ON t4.client_id = t5.client_id 
	AND t1.transaction_date BETWEEN t5.effective_from AND t5.effective_to  

UNION ALL

SELECT
	t1.transaction_date AS event_dt,
	t4.passport_num,
	concat(t4.last_name, ' ', t4.first_name, ' ', t4.patronymic) AS fio,
	t4.phone,
	'Совершение операции при просроченном договоре' AS "event_type"
FROM dwh_fact_transactions t1 
INNER JOIN dwh_dim_cards t2 ON t1.card_num = t2.card_num
INNER JOIN dwh_dim_accounts t3 ON t2.account = t3.account
INNER JOIN dwh_dim_clients t4 ON t3.client_id = t4.client_id
WHERE 1=1
	AND t3.valid_to < t1.transaction_date
	
UNION ALL 

SELECT 
	t3.event_dt,
	t6.passport_num,
	concat(t6.last_name, ' ', t6.first_name, ' ', t6.patronymic) AS fio,
	t6.phone,
	'Совершение операций в течение одного часа в разных городах' AS "event_type"
FROM
	(SELECT DISTINCT
		t1.transaction_date AS "event_dt",
	    t1.card_num,
	    t1.transaction_date,
	    t1.terminal_id,
	    t2.terminal_city
	FROM dwh_fact_transactions t1
	JOIN dwh_dim_terminals t2 ON t1.terminal_id = t2.terminal_id
	JOIN dwh_fact_transactions t1_other ON t1.card_num = t1_other.card_num
	JOIN dwh_dim_terminals t2_other ON t1_other.terminal_id = t2_other.terminal_id
	WHERE 1=1
		AND t2."date"::date = t1.transaction_date::date
		AND t2.terminal_city <> t2_other.terminal_city
	  	AND t1_other.transaction_date BETWEEN 
	      	t1.transaction_date - INTERVAL '1 hour'
      		AND t1.transaction_date + INTERVAL '1 hour'
	) t3
INNER JOIN dwh_dim_cards t4 ON t3.card_num = t4.card_num
INNER JOIN dwh_dim_accounts t5 ON t4.account = t5.account
INNER JOIN dwh_dim_clients t6 ON t5.client_id = t6.client_id;
