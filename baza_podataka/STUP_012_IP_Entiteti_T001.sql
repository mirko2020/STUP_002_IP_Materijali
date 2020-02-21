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



