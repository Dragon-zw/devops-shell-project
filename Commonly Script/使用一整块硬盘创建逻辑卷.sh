#!/bin/bash
# Function:使用一整块硬盘创建LVM逻辑卷
read -p "请输入你要做成逻辑卷的硬盘(写绝对路径，如：/dev/sda)：" path
if [ -e $path ];then
    echo "true"
else
    echo "该设备不存在！！"
    exit
fi
pvcreate $path
echo "该硬盘已做成物理卷！"
vgcreate myvg $path
echo "该物理卷已加入卷组 myvg 中"
vgs
free=`vgs| awk '$1~/myvg/{print}'|awk '{print $6}'`
echo "该物理卷剩余的空间大小为：$free "
read -p "请输入你要创建逻辑卷的大小(如：1G)：" repy2
lvcreate -L $repy2 -n mylv myvg
echo "已成功创建逻辑卷mylv"
echo "------------------------"
lvs
echo "------------------------"
echo "你想对新分区设定什么类型的文件系统？有以下选项："
echo "A：ext4文件系统"
echo "B：xfs文件系统"
read -p "请输入你的选择：" repy3
case $repy3 in
    a|A)
        mkfs.ext4 /dev/myvg/mylv
        echo "该分区将被挂载在 "/mnt/mylv" 下"
        m=`ls /mnt/|grep mylv | wc -l`
        if [ $m -eq 0 ];then
            mkdir /mnt/mylv
        fi
        echo "/dev/myvg/mylv     /mnt/mylv     ext4         defaults          0      0" >> /etc/fstab
        mount -a
        df -Th
    ;;
    b|B)
        mkfs.xfs -f /dev/myvg/mylv
        echo "该分区将被挂载在 "/mnt/mylv" 下"
        m=`ls /mnt/|grep mylv | wc -l`
        if [ $m -eq 0 ];then
            mkdir /mnt/mylv
        fi
        echo "/dev/myvg/mylv     /mnt/mylv      xfs       defaults          0      0" >> /etc/fstab
        mount -a
        df -Th
    ;;
    *)
        echo "你的输入有误！！"
esac