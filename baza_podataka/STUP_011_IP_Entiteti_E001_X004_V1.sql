USE studiranje; 

DROP TRIGGER IF EXISTS st_user_AD; 

DELIMITER $$
CREATE TRIGGER st_user_AD AFTER DELETE ON st_user
FOR EACH ROW 
BEGIN 
	DECLARE var_id INTEGER;
	DECLARE var_old VARCHAR(100);
    DECLARE var_new VARCHAR(100);
    DECLARE var_op VARCHAR(100);
    SET var_new = OLD.st_username; 
    X:LOOP
		IF var_new  is null THEN 
			LEAVE X;
        END IF;
		SELECT st_identification, st_new_username, st_old_username, st_operation 
        INTO var_id, var_new, var_old, var_op FROM st_user_chrono 
        WHERE st_new_username = var_new
        ORDER BY st_timestamp DESC, st_identification DESC LIMIT 1; 
        IF var_id is NULL THEN 
			LEAVE X; 
		ELSE 
			IF var_op = 'UPDATE' THEN
				DELETE FROM st_user_chrono WHERE st_identification = var_id; 
            ELSEIF var_op = 'INSERT' THEN 
				DELETE FROM st_user_chrono WHERE st_identification = var_id; 
                DELETE FROM st_user_chrono WHERE st_operation = 'DELETE' AND 
					st_old_username = var_new; 
				DELETE FROM st_user_chrono WHERE st_operation = 'DELETE' AND 
					st_old_username = OLD.st_username; 
            END IF; 
        END IF; 
		SET var_id = NULL;
        SET var_new = var_old; 
	END LOOP; 
    INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('DELETE', old.st_username, null);  
    
    DELETE FROM st_entity WHERE st_entity_uri LIKE CONCAT('yi:user://',OLD.st_username, "%");
END$$
DELIMITER ; 