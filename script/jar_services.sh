#!/bin/bash
##
#用途：用来启动jar服务
##
JARFILE=$1

if [ ! -f $JARFILE ]
then
   echo $JARFILE 不存在
   exit 1
fi
#获取jar服务进程id
function jar_pid() {
  jps -l | grep ${JARFILE##*/} | awk '{print $1}'
}
#jar服务启动函数
function start() 
{
  PID=$(jar_PID)
  if [ -z ${PID} ]
  then
     echo "开始启动 $JARFILE" 
     nohup java -jar $JARFILE &>/dev/null &
     sleep 20
     PID=$(jar_pid)
     if [ ! -z ${PID} ]
     then
        echo "$JARFILE 启动成功,进程ID：${PID}"
     else
        echo "$JARFILE 启动失败，请查看日志！"
     fi
  else
     echo "$JARFILE 已在运行,进程ID：${PID}"
  fi
}
#jar服务停止函数
function stop() {
  PID=$(jar_pid)
  if [ -z $PID ]
  then
     echo "$JARFILE未运行！"
     exit 0
  else
     kill $PID
     while [ -x /proc/$PID ]
     do
        echo "等待 $JARFILE 结束运行...."
        sleep 1
     done
     echo "$JARFILE 已经结束运行。"
  fi
}

function status() {
  PID=$(jar_pid)
  if [ -z $PID ]
  then
      echo "$JARFILE 未运行"
  else
      echo "$JARFILE 正则运行，进程：$PID"
  fi
}


case $2 in
 start)
   start
   ;;
 stop)
  stop
  ;;
 restart)
  stop && start
  ;;
 status)
  status
  ;;
 *)
  echo "用法：$0 jarfile [start|restart|stop|status]"
  ;;
esac
