begin;

create temp table temp_new_blacklist(
	client_id varchar,
	effective_from timestamp
);

INSERT INTO temp_new_blacklist (
	client_id,
	effective_from
) VALUES
(:client_id, :effective_from);

UPDATE dwh_fact_passport_blacklist
SET deleted_flag = true,
	effective_to = (SELECT effective_from FROM temp_new_blacklist limit 1)
WHERE deleted_flag = false
  AND client_id NOT IN (SELECT client_id FROM temp_new_blacklist);

INSERT INTO dwh_fact_passport_blacklist
	(client_id, effective_from, deleted_flag)
SELECT client_id, effective_from, false
FROM temp_new_blacklist t2
WHERE t2.client_id NOT IN (SELECT client_id FROM dwh_fact_passport_blacklist);

drop table temp_new_blacklist;

commit;
