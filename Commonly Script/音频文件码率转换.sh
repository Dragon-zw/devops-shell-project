#!/bin/bash
# Description: 音频文件码率转换成 16 K

# 当前 bnpp 目录路径
# BNPP_DIR="/opt/bnpp-data"
BNPP_DIR="/mnt/test"
# 获取当前 bnpp 目录下的所有子目录
BNPP_SUB_DIR=$(find ${BNPP_DIR} -maxdepth 1 ! -path ${BNPP_DIR} -type d -print)
# 获取当前 bnpp 子目录下的所有 *.wav 文件
FILES=$(find ${BNPP_SUB_DIR[@]} -type f -name "*.wav")
# bnpp 转换完成的目录路径
# OUTPUT_PATH="/opt/bnpp-new-data"
OUTPUT_PATH="/mnt/new-test"

mkdir -p ${OUTPUT_PATH}
# 遍历所有文件，判断是否是音频文件
for sub_dir in ${BNPP_SUB_DIR[@]}
do
    cd ${sub_dir}
    # 获取子目录的 basename
    BNPP_SUB_BASENAME=$(basename ${sub_dir})

    # 判断子目录下是否还有目录(二级目录)
    if [ $(ls -l "${sub_dir}" | grep ^d &> /dev/null; echo $?) -eq 0 ]; then
        DIR=$(find . -type d ! -path . -print | awk -F '/' '{print $2}')
        # 当子目录有其他的目录
        for dir in ${DIR[@]}
        do
            # 创建转换子目录下的目录
            mkdir -p ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}/${dir}

            cd ${sub_dir}/${dir}
            for file in $(ls *.wav)
            do
                # 使用 ffmpeg 将 wav 文件转换为 wav(16000) 格式，并保留原始文件
                ffmpeg -hide_banner -loglevel panic -y -i ${file} -acodec pcm_s16le -f wav -ar 16000 ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}/${dir}/${file}

                # 打印成功转换的消息
            echo -e "\E[1;33m---> 已成功将 ${file} 转换为 ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}/${dir}/${file%}\E[0m"
            done
        done

    else
        # 当子目录是只有音频文件执行
        for file in $(ls *.wav)
        do
            # 创建转换的目录
            mkdir -p ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}
            # 使用 ffmpeg 将 wav 文件转换为 wav(16000) 格式，并保留原始文件
            ffmpeg -hide_banner -loglevel panic -y -i ${file} -acodec pcm_s16le -f wav -ar 16000 ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}/${file}

            # 打印成功转换的消息
            echo -e "\E[1;33m---> 已成功将 ${file} 转换为 ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}/${file%}\E[0m"
        done
    fi
    echo -e "\E[1;33m======================================================================\E[0m"
    # 验证是否转换成功
    echo -e "\E[1;32m使用命令: ffprobe -show_format <RADIO_NAME>.wav\E[0m"
    echo -e "\E[1;32m---> 已成功将 ${sub_dir} 保存到 ${OUTPUT_PATH}/${BNPP_SUB_BASENAME}\E[0m"
    echo
done