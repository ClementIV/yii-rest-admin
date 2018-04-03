/*
Navicat MySQL Data Transfer

Source Server         : localhost_3306
Source Server Version : 50505
Source Host           : localhost:3306
Source Database       : newcc

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2018-04-03 08:42:13
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `cc_auth_assignment`
-- ----------------------------
DROP TABLE IF EXISTS `cc_auth_assignment`;
CREATE TABLE `cc_auth_assignment` (
`item_name`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`user_id`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`created_at`  int(11) NULL DEFAULT NULL ,
PRIMARY KEY (`item_name`, `user_id`),
FOREIGN KEY (`item_name`) REFERENCES `cc_auth_item` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_unicode_ci

;

-- ----------------------------
-- Table structure for `cc_auth_item`
-- ----------------------------
DROP TABLE IF EXISTS `cc_auth_item`;
CREATE TABLE `cc_auth_item` (
`name`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`type`  smallint(6) NOT NULL ,
`description`  text CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL ,
`rule_name`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL ,
`data`  blob NULL ,
`created_at`  int(11) NULL DEFAULT NULL ,
`updated_at`  int(11) NULL DEFAULT NULL ,
`methods`  varchar(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL ,
PRIMARY KEY (`name`),
FOREIGN KEY (`rule_name`) REFERENCES `cc_auth_rule` (`name`) ON DELETE SET NULL ON UPDATE CASCADE,
INDEX `rule_name` (`rule_name`) USING BTREE ,
INDEX `idx-auth_item-type` (`type`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_unicode_ci

;

-- ----------------------------
-- Table structure for `cc_auth_item_child`
-- ----------------------------
DROP TABLE IF EXISTS `cc_auth_item_child`;
CREATE TABLE `cc_auth_item_child` (
`parent`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`child`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
PRIMARY KEY (`parent`, `child`),
FOREIGN KEY (`parent`) REFERENCES `cc_auth_item` (`name`) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (`child`) REFERENCES `cc_auth_item` (`name`) ON DELETE CASCADE ON UPDATE CASCADE,
INDEX `child` (`child`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_unicode_ci

;

-- ----------------------------
-- Table structure for `cc_auth_rule`
-- ----------------------------
DROP TABLE IF EXISTS `cc_auth_rule`;
CREATE TABLE `cc_auth_rule` (
`name`  varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`data`  blob NULL ,
`created_at`  int(11) NULL DEFAULT NULL ,
`updated_at`  int(11) NULL DEFAULT NULL ,
PRIMARY KEY (`name`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_unicode_ci

;

-- ----------------------------
-- Table structure for `cc_menu`
-- ----------------------------
DROP TABLE IF EXISTS `cc_menu`;
CREATE TABLE `cc_menu` (
`id`  int(11) NOT NULL AUTO_INCREMENT ,
`name`  varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ,
`parent`  int(11) NULL DEFAULT NULL ,
`route`  varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ,
`order`  int(11) NULL DEFAULT NULL ,
`data`  blob NULL ,
PRIMARY KEY (`id`),
FOREIGN KEY (`parent`) REFERENCES `cc_menu` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
INDEX `cc_menu_ibfk_1` (`parent`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
AUTO_INCREMENT=4

;

-- ----------------------------
-- Table structure for `cc_user`
-- ----------------------------
DROP TABLE IF EXISTS `cc_user`;
CREATE TABLE `cc_user` (
`id`  int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID' ,
`username`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名' ,
`auth_key`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '自动登录key' ,
`password_hash`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '加密密码' ,
`password_reset_token`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '重置密码token' ,
`access_token`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户验证token' ,
`email_validate_token`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '邮箱验证token' ,
`email`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '邮箱' ,
`role`  smallint(6) NOT NULL DEFAULT 10 COMMENT '角色等级' ,
`status`  smallint(6) NOT NULL DEFAULT 10 COMMENT '状态' ,
`avatar`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '头像' ,
`vip_lv`  int(11) NULL DEFAULT 0 COMMENT 'vip等级' ,
`created_at`  int(11) NOT NULL COMMENT '创建时间' ,
`updated_at`  int(11) NOT NULL ,
`allowance`  int(20) NOT NULL COMMENT '访问API的剩余次数' ,
`allowance_updated_at`  int(20) NOT NULL COMMENT '最近访问API的UNIX时间戳' ,
PRIMARY KEY (`id`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='会员表'
AUTO_INCREMENT=583

;

-- ----------------------------
-- Auto increment value for `cc_menu`
-- ----------------------------
ALTER TABLE `cc_menu` AUTO_INCREMENT=4;

-- ----------------------------
-- Auto increment value for `cc_user`
-- ----------------------------
ALTER TABLE `cc_user` AUTO_INCREMENT=583;
