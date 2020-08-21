#!/bin/bash
user=oracle
groups=(dba oinstall)
ORACLE_BASE=/data/app

#rpm -ivh --nodeps --force oracle_deps/*.rpm

egrep "$user:" /etc/passwd >/dev/null 2>&1
if [ $? -eq 0 ]
then
  userdel -r $user
fi

for group in "${groups[@]}"
do
   egrep "^$group:" /etc/group >/dev/null 2>&1
   if [ $? -eq 0 ]
   then
      groupdel $group
   fi
   echo "creating group: $group"
   groupadd $group
done 


useradd -g oinstall -G dba oracle
echo "$user:oracle" | chpasswd

#创建oracle基本目录
mkdir -p $ORACLE_BASE/oracle
chown -R oracle:oinstall $ORACLE_BASE/oracle
chmod -R 755 $ORACLE_BASE/oracle

mkdir -p $ORACLE_BASE/oraInventory
chown -R oracle:oinstall $ORACLE_BASE/oraInventory
chmod -R 755 $ORACLE_BASE/oraInventory 

# configure the kernel params
sed -i '/kernel.shmall/d' /etc/sysctl.conf 
sed -i '/kernel.shmall/d' /etc/sysctl.conf 
sed -i '/kernel.shmmax/d' /etc/sysctl.conf  
sed -i '/kernel.shmmni/d' /etc/sysctl.conf 
sed -i '/kernel.sem/d' /etc/sysctl.conf 
sed -i '/fs.file-max/d' /etc/sysctl.conf 
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf 
sed -i '/net.core.rmem_default/d' /etc/sysctl.conf 
sed -i '/net.core.rmem_max/d' /etc/sysctl.conf 
sed -i '/net.core.wmem_default/d' /etc/sysctl.conf 
sed -i '/net.core.wmem_max/d' /etc/sysctl.conf 

cat >> /etc/sysctl.conf << EOF
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.file-max = 65536
net.ipv4.ip_local_port_range = 1024 65000
net.core.rmem_default = 262144
net.core.rmem_max = 262144
net.core.wmem_default = 262144
net.core.wmem_max = 262144
EOF

if [ $? -ne 0 ]
then
 # errorExit  
 echo "unable to configure settings for database"
fi

sed -i '/oracle soft nofile 65536/d' /etc/security/limits.conf
sed -i '/oracle hard nofile 65536/d' /etc/security/limits.conf
sed -i '/oracle soft nproc 65536/d' /etc/security/limits.conf
sed -i '/oracle hard nproc 65536/d' /etc/security/limits.conf

cat >> /etc/security/limits.conf << EOF
oracle soft nofile 65536
oracle hard nofile 65536
oracle soft nproc 65536
oracle hard nproc 65536
EOF
sed -i '/session    required     pam_limits.so/d' /etc/pam.d/login
cat >> /etc/pam.d/login << EOF
session    required     pam_limits.so
EOF
sed  -i '/if \[ \$USER = "oracle" \];/,$d' /etc/profile
cat >> /etc/profile << EOF
if [ \$USER = "oracle" ];
then if [ \$SHELL = "/bin/ksh"];
   then ulimit -p 65536 ulimit -n 65536
   else ulimit -u 65536 -n 65536
   fi
fi
EOF

cat >> /home/oracle/.bash_profile << EOF
export ORACLE_BASE=/data/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0.1
export ORACLE_SID=orcl
export PATH=\$PATH:\$HOME/bin:\$ORACLE_HOME/bin
export LD_LIBRARY_PATH=\$ORACLE_HOME/bin:/usr/lib
export LANG=en_US
export GDM_LANG=en_US
export LC=en_US
EOF
