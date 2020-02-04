use studiranje; 

drop procedure if exists st_user_chrono_for_user; 

delimiter ZZ
create procedure st_user_chrono_for_user(in param_username varchar(100))
begin 
	DECLARE var_id INTEGER;
	DECLARE var_old VARCHAR(100);
    DECLARE var_new VARCHAR(100) DEFAULT param_username;
    DECLARE var_op VARCHAR(100);
    
    DECLARE temp_id INTEGER;
    DECLARE temp_timestamp TIMESTAMP;
	DECLARE temp_old VARCHAR(100);
    DECLARE temp_new VARCHAR(100);
    DECLARE temp_op VARCHAR(100);
    
    DECLARE var_old_id INTEGER;
    
    DECLARE config_insert BOOLEAN DEFAULT FALSE; 
    
	start transaction; 
    drop temporary table if exists temp_results; 
    create temporary table temp_results (
		st_identification integer not null unique,
        st_timestamp timestamp not null,
        st_old_username varchar(100), 
        st_new_username varchar(100), 
        st_operation set('INSERT', 'UPDATE', 'DELETE') not null
    ); 
    
	if (select count(*) from st_user where st_username=param_username)=0 then  
		select st_identification,st_timestamp,st_old_username,st_new_username,st_operation  from temp_results; 
		drop temporary table temp_results;
    
		commit work; 
    else
    
		X: LOOP 
			SELECT var_id INTO var_old_id; 
			IF var_new  IS NULL THEN 
				LEAVE X;
			END IF;
			
			SELECT st_identification, st_new_username, st_old_username, st_operation 
			INTO var_id, var_new, var_old, var_op FROM st_user_chrono 
			WHERE st_new_username = var_new AND config_insert <> TRUE
            AND (var_id IS NULL OR st_identification < var_id)
			ORDER BY st_timestamp DESC, st_identification DESC LIMIT 1;
			
			IF var_id IS NULL OR var_id = var_old_id THEN 
				SELECT st_identification, st_new_username, st_old_username, st_operation 
				INTO var_id, var_new, var_old, var_op FROM st_user_chrono 
				WHERE st_old_username = var_new AND st_operation = 'DELETE'
				AND (var_id IS NULL OR st_identification < var_id)
				ORDER BY st_timestamp DESC, st_identification DESC LIMIT 1;
			END IF; 
			
			
			
			IF var_id IS NULL OR var_id = var_old_id THEN 
				LEAVE X; 
			ELSE 
				IF var_op = 'UPDATE' THEN
					IF (SELECT COUNT(*) FROM st_user_chrono WHERE st_identification = var_id)=1 THEN
						SELECT st_identification,st_timestamp,st_old_username,st_new_username,st_operation 
						INTO temp_id, temp_timestamp, temp_old, temp_new, temp_op
						FROM st_user_chrono WHERE st_identification = var_id;
						INSERT INTO temp_results(st_identification,st_timestamp,st_old_username,st_new_username,st_operation)
						VALUES (temp_id, temp_timestamp, temp_old, temp_new, temp_op); 
					END IF;
					SET var_new = var_old; 
				ELSEIF var_op = 'INSERT' THEN 
					IF (SELECT COUNT(*) FROM st_user_chrono WHERE st_identification = var_id)=1 THEN
						SELECT st_identification,st_timestamp,st_old_username,st_new_username,st_operation 
						INTO temp_id, temp_timestamp, temp_old, temp_new, temp_op
						FROM st_user_chrono WHERE st_identification = var_id;
						INSERT INTO temp_results(st_identification,st_timestamp,st_old_username,st_new_username,st_operation)
						VALUES (temp_id, temp_timestamp, temp_old, temp_new, temp_op); 
					END IF; 
                    SET config_insert = TRUE; 
				ELSEIF var_op = 'DELETE' THEN 
					IF (SELECT COUNT(*) FROM st_user_chrono WHERE st_identification = var_id)=1 THEN
						SELECT st_identification,st_timestamp,st_old_username,st_new_username,st_operation 
						INTO temp_id, temp_timestamp, temp_old, temp_new, temp_op
						FROM st_user_chrono WHERE st_identification = var_id;
						INSERT INTO temp_results(st_identification,st_timestamp,st_old_username,st_new_username,st_operation)
						VALUES (temp_id, temp_timestamp, temp_old, temp_new, temp_op); 
						SET var_new = var_old; 
					END IF; 
				END IF; 
			END IF; 
		END LOOP;
		
		select st_identification,st_timestamp,st_old_username,st_new_username,st_operation  from temp_results; 
		drop temporary table temp_results;
		
		commit work; 
	end if; 
end ZZ
delimiter ; 