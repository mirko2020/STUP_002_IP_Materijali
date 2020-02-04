-- Adminer 4.7.1 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

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
) ENGINE=MyISAM AUTO_INCREMENT=101 DEFAULT CHARSET=utf8;

INSERT INTO `st_user` (`st_identification`, `st_username`, `st_firstname`, `st_secondname`, `st_email_address`, `st_password_hash`) VALUES
(36,	'jefrem',	'Jefrem',	'Jefremovic',	'jefrem@yandex.com',	'22759$X1JQXPZNvwtCgzVvs1bDW5MsUyzgwaTMfIAi9gAkOCc='),
(38,	'ivo',	'Ivan',	'Ivanovic',	'ivo@mail.com',	'24807$E151gHAklTK0IfVEEjWYgCPuG6jImM4HqMLkkA3dFI4='),
(34,	'marko',	'Marko',	'Markovic',	'marko.markovic@gmail.com',	'42794$lhL+LWRC7tL2C9A7letm7DzqOVS2FZnmUxJhIigAeKE='),
(35,	'janko',	'Janko',	'Jankovic',	'janko.jankovic@gmail.com',	'02522$jkG6cs6mm7ba3H1ayHkNMp2up5QBKE36emoJTGGux80='),
(39,	'јован',	'Јован',	'Јовановић',	'jovo@email.com',	'98426$hkQqbXPCAo3JbgduVbz0I/i3nP+jwdMVELptCZemF/k='),
(41,	'petar',	'Petar',	'Petrovic',	'petar.petrovic@gmail.com',	'67694$37YSBEd9R2aB/Xn1kc3CkAhiPDo+t22X+v4ZkjfzVhw='),
(42,	'mihailo',	'Mihailo',	'Mihailovic',	'mihailo.mihailovic@gmail.com',	'99902$2Hene4vh9T5VHzShXDuMQAoJvSckJwG7jXGUqycYRbk='),
(45,	'jelena',	'\'Helena',	'Jokic',	'jelena.helena@posta.ru',	'95225$gjrWgYBFlHdLB3LguFK/1zL/PVaIjF9+0abT329Hav0='),
(46,	'mitar',	'Mitar',	'Mitrovic',	'mitar@gmail.com',	'80006$GUkMe5CzQ4oJq5ckQxdhH7+xvFsvL3v3UnUP9EZizxg='),
(47,	'jovana',	'Jovana',	'Jovanovic',	'jovana@gmail.com',	'65431$4Usq3iYE2UM5i/leztSCsI/I4b55jTpusSoc9eHnBMk='),
(48,	'jotan',	'Jotan',	'Jotanovic',	'jotan@yatospace.com',	'12209$thm84QEGwum+S92wZFwyCNlcRZiItRNQL1BFngHZKvg='),
(49,	'helena',	'Helena',	'Jokic',	'jelena.helena@posta.ru',	'49777$7Gf7pY1KtLYH+5mC5XHWdlBTDls/lKCJob+3MlfjWa4='),
(58,	'марио',	'Марио',	'Маринковић',	'mario@express.com',	'92952$AiXiCo/smBMuIStAG3V02d0oyQhwINxLQgkuQ/+FrJY='),
(59,	'дарио',	'Дарио',	'Маринковић',	'dario@express.com',	'15702$m+luetsD+wgofHbnC5EgXIwxXr05BxrCPC+Dpf/qqzQ=');

-- 2020-01-24 07:40:29
