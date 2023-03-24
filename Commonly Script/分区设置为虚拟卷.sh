#! /bin/bash
# Function:新建一个分区，并做成逻辑卷
cat /proc/partitions > old
read -p "请输入你要分区的硬盘(写绝对路径，如：/dev/sda)：" A
if [ -e $A ];then
    echo "true"
else
    echo "该设备不存在！！"
    exit
fi
read -p "请输入你要创建的磁盘分区类型(这里只能是主分区，默认按回车即可):" B
read -p "请输入分区数字，范围1-4，默认从1开始，默认按回车即可：" C
read -p "请输入扇区起始表号，默认按回车即可：" D
read -p "请输入你要分区的分区大小(格式：如 +5G )：" E
read -p "请输入你要划分为逻辑卷的分区盘符(默认回车即可)：" Z
fdisk $A << EOF
n
p
$C
$D
$E
t
$Z
8e
p
w
EOF
echo "一个标准LVM的分区已经建立好！！"
partprobe $A
echo "-------------------------------"
cat /proc/partitions
cat /proc/partitions > new
F=`diff new old | grep "<" | awk '{print $5}'`
echo "-------------------------------"
echo $F
pvcreate /dev/$F
echo "该硬盘已做成物理卷！"
n=`vgs | grep myvg |wc -l`
if [ $n -eq 0 ];then
    vgcreate myvg /dev/$F
    echo "该物理卷已加入卷组myvg中"
else
    vgextend myvg /dev/$F
    echo  "该物理卷已加入卷组myvg中"
    vgs
    free=`vgs| awk '$1~/myvg/{print}'|awk '{print $7}'`
    echo "该卷组剩余的空间大小为：$free "
    lvs
    exit
fi
vgs
free=`vgs| awk '$1~/myvg/{print}'|awk '{print $6}'`
echo "该卷组剩余的空间大小为：$free "
read -p "请输入你要创建逻辑卷的大小(如：1G)：" repy2
lvcreate -L $repy2 -n mylv myvg
echo "已成功创建逻辑卷mylv"
echo "------------------------"
lvs
echo "------------------------"
echo "你想对新分区设定什么类型的文件系统？有以下选项："
echo "A：ext4文件系统"
echo "B：xfs文件系统"
read -p "请输入你的选择：" G
case $G in
    a|A)
        mkfs.ext4 /dev/myvg/mylv
        echo "该分区将被挂载在 "/mnt/$F" 下"
        m=`ls /mnt/|grep $F | wc -l`
        if [ $m -eq 0 ];then
            mkdir /mnt/$F
        fi
        echo "/dev/myvg/mylv     /mnt/$F     ext4         defaults          0      0" >> /etc/fstab
        mount -a
        df -Th
    ;;
    b|B)
        mkfs.xfs -f /dev/myvg/mylv
        echo "该分区将被挂载在 "/mnt/$F" 下"
        m=`ls /mnt/|grep $F | wc -l`
        if [ $m -eq 0 ];then
            mkdir /mnt/$F
        fi
        echo "/dev/myvg/mylv     /mnt/$F      xfs       defaults          0      0" >> /etc/fstab
        mount -a
        df -Th
    ;;
    *)
        echo "你的输入有误！！"
esac