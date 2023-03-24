#! /bin/bash
# Function:对硬盘进行分区,得到一个标准的linux文件系统(ext4/xfs)的主分区
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
fdisk $A << EOF
n
p
$C
$D
$E
w
EOF
echo "一个标准的linux文件系统的分区已经建立好！！"
partprobe $A
echo "-------------------------------"
cat /proc/partitions
cat /proc/partitions > new
F=`diff new old | grep "<" | awk '{print $5}'`
echo "-------------------------------"
echo $F
echo "你想对新分区设定什么类型的文件系统？有以下选项："
echo "A：ext4文件系统"
echo "B：xfs文件系统"
read -p "请输入你的选择：" G
case $G in
    a|A)
        mkfs.ext4 /dev/$F
        echo "该分区将被挂载在 "/mnt/$F" 下"
        m=`ls /mnt/|grep $F | wc -l`
        if [ $m -eq 0 ];then
            mkdir /mnt/$F
        fi
        n=`cat /etc/fstab | grep /dev/$F| wc -l`
        if [ $n -eq 0 ];then
            echo "/dev/$F     /mnt/$F     ext4         defaults          0      0" >> /etc/fstab
        else
            sed -i '/^\/dev\/$F/c\/dev/$F     /mnt/$F     ext4         defaults          0      0' /etc/fstab
        fi
        mount -a
        df -Th
    ;;
    b|B)
        mkfs.xfs -f /dev/$F
        echo "该分区将被挂载在 "/mnt/$F" 下"
        m=`ls /mnt/|grep $F | wc -l`
        if [ $m -eq 0 ];then
            mkdir /mnt/$F
        fi
        n=`cat /etc/fstab | grep /dev/$F | wc -l`
        if [ $n -eq 0 ];then
            echo "/dev/$F     /mnt/$F      xfs       defaults          0      0" >> /etc/fstab
        else
            sed -i '/^\/dev\/$F/c\/dev/$F     /mnt/$F     xfs         defaults          0      0' /etc/fstab
        fi
        mount -a
        df -Th
    ;;
    *)
        echo "你的输入有误！！"
esac