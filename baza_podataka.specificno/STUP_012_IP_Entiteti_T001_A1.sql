USE studiranje; 

DROP TABLE IF EXISTS stbap_database_info; 
DROP TABLE IF EXISTS bap_database_info; 

CREATE TABLE bap_database_info (
	db_identification INTEGER PRIMARY KEY AUTO_INCREMENT,
    db_username_id INTEGER NOT NULL, 
    db_password_info VARCHAR(1000) NOT NULL, 
	
    CONSTRAINT FK_db_username_id FOREIGN KEY (db_username_id) 
    REFERENCES st_user(st_identification)
    ON DELETE CASCADE
); 

DROP PROCEDURE IF EXISTS `bap_stuiranje_add_user`; 
DELIMITER ZZ
CREATE DEFINER=`root`@`localhost` PROCEDURE `bap_stuiranje_add_user`(param_username VARCHAR(100), param_password VARCHAR(200), param_password_info VARCHAR(1000))
BEGIN 
	DECLARE var_user_id varchar(100); 
    DECLARE var_password varchar(100); 
	IF param_username IN (SELECT st_username FROM st_user) THEN 
		SELECT st_password_hash, st_identification INTO var_password, var_user_id
        FROM st_user WHERE st_username = param_username
        LIMIT 1;
        IF var_password IS NULL OR var_user_id IS NULL THEN 
			SIGNAL SQLSTATE '45000';
		END IF;
		SET @var_statement = CONCAT("DROP USER IF EXISTS '",param_username,"'@'localhost';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
        SET @var_statement = CONCAT("CREATE USER '",param_username,"'@'localhost' IDENTIFIED BY '",param_password,"';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
        INSERT INTO bap_database_info(db_username_id, db_password_info)
        VALUES (var_user_id, param_password_info); 
	ELSE 
		SIGNAL SQLSTATE '45000';
    END IF; 
END ZZ
DELIMITER ; 


DROP TRIGGER IF EXISTS st_user_AD;  
DELIMITER ZZ
CREATE DEFINER=`root`@`localhost` TRIGGER st_user_AD AFTER DELETE ON st_user
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
    
    DELETE FROM st_entity WHERE st_entity_uri LIKE CONCAT('yi:user://',OLD.st_username, ":%");
    IF OLD.st_username IN (SELECT USER FROM MYSQL.USER WHERE HOST='localhost') THEN
		DELETE FROM MYSQL.USER WHERE USER = OLD.st_username AND HOST='localhost';
    END IF; 
END ZZ
DELIMITER ;


DROP TRIGGER IF EXISTS st_user_BD; 
DELIMITER ZZ
CREATE TRIGGER st_user_BD BEFORE DELETE ON st_user
FOR EACH ROW
BEGIN 
	DELETE FROM bap_database_info WHERE db_username_id IN 
    (SELECT st_identification FROM st_user WHERE st_username = OLD.st_username); 
END ZZ
DELIMITER ; 

DROP PROCEDURE IF EXISTS `bap_stuiranje_delete_user`; 
DELIMITER ZZ
CREATE DEFINER=`root`@`localhost` PROCEDURE `bap_stuiranje_delete_user`(param_username varchar(100))
BEGIN 
	IF param_username IN (SELECT USER FROM MYSQL.USER WHERE HOST='localhost') THEN
		SET @var_statement = CONCAT("DROP USER IF EXISTS '",param_username,"'@'localhost';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
		DELETE FROM MYSQL.USER WHERE USER = param_username AND HOST='localhost';
        DELETE FROM bap_database_info WHERE db_username_id IN 
			(SELECT st_identification FROM st_user WHERE st_username = param_username); 
    END IF; 
END ZZ
DELIMITER ;