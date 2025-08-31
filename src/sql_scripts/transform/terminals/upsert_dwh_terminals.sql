INSERT INTO dwh_dim_terminals (
	terminal_id,
	terminal_type,
	terminal_city,
	terminal_address
) VALUES
(:terminal_id, :terminal_type, :terminal_city, :terminal_address)
ON CONFLICT ON CONSTRAINT dwh_dim_terminals_pkey
DO UPDATE SET
	terminal_type = :terminal_type,
	terminal_city = :terminal_city,
	terminal_address = :terminal_address,
	update_dt = current_timestamp
;