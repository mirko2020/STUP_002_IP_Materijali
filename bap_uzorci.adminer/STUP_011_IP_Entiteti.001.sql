-- Adminer 4.7.1 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP DATABASE IF EXISTS `studiranje`;
CREATE DATABASE `studiranje` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `studiranje`;

DELIMITER ;;

CREATE PROCEDURE `bap_stuiranje_add_user`(param_username varchar(100))
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
END;;

CREATE PROCEDURE `bap_stuiranje_delete_user`(param_username varchar(100))
BEGIN 
	IF param_username IN (SELECT USER FROM MYSQL.USER WHERE HOST='localhost') THEN
		SET @var_statement = CONCAT("DROP USER IF EXISTS '",param_username,"'@'localhost';");  
        PREPARE stmt FROM @var_statement;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt; 
		DELETE FROM MYSQL.USER WHERE USER = param_username AND HOST='localhost';
    END IF; 
END;;

CREATE PROCEDURE `bap_stuiranje_info_schema_user`()
BEGIN 
    DESC MYSQL.USER; 
END;;

CREATE PROCEDURE `bap_stuiranje_info_user`(param_username varchar(100))
BEGIN 
    SELECT * FROM MYSQL.USER WHERE USER = param_username AND HOST='localhost';
END;;

CREATE PROCEDURE `st_user_chrono_for_user`(in param_username varchar(100))
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
end;;

DELIMITER ;

DROP TABLE IF EXISTS `st_entity`;
CREATE TABLE `st_entity` (
  `st_identification` int(11) NOT NULL AUTO_INCREMENT,
  `st_entity_uri` varchar(200) NOT NULL,
  `st_last_recording_time` timestamp NOT NULL,
  `st_table_identification` int(11) DEFAULT NULL,
  `st_table_name` varchar(100) DEFAULT NULL,
  `st_resource_url` varchar(100) DEFAULT NULL,
  `st_database_url` varchar(100) DEFAULT NULL,
  `st_communication_protocol` varchar(100) DEFAULT NULL,
  `st_subjectivity` set('GENERAL','SUBJECT','OBJECT','PREDICT','OPTIONAL','ACTION','EXECUTOR') NOT NULL DEFAULT 'GENERAL',
  `st_administrativity` set('ROOT_ADMIN','GENERAL_ADMIN','USER','ENTITY','GROUP','OPTIONAL') NOT NULL DEFAULT 'ENTITY',
  `st_estate_constraint` set('ROOT_ADMIN','GENERAL_ADMIN','OWNER','USER','ENTITY','GROUP','OPTIONAL') NOT NULL DEFAULT 'ENTITY',
  PRIMARY KEY (`st_identification`),
  UNIQUE KEY `st_entity_uri_UNIQUE` (`st_entity_uri`)
) ENGINE=MyISAM AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

INSERT INTO `st_entity` (`st_identification`, `st_entity_uri`, `st_last_recording_time`, `st_table_identification`, `st_table_name`, `st_resource_url`, `st_database_url`, `st_communication_protocol`, `st_subjectivity`, `st_administrativity`, `st_estate_constraint`) VALUES
(22,	'yi:user://janko:mR2yMHQvKOlK6L9NWl5nlWQvwOPwJWu57j9PLEHJzdA%3D:86531:SHA-256:3306@localhost:3306/studiranje/st_user',	'2020-02-05 15:27:22',	55,	'st_user',	NULL,	'//localhost:3306/studiranje/st_user',	NULL,	'EXECUTOR',	'GENERAL_ADMIN',	'GENERAL_ADMIN'),
(21,	'yi:user://marko:QpP2KVASJ306oAWVzzRvWJCmRwg25MmBlkB7jwhof%2Fc%3D:41760:SHA-256:3306@localhost:3306/studiranje/st_user',	'2020-02-05 13:23:56',	2,	'st_user',	NULL,	'//localhost:3306/studiranje/st_user',	NULL,	'EXECUTOR',	'GENERAL_ADMIN',	'GENERAL_ADMIN');

DELIMITER ;;

CREATE TRIGGER `st_entity_BI` BEFORE INSERT ON `st_entity` FOR EACH ROW
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
END;;

DELIMITER ;

DROP TABLE IF EXISTS `st_user`;
CREATE TABLE `st_user` (
  `st_identification` int(11) NOT NULL AUTO_INCREMENT,
  `st_username` varchar(100) NOT NULL,
  `st_firstname` varchar(100) DEFAULT NULL,
  `st_secondname` varchar(100) DEFAULT NULL,
  `st_email_address` varchar(100) DEFAULT NULL,
  `st_password_hash` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`st_identification`),
  UNIQUE KEY `st_username` (`st_username`)
) ENGINE=MyISAM AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;

INSERT INTO `st_user` (`st_identification`, `st_username`, `st_firstname`, `st_secondname`, `st_email_address`, `st_password_hash`) VALUES
(55,	'janko',	'Janko',	'Jankovic',	'janko.jankovic@gmail.com',	'86531$mR2yMHQvKOlK6L9NWl5nlWQvwOPwJWu57j9PLEHJzdA='),
(2,	'marko',	'Marko',	'Markovic',	'marko.markovic@gmail.com',	'41760$QpP2KVASJ306oAWVzzRvWJCmRwg25MmBlkB7jwhof/c=');

DELIMITER ;;

CREATE TRIGGER `st_user_BI` BEFORE INSERT ON `st_user` FOR EACH ROW
BEGIN 
	IF NOT (NEW.st_username REGEXP BINARY '^([a-zA-Z0-9_-]|\.)+$')  THEN
		SIGNAL SQLSTATE '45000'; 
    END IF; 
END;;

CREATE TRIGGER `st_user_AI` AFTER INSERT ON `st_user` FOR EACH ROW
BEGIN 
	INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('INSERT', null, new.st_username);  
END;;

CREATE TRIGGER `st_user_AU` AFTER UPDATE ON `st_user` FOR EACH ROW
BEGIN 
	INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('UPDATE', old.st_username, new.st_username);  
END;;

CREATE TRIGGER `st_user_AD` AFTER DELETE ON `st_user` FOR EACH ROW
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
END;;

DELIMITER ;

DROP TABLE IF EXISTS `st_user_chrono`;
CREATE TABLE `st_user_chrono` (
  `st_identification` int(11) NOT NULL AUTO_INCREMENT,
  `st_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `st_old_username` varchar(100) DEFAULT NULL,
  `st_new_username` varchar(100) DEFAULT NULL,
  `st_operation` set('INSERT','UPDATE','DELETE') NOT NULL,
  PRIMARY KEY (`st_identification`)
) ENGINE=MyISAM AUTO_INCREMENT=203 DEFAULT CHARSET=utf8;

INSERT INTO `st_user_chrono` (`st_identification`, `st_timestamp`, `st_old_username`, `st_new_username`, `st_operation`) VALUES
(153,	'2020-02-05 10:38:21',	'marko.1',	NULL,	'DELETE'),
(150,	'2020-02-05 10:37:19',	'marko-1',	NULL,	'DELETE'),
(144,	'2020-02-05 10:32:09',	'marko+1',	NULL,	'DELETE'),
(202,	'2020-02-05 15:39:01',	'jank',	NULL,	'DELETE'),
(135,	'2020-02-05 10:25:15',	'marko@a',	NULL,	'DELETE'),
(193,	'2020-02-05 13:13:01',	'mark',	NULL,	'DELETE'),
(100,	'2020-01-25 03:34:39',	'marko',	'marko',	'UPDATE'),
(101,	'2020-01-25 03:34:39',	'marko',	'marko',	'UPDATE'),
(171,	'2020-02-05 12:42:56',	'janko',	NULL,	'DELETE'),
(172,	'2020-02-05 12:50:49',	NULL,	'janko',	'INSERT'),
(173,	'2020-02-05 12:50:49',	'janko',	'janko',	'UPDATE'),
(174,	'2020-02-05 12:52:06',	'janko',	'janko',	'UPDATE'),
(175,	'2020-02-05 12:52:06',	'janko',	'janko',	'UPDATE');

DROP VIEW IF EXISTS `st_user_chrono_latest`;
CREATE TABLE `st_user_chrono_latest` (`st_identification` int(11), `st_timestamp` timestamp, `st_old_username` varchar(100), `st_new_username` varchar(100), `st_operation` varchar(20));


DROP TABLE IF EXISTS `st_user_chrono_latest`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `st_user_chrono_latest` AS (select `studiranje`.`st_user_chrono`.`st_identification` AS `st_identification`,`studiranje`.`st_user_chrono`.`st_timestamp` AS `st_timestamp`,`studiranje`.`st_user_chrono`.`st_old_username` AS `st_old_username`,`studiranje`.`st_user_chrono`.`st_new_username` AS `st_new_username`,`studiranje`.`st_user_chrono`.`st_operation` AS `st_operation` from (`studiranje`.`st_user_chrono` join (select `studiranje`.`st_user_chrono`.`st_operation` AS `st_operation`,max(`studiranje`.`st_user_chrono`.`st_timestamp`) AS `max_time`,max(`studiranje`.`st_user_chrono`.`st_identification`) AS `max_id` from `studiranje`.`st_user_chrono` where ((`studiranje`.`st_user_chrono`.`st_operation` = 'DELETE') and (`studiranje`.`st_user_chrono`.`st_old_username` is not null)) group by `studiranje`.`st_user_chrono`.`st_old_username`) `max_group_time` on((`studiranje`.`st_user_chrono`.`st_operation` = `max_group_time`.`st_operation`))) where ((`studiranje`.`st_user_chrono`.`st_timestamp` = `max_group_time`.`max_time`) and (`studiranje`.`st_user_chrono`.`st_identification` = `max_group_time`.`max_id`))) union (select `studiranje`.`st_user_chrono`.`st_identification` AS `st_identification`,`studiranje`.`st_user_chrono`.`st_timestamp` AS `st_timestamp`,`studiranje`.`st_user_chrono`.`st_old_username` AS `st_old_username`,`studiranje`.`st_user_chrono`.`st_new_username` AS `st_new_username`,`studiranje`.`st_user_chrono`.`st_operation` AS `st_operation` from (`studiranje`.`st_user_chrono` join (select `studiranje`.`st_user_chrono`.`st_operation` AS `st_operation`,max(`studiranje`.`st_user_chrono`.`st_timestamp`) AS `max_time`,max(`studiranje`.`st_user_chrono`.`st_identification`) AS `max_id` from `studiranje`.`st_user_chrono` where ((`studiranje`.`st_user_chrono`.`st_operation` = 'INSERT') and (`studiranje`.`st_user_chrono`.`st_new_username` is not null)) group by `studiranje`.`st_user_chrono`.`st_new_username`) `max_group_time` on((`studiranje`.`st_user_chrono`.`st_operation` = `max_group_time`.`st_operation`))) where ((`studiranje`.`st_user_chrono`.`st_timestamp` = `max_group_time`.`max_time`) and (`studiranje`.`st_user_chrono`.`st_identification` = `max_group_time`.`max_id`))) union (select `studiranje`.`st_user_chrono`.`st_identification` AS `st_identification`,`studiranje`.`st_user_chrono`.`st_timestamp` AS `st_timestamp`,`studiranje`.`st_user_chrono`.`st_old_username` AS `st_old_username`,`studiranje`.`st_user_chrono`.`st_new_username` AS `st_new_username`,`studiranje`.`st_user_chrono`.`st_operation` AS `st_operation` from (`studiranje`.`st_user_chrono` join (select `studiranje`.`st_user_chrono`.`st_operation` AS `st_operation`,max(`studiranje`.`st_user_chrono`.`st_timestamp`) AS `max_time`,max(`studiranje`.`st_user_chrono`.`st_identification`) AS `max_id` from `studiranje`.`st_user_chrono` where ((`studiranje`.`st_user_chrono`.`st_operation` = 'UPDATE') and (`studiranje`.`st_user_chrono`.`st_new_username` <> `studiranje`.`st_user_chrono`.`st_old_username`)) group by `studiranje`.`st_user_chrono`.`st_new_username`) `max_group_time` on((`studiranje`.`st_user_chrono`.`st_operation` = `max_group_time`.`st_operation`))) where ((`studiranje`.`st_user_chrono`.`st_timestamp` = `max_group_time`.`max_time`) and (`studiranje`.`st_user_chrono`.`st_identification` = `max_group_time`.`max_id`))) union (select `studiranje`.`st_user_chrono`.`st_identification` AS `st_identification`,`studiranje`.`st_user_chrono`.`st_timestamp` AS `st_timestamp`,`studiranje`.`st_user_chrono`.`st_old_username` AS `st_old_username`,`studiranje`.`st_user_chrono`.`st_new_username` AS `st_new_username`,`studiranje`.`st_user_chrono`.`st_operation` AS `st_operation` from (`studiranje`.`st_user_chrono` join (select `studiranje`.`st_user_chrono`.`st_operation` AS `st_operation`,max(`studiranje`.`st_user_chrono`.`st_timestamp`) AS `max_time`,max(`studiranje`.`st_user_chrono`.`st_identification`) AS `max_id` from `studiranje`.`st_user_chrono` where ((`studiranje`.`st_user_chrono`.`st_operation` = 'UPDATE') and (`studiranje`.`st_user_chrono`.`st_new_username` <> `studiranje`.`st_user_chrono`.`st_old_username`)) group by `studiranje`.`st_user_chrono`.`st_old_username`) `max_group_time` on((`studiranje`.`st_user_chrono`.`st_operation` = `max_group_time`.`st_operation`))) where ((`studiranje`.`st_user_chrono`.`st_timestamp` = `max_group_time`.`max_time`) and (`studiranje`.`st_user_chrono`.`st_identification` = `max_group_time`.`max_id`))) union (select `studiranje`.`st_user_chrono`.`st_identification` AS `st_identification`,`studiranje`.`st_user_chrono`.`st_timestamp` AS `st_timestamp`,`studiranje`.`st_user_chrono`.`st_old_username` AS `st_old_username`,`studiranje`.`st_user_chrono`.`st_new_username` AS `st_new_username`,`studiranje`.`st_user_chrono`.`st_operation` AS `st_operation` from (`studiranje`.`st_user_chrono` join (select `studiranje`.`st_user_chrono`.`st_operation` AS `st_operation`,max(`studiranje`.`st_user_chrono`.`st_timestamp`) AS `max_time`,max(`studiranje`.`st_user_chrono`.`st_identification`) AS `max_id` from `studiranje`.`st_user_chrono` where ((`studiranje`.`st_user_chrono`.`st_operation` = 'UPDATE') and (`studiranje`.`st_user_chrono`.`st_new_username` = `studiranje`.`st_user_chrono`.`st_old_username`)) group by `studiranje`.`st_user_chrono`.`st_old_username`) `max_group_time` on((`studiranje`.`st_user_chrono`.`st_operation` = `max_group_time`.`st_operation`))) where ((`studiranje`.`st_user_chrono`.`st_timestamp` = `max_group_time`.`max_time`) and (`studiranje`.`st_user_chrono`.`st_identification` = `max_group_time`.`max_id`)));

-- 2020-02-05 15:47:01
