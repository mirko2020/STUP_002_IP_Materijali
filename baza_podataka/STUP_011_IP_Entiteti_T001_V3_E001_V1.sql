USE studiranje; 

DROP TRIGGER IF EXISTS st_entity_BI;

DELIMITER ZZ
CREATE TRIGGER st_entity_BI BEFORE INSERT ON st_entity
FOR EACH ROW 
BEGIN 
	DECLARE var_username VARCHAR(200) DEFAULT SUBSTRING_INDEX(SUBSTR(NEW.st_entity_uri, LENGTH('yi:user://')+1),':',1); 
	DECLARE var_authority VARCHAR(200) DEFAULT SUBSTRING_INDEX(SUBSTR(NEW.st_entity_uri, LENGTH('yi:user://')+1),'/',1);
    DECLARE var_path_url VARCHAR(200) DEFAULT SUBSTRING_INDEX(SUBSTR(NEW.st_entity_uri , LENGTH('yi:user://')+LENGTH(var_authority)+1),'/',3);
    DECLARE var_user_info varchar(200) DEFAULT SUBSTRING_INDEX(var_authority, '@', 1); 
    DECLARE var_table_id INTEGER; 
    
    IF NEW.st_entity_uri LIKE 'yi:user://%' THEN 
        SELECT st_identification INTO var_table_id 
        FROM st_user WHERE st_username = var_username LIMIT 1; 
		
        IF var_table_id  IS NULL THEN
        	SIGNAL SQLSTATE '45000'; 
        END IF; 
        IF  var_authority = var_user_info THEN 
			SIGNAL SQLSTATE '45000';
        END IF; 
        IF SUBSTRING_INDEX(var_authority, '@', 2) <> var_authority THEN 
			SIGNAL SQLSTATE '45000';
        END IF; 
        IF LENGTH(var_user_info) = 0 THEN 
			SIGNAL SQLSTATE '45000';
        END IF;
        IF var_user_info LIKE '%#%' THEN 
			SIGNAL SQLSTATE '45000';
        END IF; 
        IF var_user_info LIKE '%?%' THEN 
			SIGNAL SQLSTATE '45000';
        END IF; 
        IF  var_path_url <> '/studiranje/st_user' THEN 
			SIGNAL SQLSTATE '45000'; 
        END IF; 
        
        SET NEW.st_last_recording_time = CURRENT_TIMESTAMP; 
        SET NEW.st_table_identification = var_table_id; 
    END IF;
END ZZ
DELIMITER ; 
