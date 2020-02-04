use studiranje; 

select st_identification, st_timestamp from st_user_chrono where st_operation='INSERT' ORDER BY st_timestamp DESC,  st_identification DESC; 
select st_identification, st_timestamp from st_user_chrono where st_operation='DELETE' ORDER BY st_timestamp DESC,  st_identification DESC; 
select st_identification, st_timestamp from st_user_chrono where st_operation='UPDATE' AND st_old_username=st_new_username ORDER BY st_timestamp DESC,  st_identification DESC; 
select st_identification, st_timestamp from st_user_chrono where st_operation='UPDATE' AND st_old_username<>st_new_username ORDER BY st_timestamp DESC,  st_identification DESC; 

select count(*) from st_user_chrono where st_operation='INSERT'; 
select count(*) from st_user_chrono where st_operation='DELETE'; 
select count(*) from st_user_chrono where st_operation='UPDATE' AND st_old_username=st_new_username; 
select count(*) from st_user_chrono where st_operation='UPDATE' AND st_old_username<>st_new_username; 

select st_operation, count(*) from st_user_chrono group by st_operation; 

call st_user_chrono_for_user('miodrag');