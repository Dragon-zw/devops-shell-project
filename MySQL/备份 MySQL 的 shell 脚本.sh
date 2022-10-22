#!/bin/bash

# 备份 MySQL 的 shell 脚本(mysqldump版本) 
 
# 定义变量 user(数据库用户名),passwd(数据库密码),date(备份的时间标签)
# dbname(需要备份的数据库名称,根据实际需求需要修改该变量的值,默认备份 mysql 数据库)
 
user=root
passwd=123456
dbname=mysql
date=$(date +%Y%m%d)
 
# 测试备份目录是否存在,不存在则自动创建该目录
[ ! -d /mysqlbackup ] && mkdir /mysqlbackup
# 使用 mysqldump 命令备份数据库
mysqldump -u "$user" -p "$passwd" "$dbname" > /mysqlbackup/"$dbname"-${date}.sql