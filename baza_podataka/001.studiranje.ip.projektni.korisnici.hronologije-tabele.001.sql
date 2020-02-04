drop database if exists studiranje;
create database studiranje character set utf8 collate utf8_general_ci;

use studiranje; 

create table st_user(
	st_identification integer primary key auto_increment, 
	st_username varchar(100) unique not null,
	st_firstname varchar(100), 
    st_secondname varchar(100),
    st_email_address varchar(100),
    st_password_hash varchar(100)
); 

create table st_user_chrono(
	st_identification integer primary key auto_increment, 
    st_timestamp timestamp default current_timestamp() not null, 
    st_old_username varchar(100), 
    st_new_username varchar(100), 
    st_operation set('INSERT', 'UPDATE', 'DELETE') not null, 
    constraint check(not st_operation='UPDATE'and st_old_username is null),  
    constraint check(not st_operation='UPDATE'and st_new_username is null),
    constraint check(not st_operation='DELETE'and st_old_username is null), 
    constraint check(not st_operation='INSERT'and st_new_username is null)
); 

DELIMITER $$
CREATE TRIGGER st_user_AI AFTER INSERT ON st_user
FOR EACH ROW 
BEGIN 
	INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('INSERT', null, new.st_username);  
END$$
DELIMITER ; 


DELIMITER %%
CREATE TRIGGER st_user_AU AFTER UPDATE ON st_user
FOR EACH ROW 
BEGIN 
	INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('UPDATE', old.st_username, new.st_username);  
END%%
DELIMITER ; 

DELIMITER $$
CREATE TRIGGER st_user_AD AFTER DELETE ON st_user
FOR EACH ROW 
BEGIN 
	INSERT INTO st_user_chrono(st_operation, st_old_username, st_new_username)
    VALUES ('DELETE', old.st_username, null);  
END$$
DELIMITER ; 

