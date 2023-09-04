#!/bin/bash
# Description：用于安装 Ubuntu | Debian 操作系统的 VNC 软件
set +ux

# 操作系统类型
OS=$(cat /etc/os-release | grep "^NAME" | awk -F'"' '{print $2}' | awk -F" " '{print $1}')
# VNC_PORT="10" # 默认59为前缀，即05，则放通端口5901 5902 5903 5904 5905
USER=$(whoami)
DEBIAN_ROOT_PASSWORD="magedu"

# Ubuntu安装VNC函数
function ubuntu_install_vnv() {
    # 关闭防火墙
    echo "关闭防火墙并查看防火墙状态"
    ufw disable && ufw status
    echo 

    # 对APT进行更新
    sudo apt-get update 
    # 安装 Xfce 软件包(桌面环境)
    echo "-----> 安装 Xfce 软件包(桌面环境)"
    sudo apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
    # 判断执行是否成功
    # echo $? &> /dev

    # 安装 VNC 服务器
    echo "-----> 安装 VNC 服务器"
    sudo apt install -y tigervnc-standalone-server tigervnc-common
    # 判断执行是否成功
    # echo $? &> /dev

    # 运行vncserver命令，需要管理员设置VNC远程桌面密码
    echo -e "\a"
    echo "-----> 运行vncserver命令，需要管理员设置VNC远程桌面密码"
    vncserver

    # 执行完毕后，默认会启动5901端口进行测试
    echo -e "\E[1;5;32m-----> 进行休眠 5 分钟时间进行测试(端口:5901)\E[0m"
    echo -e "\E[1;5;31m-----> 若出现无法访问现象，可以新开终端，将vncserver重新启动\E[0m"
    sleep 250
    echo -e "\E[1;5;32m-----> 休眠即将结束，会删除测试端口(端口:5901)\E[0m"
    sleep 50
    vncserver -kill :1

    # 查看VNC启动列表
    vncserver -list

    # 修改VNC配置信息
    echo "-----> 修改VNC配置信息"
    sleep 5
    cp -av ~/.vnc/xstartup ~/.vnc/xstartup.bak
    cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
    # 添加权限
    chmod u+x ~/.vnc/xstartup

    # 更改VNC服务器启动参数
    echo "-----> 更改VNC服务器启动参数"
    cat <<EOF > ~/.vnc/config
geometry=1920x1084
dpi=96
EOF

    # 配置防火墙
    # echo "配置防火墙策略"
    # for port in {1..${VNC_PORT}}; do sudo ufw allow 59${port}; done

    # 启动VNC服务器
    
    vncserver :1 -localhost no

    # 可以执行运行命令开启 VNC 终端
    echo "-----> 可以执行运行命令开启 VNC 终端"
    echo -e "vncserver -depth 24 -geometry 1280x800 :1"
    echo
    vncserver -kill :1
}

# Debian需要拥有 root 临时权限sudo(测试)
# function debian_user_sudo() {
#     # 系统需要安装 expect 软件包
#     cat <<EOF > /tmp/expect-user-sudo
# #!/usr/bin/expect
# spawn su -
# expect {
#     "密码" { send "magedu"\n }
# }
# interact
# EOF
#     chmod +x /tmp/expect-user-sudo
#     . /tmp/expect-user-sudo
#     echo "${USER}     ALL=(ALL:ALL) ALL" >> /etc/sudoers
# }

# Debian安装VNC函数
function debian_install_vnv() {
    # 对APT进行更新
    sudo apt-get update 
    # 安装 Xfce 软件包(桌面环境)
    echo "-----> 安装 Xfce 软件包(桌面环境)"
    sudo apt install -y xfce4 xfce4-goodies

    # 安装完成后，安装TightVNC服务器以及对应的依赖包
    echo "-----> 安装TightVNC服务器以及对应的依赖包"
    sudo apt install -y tightvncserver dbus-x11
    # 判断执行是否成功
    # echo $? &> /dev

    # 使用vncserver 命令来设置安全密码并创建初始配置文件
    echo -e "\a"
    echo "-----> 运行vncserver命令，需要管理员设置VNC远程桌面密码"
    vncserver

    # 执行完毕后，默认会启动5901端口进行测试
    echo -e "\E[1;5;32m-----> 进行休眠 5 分钟时间进行测试(端口:5901)\E[0m"
    echo -e "\E[1;5;31m-----> 若出现无法访问现象，可以新开终端，将vncserver重新启动\E[0m"
    sleep 250
    echo -e "\E[1;5;32m-----> 休眠即将结束，会删除测试端口(端口:5901)\E[0m"
    sleep 50
    vncserver -kill :1

    # 修改VNC配置信息
    echo "-----> 修改VNC配置信息"
    sleep 5
    cp -av ~/.vnc/xstartup ~/.vnc/xstartup.bak
    cat <<-'EOF' > ~/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

    # 添加权限
    chmod u+x ~/.vnc/xstartup

    # 可以执行运行命令开启 VNC 终端
    echo "-----> 可以执行运行命令开启 VNC 终端"
    echo -e "vncserver -depth 24 -geometry 1280x800 :1"
    echo 
    # vncserver -depth 24 -geometry 1280x800 :1
}

# Ubuntu_Debian安装独立服务(可选择)
function ubuntu_debian_vnc_service() {
    USER=$(whoami)
    # 配置Ubuntu_Debian安装独立服务
    echo "-----> Ubuntu_Debian安装独立服务"

    cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=${USER}
Group=${USER}
WorkingDirectory=/home/${USER}

PIDFile=/home/${USER}/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

    # 更新新的服务文件
    sudo systemctl daemon-reload
    # 删除VNC实例
    vncserver -kill :1
    # 启动服务文件
    sudo systemctl enable vncserver@1.service
    # @ 后面的1 标志着服务应该出现在哪个显示号码上，在这种情况下，默认的:1
    # 启动服务
    sudo systemctl start vncserver@1
    # 查看是否成功
    sudo systemctl status vncserver@1
    # 查看日志情况：# journalctl -xeu vncserver@1.service

    # 添加防火墙策略
    # iptables -I INPUT -p tcp --dport 5901 -j ACCEPT
}

# 判断操作系统执行安装VNC软件
if [ ${OS} = "Ubuntu" ]; then
    echo -e "\E[1;32m开始进行Ubuntu操作系统安装VNC\E[0m"
    ubuntu_install_vnv
    # ubuntu_debian_vnc_service

elif [ ${OS} = "Debian" ]; then
    echo -e "\E[1;32m开始进行Debian操作系统安装VNC\E[0m"
    # debian_user_sudo
    debian_install_vnv
    ubuntu_debian_vnc_service
    
else
    echo -e "\E[1;31m不支持该操作系统的安装VNC\E[0m"
fi
