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
