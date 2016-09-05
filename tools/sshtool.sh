#!/bin/bash
######################################
####Version:1.0
####Author:mingyuan
####Date:2016年8月31日23:14:19
####Mail:himingyuan@gmail.com
######################################
PRIVATE_KEY=~/.ssh/id_rsa
PUBILC_KEY=~/.ssh/id_rsa.pub
LOG=/mnt/sshhelper.log
PASSWD="123456"
##########example like next line.
#HOSTS="192.168.65.212 192.168.65.213"
HOSTS=""
create_rsa()
{
	if [ ! -f $PRIVATE_KEY ];then
		ssh-keygen -t rsa -P '' -f $PRIVATE_KEY
		echo "create rsa successful.">>$LOG
	else
		echo "RSA file is already created.">>$LOG
	fi
}
transport()
{
	/usr/bin/expect -c "
	set timeout 10
	spawn ssh-copy-id -i $PUBLIC_KEY root@$IP
	expect "yes/no" {exp_send "yes"\r;}
	expect "password:" {exp_send "$PASSWD"\r;}
	expect "*\#" {exp_send "exit"\r;}
	interact"
}
##################if the rsa key and pub file is already created,don't run the create_rsa function.
#create_rsa
for IP in $HOSTS
do
	transport
done
