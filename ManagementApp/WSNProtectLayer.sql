CREATE DATABASE IF NOT EXISTS `WSNProtectLayer`;
USE `WSNProtectLayer`;
CREATE TABLE IF NOT EXISTS `node` (
	`id`		TINYINT(3) 	NOT NULL COMMENT 'Node id',
	`device`	VARCHAR(100)	NOT NULL COMMENT '/dev io file',
	
	CONSTRAINT PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `application` (
	`id`		INT(5)		NOT NULL AUTO_INCREMENT COMMENT 'Application ID',
	`enabled`	TINYINT(1)	NOT NULL DEFAULT FALSE COMMENT 'Is application enabled',
	`name`		VARCHAR(150)	NOT NULL COMMENT 'Application name',
	`description`	TINYTEXT	CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL COMMENT 'Short application description',

	CONSTRAINT PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT = 100;

CREATE TABLE IF NOT EXISTS `node_to_application` (
	`id`			INT(10)		NOT NULL AUTO_INCREMENT COMMENT 'JOIN id (usable in scripts, but not necessary for scheme)',
	`application_id`	INT(5)		NOT NULL COMMENT 'Application ID reference',
	`node_id`		TINYINT(3)	NOT NULL COMMENT 'Node ID refrenece',

	CONSTRAINT PRIMARY KEY (`id`),
	CONSTRAINT FOREIGN KEY (`application_id`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT = 1;

CREATE TABLE IF NOT EXISTS `logs` (
	`id`			INT(10)		NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
	`time`			TIMESTAMP	NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Message timestamp',
	`application_id`	INT(5)		NOT NULL COMMENT 'Application ID reference',
	`msg`			TINYTEXT	CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'Message string',

	CONSTRAINT PRIMARY KEY (`id`),
	CONSTRAINT FOREIGN KEY (`application_id`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `config` (
	`id`			INT(10)		NOT NULL AUTO_INCREMENT COMMENT 'Config item ID',
	`application_id`	INT(5)		NOT NULL COMMENT 'Application ID reference',
	`node_id`		TINYINT(3)	NOT NULL COMMENT 'Node ID refrenece',
	`neighbor_id`		VARCHAR(20)	NOT NULL COMMENT 'Node id (parted as byte array) specifing neighbor of node_id',
	`item_name`		VARCHAR(100)	NOT NULL COMMENT 'Value name',
	`value`			VARCHAR(50)	NOT NULL COMMENT 'Binary representation of value',

	CONSTRAINT PRIMARY KEY (`id`),
	CONSTRAINT FOREIGN KEY (`application_id`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT UNIQUE KEY (`application_id`, `node_id`, `item_name`, `neighbor_id`)
) ENGINE=InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `WSNProtectLayer` VALUES(NULL, TRUE, 'Initial Application', '');
