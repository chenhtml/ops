#!/bin/bash

#Location JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/jre

export PATH=$JAVA_HOME/bin:$PATH

export CATALINA_HOME=/usr/local/tomcat

export CATALINA_BASE=/usr/local/tomcat

export TOMCAT_USER=tomcat

TOMCAT_USAGE="Usage: $0 start stop status restart"

SHUTDOWN_WAIT=20

tomcat_pid() {
  echo `ps -ef | grep $CATALINA_BASE | grep -v grep | tr -s " "|cut -d" " -f2`
}

oracle_port_opend(){
 nmap -v 192.168.92.137 -p T:1521 | awk '/Discovered open port/{print $4}'|awk -F/ '{print $1}'
}
start() {
  pid=$(tomcat_pid)
  port=$(oracle_port_opend)
  let kwait=20
     count=0;
  if [ -n "$pid" ]
  then
     echo -e "\e[00;31mTomcat is already running (pid: $pid)\e[00m "
  else
      echo -e "Staring tomcat"
      until [ "$port" == "1521" ] || [ $count -gt $kwait ]
      do 
        echo "waiting for oracle start"
        sleep 1
        count=$[ $count + 1 ]
      done
      if [ $count -gt $kwait ]
      then
         echo "make sure oracle started"
      else
      	if [ `user_exists $TOMCAT_USER` = "1" ]
      	then
           su  $TOMCAT_USER -s /bin/bash  -c $CATALINA_HOME/bin/startup.sh
      	else
           sh $CATA_LINA/bin/startup.sh
      	fi
      fi
      status
  fi
  return
}

status() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
     echo -e "Tomcat is running with pid: $pid"
  else
     echo -e "Tomcat is not running"
  fi
}

stop() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
     echo -e "Stopping Tomcat"
     sh $CATALINA_HOME/bin/shutdown.sh
     let kwait=$SHUTDOWN_WAIT
      count=0;
     until [ `ps -p $pid | grep -c $pid`='0' ] || [ $count -gt $kwait ] 
     do 
        echo -n -e "waiting for process to exit"
        sleep
        let count=$count + 1
     done 

     if [ $count -gt $kwait ]
     then
         echo -n -e "killing process which didn't stop after $SHUTDOWN_WAIT seconds"
         kill -9 $pid
     fi
  else
      echo -e "Tomcat is not running"
  fi
  return
}

user_exists() {
  if id -u $1 >/dev/null 2>&1; then
  echo "1"
  else
   echo "0"
  fi
}

case $1 in 
  start)
     start
  ;;
  
  stop)
     stop
  ;;
 
 restart)
    stop
    start
  ;;
  status)
    status
  ;;

  *)
    echo -e $TOMCAT_USAGE
  ;;
esac
exit 0
