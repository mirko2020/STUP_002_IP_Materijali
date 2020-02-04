CREATE TABLE IF NOT EXISTS `studiranje`.`st_entity` (
  `st_identification` INT NOT NULL AUTO_INCREMENT,
  `st_entity_uri` VARCHAR(200) NOT NULL,
  `st_last_recording_time` TIMESTAMP NOT NULL,
  PRIMARY KEY (`st_identification`),
  UNIQUE INDEX `st_entity_uri_UNIQUE` (`st_entity_uri` ASC)
);