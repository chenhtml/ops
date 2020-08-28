#!/bin/bash
src="/usr/local/nginx/conf/"
log="watch.log"
fileType="conf"
inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' -e close_write $src | while read DATE TIME DIR FILE; do
 
FILECHANGE=${DIR}${FILE}
 
if [[ $FILECHANGE =~ $fileType ]]
then
        echo “At ${TIME} on ${DATE}, file $FILECHANGE was change” >> $log
        #/home/ftpuser/script/springboot.sh restart >> $log
fi
done
