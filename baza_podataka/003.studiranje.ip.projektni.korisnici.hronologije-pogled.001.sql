use studiranje; 
drop view if exists st_user_chrono_latest;
create view st_user_chrono_latest as 
(
	select st_identification, st_timestamp, st_old_username, st_new_username, st_operation from st_user_chrono natural join
	(
		select st_operation, max(st_timestamp) as max_time, max(st_identification) as max_id
		from st_user_chrono 
        where st_operation = 'DELETE' and st_old_username is not null
		group by st_old_username
	) as max_group_time
	where st_timestamp =  max_time and st_identification = max_id
)
union distinct
(
	select st_identification, st_timestamp, st_old_username, st_new_username, st_operation from st_user_chrono natural join
	(
		select st_operation, max(st_timestamp) as max_time, max(st_identification) as max_id
		from st_user_chrono 
        where st_operation = 'INSERT' and st_new_username is not null
		group by st_new_username
	) as max_group_time
	where st_timestamp =  max_time and st_identification = max_id
)
union distinct
(
	select st_identification, st_timestamp, st_old_username, st_new_username, st_operation from st_user_chrono natural join
	(
		select st_operation, max(st_timestamp) as max_time, max(st_identification) as max_id
		from st_user_chrono 
        where st_operation = 'UPDATE' and st_new_username <> st_old_username
		group by st_new_username
	) as max_group_time
	where st_timestamp =  max_time and st_identification = max_id
)
union distinct
(
	select st_identification, st_timestamp, st_old_username, st_new_username, st_operation from st_user_chrono natural join
	(
		select st_operation, max(st_timestamp) as max_time, max(st_identification) as max_id
		from st_user_chrono 
        where st_operation = 'UPDATE' and st_new_username <> st_old_username
		group by st_old_username
	) as max_group_time
	where st_timestamp =  max_time and st_identification = max_id
)
union distinct
(
	select st_identification, st_timestamp, st_old_username, st_new_username, st_operation from st_user_chrono natural join
	(
		select st_operation, max(st_timestamp) as max_time, max(st_identification) as max_id
		from st_user_chrono 
        where st_operation = 'UPDATE' and st_new_username = st_old_username
		group by st_old_username
	) as max_group_time
	where st_timestamp =  max_time and st_identification = max_id
); 

