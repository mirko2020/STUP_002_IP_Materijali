USE studiranje; 

DROP TRIGGER IF EXISTS st_entity_AI; 

DELIMITER ZZ
CREATE TRIGGER  st_entity_AI AFTER INSERT ON st_entity
FOR EACH ROW 
BEGIN 
	DECLARE var_username VARCHAR(200) DEFAULT SUBSTRING_INDEX(SUBSTR(NEW.st_entity_uri, LENGTH('yi:user://')+1),':',1); 
	DECLARE var_table_id INTEGER; 
	IF NEW.st_entity_uri LIKE 'yi:user://' THEN 
		SELECT st_identification INTO var_table_id 
        FROM st_user WHERE st_username = var_username LIMIT 1; 
    END IF; 
    UPDATE st_entity 
    SET st_last_recording_time = CURRENT_TIMESTAMP,
        st_table_identification = var_table_id
    WHERE st_identification = NEW.st_identification; 
END ZZ
DELIMITER ; 

DROP TRIGGER IF EXISTS st_entity_BI;

DELIMITER ZZ
CREATE TRIGGER st_entity_BI BEFORE INSERT ON st_entity
FOR EACH ROW 
BEGIN 
	DECLARE var_authority VARCHAR(200) DEFAULT SUBSTRING_INDEX(SUBSTR(NEW.st_entity_uri, LENGTH('yi:user://')+1),'/',1);
    DECLARE var_path_url VARCHAR(200) DEFAULT SUBSTRING_INDEX(SUBSTR(NEW.st_entity_uri , LENGTH('yi:user://')+LENGTH(var_authority)+1),'/',3);
    DECLARE var_user_info varchar(200) DEFAULT SUBSTRING_INDEX(var_path_url, '@', 1); 
    DECLARE var_table_id INTEGER; 
    IF NEW.st_entity_uri LIKE 'yi:user://' THEN 
        SELECT st_identification INTO var_table_id 
        FROM st_user WHERE st_username = var_username LIMIT 1; 
        IF var_table_id  IS NULL THEN
        	SIGNAL SQLSTATE '45000'; 
        END IF; 
        IF  var_path_url = var_user_info THEN 
			SIGNAL SQLSTATE '45000';
        END IF; 
        IF SUBSTRING_INDEX(var_path_url, '@', 1) <> var_path_url THEN 
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
    END IF;
END ZZ
DELIMITER ; 

SELECT 'Ma?A' LIKE '%?%';
SELECT SUBSTRING_INDEX(SUBSTR('yi:user://marko:asaas%23as:1236:SHA-1@localhost:3306/studiranje/st_user', LENGTH('yi:user://')+1),'/',1) AS x; 
SELECT SUBSTRING_INDEX(SUBSTR('yi:user://marko:asaas%23as:1236:SHA-1@localhost:3306/studiranje/st_user', LENGTH('yi:user://')+LENGTH(SUBSTRING_INDEX(SUBSTR('yi:user://marko:asaas%23as:1236:SHA-1@localhost:3306/studiranje/st_user', LENGTH('yi:user://')+1),'/',1))+1),'/',3) AS x; 