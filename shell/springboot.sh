#!/bin/bash
JAR_PATH=/root/
LOG=/root/jar_update.log
JAR=""
PID=$( jps -| grep $1 | grep -v grep | awk '{ print $1 }')

case "$2" in
  start)
      if [ ! -z "$PID" ]
      then
           echo "$1 already started ,PID:$PID"
      else 
           cd $JAR_PATH
           nohup java -jar $1 >/dev/null 2>&1 &
           if [ "$?"  -eq 0 ]
           then
               echo "start success"
           fi
       fi
       ;; 
  stop)
      echo $PID
      if [ -z "$PID" ]
      then
         echo "$1 not running" 
      else
         kill -9 $PID
      fi
       ;;
 restart)
       ${0} $1 stop
       ${0} $2 start
       ;;
 *)
    echo "Usage : ./springboot.sh <path_to_jar> {start|stop|restart}" >&2
    exit 1
esac 
