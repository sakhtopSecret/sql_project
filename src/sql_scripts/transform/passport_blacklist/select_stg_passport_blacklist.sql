SELECT 
	dc.client_id
FROM stg_passport_blacklist pb
JOIN
	dwh_dim_clients dc 
	ON replace(pb.passport, ' ', '') = replace(dc.passport_num, ' ', '');
