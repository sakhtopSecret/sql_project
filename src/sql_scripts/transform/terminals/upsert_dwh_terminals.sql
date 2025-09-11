INSERT INTO dwh_dim_terminals (
	terminal_id,
	terminal_type,
	terminal_city,
	terminal_address,
	date
) VALUES
(:terminal_id, :terminal_type, :terminal_city, :terminal_address, :date)
