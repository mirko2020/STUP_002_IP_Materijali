USE studiranje; 

DROP PROCEDURE IF EXISTS bap_stuiranje_add_user;
DELIMITER ZZ
CREATE PROCEDURE bap_stuiranje_add_user(param_username varchar(100))
BEGIN 
	DECLARE var_password varchar(100); 
	IF param_username IN (SELECT st_username FROM st_user) THEN 
		SELECT st_password_hash INTO var_password 
        FROM st_user WHERE st_username = param_username
        LIMIT 1;
        IF var_password IS NULL THEN 
			SIGNAL SQLSTATE '45000';
		END IF;
		SET @var_statement = CONCAT("DROP USER IF EXISTS '",param_username,"'@'localhost';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
        SET @var_statement = CONCAT("CREATE USER '",param_username,"'@'localhost' IDENTIFIED BY '",var_password,"';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
	ELSE 
		SIGNAL SQLSTATE '45000';
    END IF; 
END ZZ
DELIMITER ;

DROP PROCEDURE IF EXISTS bap_stuiranje_delete_user; 
DELIMITER ZZ
CREATE PROCEDURE bap_stuiranje_delete_user(param_username varchar(100))
BEGIN 
	IF param_username IN (SELECT USER FROM MYSQL.USER WHERE HOST='localhost') THEN
		SET @var_statement = CONCAT("DROP USER IF EXISTS '",param_username,"'@'localhost';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
		DELETE FROM MYSQL.USER WHERE USER = param_username AND HOST='localhost';
    END IF; 
END ZZ
DELIMITER ;

DROP PROCEDURE IF EXISTS bap_stuiranje_info_user; 
DELIMITER ZZ
CREATE PROCEDURE bap_stuiranje_info_user(param_username varchar(100))
BEGIN 
    SELECT * FROM MYSQL.USER WHERE USER = param_username AND HOST='localhost';
END ZZ
DELIMITER ;

DROP PROCEDURE IF EXISTS bap_stuiranje_info_schema_user; 
DELIMITER ZZ
CREATE PROCEDURE bap_stuiranje_info_schema_user()
BEGIN 
    DESC MYSQL.USER; 
END ZZ
DELIMITER ;

