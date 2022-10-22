#!/bin/bash

# 检测 MySQL 数据库连接数量 
 
# 本脚本每 2 秒检测一次 MySQL 并发连接数,可以将本脚本设置为开机启动脚本,或在特定时间段执行
# 以满足对 MySQL 数据库的监控需求,查看 MySQL 连接是否正常
# 本案例中的用户名和密码需要根据实际情况修改后方可使用
log_file=/var/log/mysql_count.log
user=root
passwd=123456
while :
do
    sleep 2
    count=`mysqladmin  -u  "$user"  -p  "$passwd"   status |  awk '{print $4}'`
    echo "`date +%Y‐%m‐%d` 并发连接数为:$count" >> $log_file
done