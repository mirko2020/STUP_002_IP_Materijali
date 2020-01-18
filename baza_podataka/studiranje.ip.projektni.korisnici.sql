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