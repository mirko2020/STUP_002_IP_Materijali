USE studiranje; 

DROP TRIGGER IF EXISTS st_user_AU; 

DELIMITER %%
CREATE TRIGGER st_user_AU  AFTER UPDATE ON st_user 
FOR EACH ROW 
BEGIN 
	DECLARE varp_protocol VARCHAR(100);
    DECLARE varp_user VARCHAR(100);
    DECLARE varp_password VARCHAR(100);
    DECLARE varp_salt VARCHAR(100);
    DECLARE varp_algorithm VARCHAR(100); 
    DECLARE varp_host VARCHAR(100);
    DECLARE varp_port VARCHAR(100);
    DECLARE varp_path VARCHAR(100);
    DECLARE varp_repeat VARCHAR(100); 
    DECLARE varp_query VARCHAR(100);
    DECLARE varp_fragment VARCHAR(100);
    
    DECLARE vartemp_uri VARCHAR(1000); 
    DECLARE vartemp_user_info VARCHAR(1000);
    DECLARE vartemp_host_info VARCHAR(1000); 
    DECLARE vartemp_password_info VARCHAR(1000); 
    
    DECLARE var_old_username VARCHAR(100) DEFAULT OLD.st_username; 
    DECLARE var_neo_username VARCHAR(100) DEFAULT NEW.st_username; 
    
    DECLARE temp VARCHAR(1000); 
    
	INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('UPDATE', OLD.st_username, NEW.st_username);
    
    IF var_neo_username <> var_old_username THEN 
        UPDATE MYSQL.USER  SET USER = var_neo_username WHERE USER = var_old_username; 
		
		SELECT st_entity.st_entity_uri INTO vartemp_uri FROM st_entity
		WHERE st_entity.st_table_identification = OLD.st_identification
		AND st_entity.st_table_name = 'st_user'  LIMIT 1; 
        
		IF vartemp_uri IS NOT NULL THEN 
			SET varp_protocol = SUBSTRING_INDEX(vartemp_uri, "//", 1); 
			SET temp = SUBSTRING(vartemp_uri, LENGTH(varp_protocol)+3); 
			SET vartemp_user_info = SUBSTRING_INDEX(temp, "/", 1); 
			SET temp = SUBSTRING(temp, LENGTH(vartemp_user_info)+1); 
			SET varp_path = SUBSTRING_INDEX(temp, "?", 1);
			SET temp = SUBSTRING(temp, LENGTH(varp_path)+1);
			SET varp_query = SUBSTRING_INDEX(temp, "?", 1);
			SET varp_fragment = SUBSTRING(temp, LENGTH(varp_query)+1);
			SET temp = vartemp_user_info; 
			SET vartemp_user_info = SUBSTRING_INDEX(temp, "@", 1); 
			IF vartemp_user_info = temp THEN 
				SET vartemp_host_info = temp;
				SET vartemp_user_info = NULL;
			ELSE 
				SET vartemp_host_info = SUBSTRING(temp, LENGTH(vartemp_user_info)+2); 
				SET varp_user = SUBSTRING_INDEX(vartemp_user_info, ":", 1); 
				SET vartemp_password_info = SUBSTRING(vartemp_user_info, LENGTH(varp_user)+2);
				
				SET varp_password = SUBSTRING_INDEX(vartemp_password_info, ":", 1); 
				SET temp = SUBSTRING(vartemp_password_info, LENGTH(varp_password)+2); 
				
				SET varp_salt = SUBSTRING_INDEX(temp, ":", 1);  
				SET temp = SUBSTRING(temp, LENGTH(varp_salt)+2);
				
				SET varp_algorithm = SUBSTRING_INDEX(temp, ":", 1);  
				SET varp_repeat = SUBSTRING(temp, LENGTH(varp_algorithm)+2);
			END IF; 
			
			SET varp_host = SUBSTRING_INDEX(vartemp_host_info, ":", 1); 
			SET varp_port = SUBSTRING(vartemp_host_info, LENGTH(varp_host)+2); 
			
			IF vartemp_uri IS NOT NULL THEN 
				IF varp_user IS NULL THEN SET varp_user = ''; END IF;  
				IF varp_protocol IS NULL THEN SET varp_protocol = ''; END IF;  
				IF varp_password IS NULL THEN SET varp_password = ''; END IF; 
				IF varp_salt IS NULL THEN SET varp_salt = ''; END IF; 
				IF varp_algorithm IS NULL THEN SET varp_algorithm = ''; END IF; 
				IF varp_repeat IS NULL THEN SET varp_repeat = ''; END IF; 
				IF varp_host IS NULL THEN SET varp_host = ''; END IF; 
				IF varp_port IS NULL THEN SET varp_port = ''; END IF; 
				IF varp_path IS NULL THEN SET varp_path = ''; END IF; 
				IF varp_fragment IS NULL THEN SET varp_fragment = ''; END IF; 
				IF varp_query IS NULL THEN SET varp_query = ''; END IF; 
				SET temp =  CONCAT(varp_protocol, "//" , NEW.st_username, ":", 
						   varp_password, ":" , varp_salt, ":", 
						   varp_algorithm, ":", varp_repeat, "@",
						   varp_host, ":", varp_port, varp_path, 
						   varp_fragment, varp_query);
						   
				UPDATE st_entity SET st_entity_uri = temp 
				WHERE st_entity.st_entity_uri = vartemp_uri; 
			END IF;
		END IF; 
	END IF; 
END%%
DELIMITER ; 

DROP PROCEDURE IF EXISTS user_info_split_uri; 
DROP FUNCTION IF EXISTS user_info_split_uri; 

DELIMITER ZZ
CREATE PROCEDURE user_info_split_uri(INOUT param_username VARCHAR(100))
BEGIN
	DECLARE varp_protocol VARCHAR(100);
    DECLARE varp_user VARCHAR(100);
    DECLARE varp_password VARCHAR(100);
    DECLARE varp_salt VARCHAR(100);
    DECLARE varp_algorithm VARCHAR(100); 
    DECLARE varp_host VARCHAR(100);
    DECLARE varp_port VARCHAR(100);
    DECLARE varp_path VARCHAR(100);
    DECLARE varp_repeat VARCHAR(100); 
    DECLARE varp_query VARCHAR(100);
    DECLARE varp_fragment VARCHAR(100);
    
    DECLARE vartemp_uri VARCHAR(1000); 
    DECLARE vartemp_user_info VARCHAR(1000);
    DECLARE vartemp_host_info VARCHAR(1000); 
    DECLARE vartemp_password_info VARCHAR(1000); 
    
    DECLARE temp VARCHAR(1000); 
    
    SELECT st_entity_uri INTO vartemp_uri FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = param_username LIMIT 1; 
    
    IF vartemp_uri IS NOT NULL THEN 
		SET varp_protocol = SUBSTRING_INDEX(vartemp_uri, "//", 1); 
        SET temp = SUBSTRING(vartemp_uri, LENGTH(varp_protocol)+3); 
        SET vartemp_user_info = SUBSTRING_INDEX(temp, "/", 1); 
		SET temp = SUBSTRING(temp, LENGTH(vartemp_user_info)+1); 
        SET varp_path = SUBSTRING_INDEX(temp, "?", 1);
        SET temp = SUBSTRING(temp, LENGTH(varp_path)+1);
        SET varp_query = SUBSTRING_INDEX(temp, "?", 1);
        SET varp_fragment = SUBSTRING(temp, LENGTH(varp_query)+1);
        SET temp = vartemp_user_info; 
        SET vartemp_user_info = SUBSTRING_INDEX(temp, "@", 1); 
        IF vartemp_user_info = temp THEN 
			SET vartemp_host_info = temp;
            SET vartemp_user_info = NULL;
		ELSE 
			SET vartemp_host_info = SUBSTRING(temp, LENGTH(vartemp_user_info)+2); 
            SET varp_user = SUBSTRING_INDEX(vartemp_user_info, ":", 1); 
            SET vartemp_password_info = SUBSTRING(vartemp_user_info, LENGTH(varp_user)+2);
            
            SET varp_password = SUBSTRING_INDEX(vartemp_password_info, ":", 1); 
            SET temp = SUBSTRING(vartemp_password_info, LENGTH(varp_password)+2); 
            
            SET varp_salt = SUBSTRING_INDEX(temp, ":", 1);  
            SET temp = SUBSTRING(temp, LENGTH(varp_salt)+2);
            
            SET varp_algorithm = SUBSTRING_INDEX(temp, ":", 1);  
            SET varp_repeat = SUBSTRING(temp, LENGTH(varp_algorithm)+2);
		END IF; 
        
        SET varp_host = SUBSTRING_INDEX(vartemp_host_info, ":", 1); 
        SET varp_port = SUBSTRING(vartemp_host_info, LENGTH(varp_host)+2); 
    END IF; 
    
	SELECT varp_protocol, varp_user, varp_password, varp_salt, 
	   varp_algorithm, varp_repeat, varp_host, varp_port, 
	   varp_path, varp_fragment, varp_query;
END ZZ
DELIMITER ;


DROP TRIGGER IF EXISTS st_user_BU; 

DELIMITER ZZ
CREATE TRIGGER st_user_BU BEFORE UPDATE ON st_user
FOR EACH ROW
BEGIN 
	IF NEW.st_username IN (SELECT USER FROM MYSQL.USER WHERE USER=NEW.st_username) 
    AND NEW.st_username <> OLD.st_username THEN 
		SIGNAL SQLSTATE '45000';
	END IF;
END ZZ
DELIMITER ; 


SELECT SUBSTRING_INDEX(st_entity_uri, "//", 1) AS protocol INTO @test_temp_protocol FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = 'marko';

SELECT SUBSTRING(st_entity_uri, LENGTH(@test_temp_protocol)+3) AS body INTO @test_temp_body FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = 'marko';

SELECT SUBSTRING_INDEX(@test_temp_body, "/", 1) AS user_info INTO @test_temp_user_info FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = 'marko';

SELECT SUBSTRING(@test_temp_body, LENGTH(@test_temp_user_info)+1) AS body INTO @test_temp_path_fragment_query FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = 'marko';

SELECT @test_temp_protocol,  @test_temp_body; 
SELECT @test_temp_user_info, @test_temp_path_fragment_query; 

SET @test_temp_path_fragment_query = '/studiranje/st_user?info=data#goto_address'; 
SET @test_temp_path = SUBSTRING_INDEX(@test_temp_path_fragment_query, "?", 1); 
SET @test_temp_fragment_query = SUBSTRING(@test_temp_path_fragment_query, LENGTH(@test_temp_path)+1);  
SET @test_temp_query = SUBSTRING_INDEX(@test_temp_fragment_query, "#", 1); 
SET @test_temp_fragment = SUBSTRING(@test_temp_fragment_query, LENGTH(@test_temp_query)+1); 

SELECT @test_temp_path, @test_temp_fragment_query;
SELECT @test_temp_query, @test_temp_fragment; 

SET @test_temp = @test_temp_user_info; 
SET @test_temp_user_info = SUBSTRING_INDEX(@test_temp, "@", 1); 
SET @test_temp_host_info = SUBSTRING(@test_temp, LENGTH(@test_temp_user_info)+2); 

SELECT @test_temp_user_info, @test_temp_host_info; 

SET @test_temp_host = SUBSTRING_INDEX(@test_temp_host_info, ":", 1); 
SET @test_temp_port = SUBSTRING(@test_temp_host_info, LENGTH(@test_temp_host)+2);

SELECT @test_temp_host, @test_temp_port; 
 
SET @test_temp_user = SUBSTRING_INDEX(@test_temp_user_info, ":", 1); 
SET @test_temp_password_info = SUBSTRING(@test_temp_user_info, LENGTH(@test_temp_user)+2);

SELECT @test_temp_user, @test_temp_password_info; 

SET @test_temp_password = SUBSTRING_INDEX(@test_temp_password_info, ":", 1); 
SET @test_temp = SUBSTRING(@test_temp_password_info, LENGTH(@test_temp_password)+2); 

SET @test_temp_salt = SUBSTRING_INDEX(@test_temp, ":", 1);  
SET @test_temp = SUBSTRING(@test_temp, LENGTH(@test_temp_salt)+2);

SET @test_temp_algorithm = SUBSTRING_INDEX(@test_temp, ":", 1);  
SET @test_temp_repeat = SUBSTRING(@test_temp, LENGTH(@test_temp_algorithm)+2);

SELECT @test_temp_password, @test_temp_salt, @test_temp_algorithm, @test_temp_repeat; 

  (SELECT st_entity_uri FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = 'marko')
   UNION
  (SELECT st_entity_uri FROM st_entity, st_user
    WHERE st_entity.st_table_identification = st_user.st_identification
    AND st_entity.st_table_name = 'st_user' 
    AND st_user.st_username = 'janko');

SELECT USER FROM MYSQL.USER; 