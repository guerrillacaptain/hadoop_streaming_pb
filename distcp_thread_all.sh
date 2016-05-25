#!/bin/bash 
DIR=`(cd "$(dirname "$0")"; pwd)`
echo $DIR


if [[ $? != 0 ]];then exit -1 ;fi

#设置并发
temp_fifo_file="$$.info"  #以进程ID命名管道文件
mkfifo "$temp_fifo_file"  
exec 4<>"$temp_fifo_file"   #以读写方式打开tmp_fifo_file管道文件,文件描述符为4，也可以取3-9任意描述符
rm $temp_fifo_file

temp_thread=5

for ((i=0;i<temp_thread;i++)) #向管道中输入并发数量的空行
do
    echo 
done >&4   #输出重导向到定义的文件描述符4上

for i in  `cat $DIR/list`
do
     read -u4
    {
       source_destination=`echo $i`
       target_destination=`echo $i | sed 's$hdfs://172.*:8020$$'`
       echo -e "source_destination  is $source_destination"
       echo -e "target_destination  is $target_destination"
       size=`hadoop fs -du -s $source_destination | awk '{print $1}'`
       if [[ $size == 0 ]]
       then 
         echo "$source_destination size is zero" >> $DIR/zero.log
       elif [[ $size -lt 268435456 ]];then
          num_map=1
       else 
         num_map=`expr $size  / 1024 / 1024 / 256 + 1`
         if [[ $num_map -lt 6 ]]; then num_map=6;fi
         if [[ $num_map -gt 500 ]]; then num_map=500;fi
       fi
       echo -e "num of maps: "$num_map""
       echo -e "hadoop distcp -update -skipcrccheck  -m $num_map   $source_destination  $target_destination"
       hadoop distcp -update -skipcrccheck  -m $num_map  $source_destination  $target_destination

  sleep 2
  echo  "">&4

    }&
done
