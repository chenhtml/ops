#!/bin/bash
src="/root/jar/"
run_path="/root/"
bk_path="/root/jar_bk/"
log="watch.log"
JARNAME="demo-0.0.1-SNAPSHOT.jar"
inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' -e close_write $src | while read DATE TIME DIR FILE; do
 
FILECHANGE=${DIR}${FILE}
 
if [ $FILE == $JARNAME ]
then
        echo “At ${TIME} on ${DATE}, file $FILECHANGE was change” >> $log
        /root/ops/shell/springboot.sh $FILE stop >> $log && mv ${run_path}${JARNAME} ${bk_path}${JARNAME}'.'$(date +'%Y%m%d') >> $log  && cp  ${src}${JARNAME} ${run_path} >> $log && /root/ops/shell/springboot.sh $FILE start >> $log
fi
done
