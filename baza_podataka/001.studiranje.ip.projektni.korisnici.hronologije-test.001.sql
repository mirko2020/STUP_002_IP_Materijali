use studiranje; 

insert into st_user(st_username, st_firstname, st_secondname, st_email_address) values('marko', 'Marko', 'Markovic', 'marko@mtel.com'); 
update st_user set st_password_hash = 'PASSWORD' WHERE st_username = 'marko';
update st_user set st_username = 'janko' WHERE st_username = 'marko'; 
delete from st_user where st_username='marko'; 
delete from st_user where st_username='janko'; 