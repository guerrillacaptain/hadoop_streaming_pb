hadoop jar hadoop-streaming-2.2.0.jar \
    -D stream.map.input=typedbytes \
    -D mapred.job.name=${job_name} \
    -files ./map.py,./ArchiveLog_pb2.py,./typedbytes.py \
    -numReduceTasks 0 \
    -input ${log_input} \
    -mapper "python27/python2.7/bin/python2.7 map.py " \
    -output ${feature_output} \
    -inputformat org.apache.hadoop.mapred.SequenceFileAsBinaryInputFormat \
    -cacheArchive yaojiandong/util/python2.7.tar.gz#python27
