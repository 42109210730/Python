/*
SQLyog Ultimate v11.33 (64 bit)
MySQL - 8.0.31 : Database - my_db_01
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`my_db_01` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `my_db_01`;

/*Table structure for table `ev_guest` */

DROP TABLE IF EXISTS `ev_guest`;

CREATE TABLE `ev_guest` (
  `guestId` int NOT NULL AUTO_INCREMENT,
  `guestName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `identityId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `deposit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `guestNum` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `leaveDate` datetime DEFAULT NULL,
  `resideDate` datetime DEFAULT NULL,
  `resideStateId` int DEFAULT NULL,
  `roomId` int DEFAULT NULL,
  `totalMoney` int DEFAULT NULL,
  PRIMARY KEY (`guestId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_guest` */

insert  into `ev_guest`(`guestId`,`guestName`,`identityId`,`phone`,`deposit`,`guestNum`,`leaveDate`,`resideDate`,`resideStateId`,`roomId`,`totalMoney`) values (21,'熊大','778899','1111111','66666','2','2024-12-26 16:09:33','2023-12-06 00:00:00',2,18,-513834),(22,'吉吉国王','22222','222222','99999','1','2023-12-09 02:15:29','2023-12-08 00:00:00',2,17,98499),(23,'光头强','33333','66666','66666','1',NULL,'2023-12-09 02:10:47',1,16,NULL),(24,'熊二','889977','6666','50000','1',NULL,'2023-12-01 00:00:00',1,13,NULL),(25,'李老板','9988','222111','1111111','1','2024-12-26 16:11:51','2023-12-14 00:00:00',2,3,1048197),(26,'毛毛','9999888','123546','112233','1',NULL,'2023-12-09 02:13:26',1,11,NULL);

/*Table structure for table `ev_residestate` */

DROP TABLE IF EXISTS `ev_residestate`;

CREATE TABLE `ev_residestate` (
  `resideStateId` int NOT NULL AUTO_INCREMENT COMMENT '结账状态 1、未结账 2、已结账  ',
  `resideStateName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '状态名称',
  PRIMARY KEY (`resideStateId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_residestate` */

insert  into `ev_residestate`(`resideStateId`,`resideStateName`) values (1,'未结账'),(2,'已结账');

/*Table structure for table `ev_role` */

DROP TABLE IF EXISTS `ev_role`;

CREATE TABLE `ev_role` (
  `roleId` int NOT NULL AUTO_INCREMENT,
  `roleName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`roleId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_role` */

insert  into `ev_role`(`roleId`,`roleName`) values (1,'超级管理员1'),(2,'前台');

/*Table structure for table `ev_room` */

DROP TABLE IF EXISTS `ev_room`;

CREATE TABLE `ev_room` (
  `roomId` int NOT NULL AUTO_INCREMENT COMMENT '房间ID',
  `roomStateId` int DEFAULT NULL COMMENT '房间状态',
  `roomTypeId` int DEFAULT NULL COMMENT '房间类型',
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '简介',
  `guestId` int DEFAULT NULL COMMENT '顾客id',
  PRIMARY KEY (`roomId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_room` */

insert  into `ev_room`(`roomId`,`roomStateId`,`roomTypeId`,`description`,`guestId`) values (1,1,1,'标准2床',NULL),(2,1,1,'标准',NULL),(3,1,2,'单',NULL),(4,1,2,'单人房',NULL),(5,1,3,'大床',NULL),(6,1,3,'大床房间',NULL),(7,1,4,'三人',NULL),(8,1,4,'3人房间',NULL),(9,1,5,'套房',NULL),(10,1,5,'标准套房',NULL),(11,2,6,'豪华套房',26),(12,1,6,'很豪华',NULL),(13,2,7,'77',24),(14,1,7,'88',NULL),(15,1,8,NULL,NULL),(16,2,8,NULL,23),(17,1,9,NULL,NULL),(18,1,9,'99999999',NULL);

/*Table structure for table `ev_roomstate` */

DROP TABLE IF EXISTS `ev_roomstate`;

CREATE TABLE `ev_roomstate` (
  `roomStateId` int NOT NULL AUTO_INCREMENT COMMENT '房间状态ID：1、空闲 2、入住 3、维修',
  `roomStateName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '房间状态名称',
  PRIMARY KEY (`roomStateId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_roomstate` */

insert  into `ev_roomstate`(`roomStateId`,`roomStateName`) values (1,'空闲'),(2,'入住'),(3,'维修');

/*Table structure for table `ev_roomtype` */

DROP TABLE IF EXISTS `ev_roomtype`;

CREATE TABLE `ev_roomtype` (
  `roomTypeId` int NOT NULL AUTO_INCREMENT COMMENT '房型编号',
  `roomTypeName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '房型名称',
  `roomTypePrice` int DEFAULT NULL COMMENT '房型价格',
  `bedNum` int DEFAULT NULL COMMENT '床位数',
  `typeDescription` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '房型简介',
  `typeTotalMoney` int DEFAULT NULL COMMENT '房型销售总额',
  PRIMARY KEY (`roomTypeId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_roomtype` */

insert  into `ev_roomtype`(`roomTypeId`,`roomTypeName`,`roomTypePrice`,`bedNum`,`typeDescription`,`typeTotalMoney`) values (1,'标准间',120,2,'标准2床房间',500),(2,'单人间',166,1,'单人房',63214),(3,'大床房',188,1,'豪华大床房',400),(4,'三人间',300,3,'多人房间',500),(5,'标准套房',500,2,'标准房间',1000),(6,'豪华套房',600,2,'可以k歌',1000),(7,'商务套房',800,3,'真不错',250),(8,'总统套房',1200,4,'你值得拥有',600),(9,'定制套房',1500,1,'太酷了',590888);

/*Table structure for table `ev_users` */

DROP TABLE IF EXISTS `ev_users`;

CREATE TABLE `ev_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `userPic` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `roleId` int NOT NULL COMMENT '1是系统管理员、2是普通管理员',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `id` (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

/*Data for the table `ev_users` */

insert  into `ev_users`(`id`,`username`,`password`,`name`,`phone`,`userPic`,`roleId`) values (1,'admin1','123456','管理员','66666','http://127.0.0.1:3000/static/image1701632006885.jpg',1),(3,'admin2','123456','初一','1234567','http://127.0.0.1:3000/static/image1701631984905.jpg',1),(6,'fifi66','123456','fifi','125800000','http://127.0.0.1:3000/static/image1701631952645.jpg',4),(7,'admin3','123456','十五','123456789','http://127.0.0.1:3000/static/image1701630713646.jpg',3),(8,'mimi66','123456','咪咪','6666','http://127.0.0.1:3000/static/image1701636907827.jpg',5),(9,'ceshi6','aaaaaa','测试','66666666','http://127.0.0.1:3000/static/image1701637057415.jpg',2);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
