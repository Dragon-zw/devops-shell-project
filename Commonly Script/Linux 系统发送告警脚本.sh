#!/bin/bash
#SHELL ENV
MAIL="baojingtongzhi@163.com"
MSTP="smtp.163.com"
MSTP_PASSWORD="123456"

sudo yum install -y mailx

cat > /etc/mail.rc <<-'EOF'
set from=${MAIL} smtp=${MSTP}
set smtp-auth-user=${MAIL} smtp-auth-password=${MSTP_PASSWORD}
set smtp-auth=login
EOF