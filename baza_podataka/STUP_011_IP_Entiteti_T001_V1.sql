DROP TABLE IF EXISTS  `studiranje`.`st_entity`; 
CREATE TABLE IF NOT EXISTS `studiranje`.`st_entity` (
  `st_identification` INT NOT NULL AUTO_INCREMENT,
  `st_entity_uri` VARCHAR(200) NOT NULL,
  `st_last_recording_time` TIMESTAMP NOT NULL,
  `st_table_identification` INTEGER, 
  `st_table_name` VARCHAR(100), 
  `st_resource_url` VARCHAR(100), 
  `st_database_url` VARCHAR(100), 
  `st_communication_protocol` VARCHAR(100), 
  `st_subjectivity` SET('GENERAL', 'SUBJECT', 'OBJECT', 'PREDICT', 'OPTIONAL', 'ACTION', 'EXECUTOR') DEFAULT 'GENERAL' NOT NULL, 
  PRIMARY KEY (`st_identification`),
  UNIQUE INDEX `st_entity_uri_UNIQUE` (`st_entity_uri` ASC), 
  UNIQUE INDEX `st_table_UNIQUE` (`st_table_identification` ASC, `st_table_name` ASC)
);