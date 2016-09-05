#!/bin/bash
###########################
# version: 1.0
# author: mingyuan.liu
# date:  20151214 
###########################
#######测试内网主机存活状态########
echo -en "\033[32;36;1mInput the network which do you want to test(format like x.x.x):\033[0m"
read NETWORK
for HOST in `seq 254`
do
        ping -c 1 -w 1 $NETWORK.$HOST &>/dev/null
		                if [ "$?" == 0 ];then
					        echo -e "\033[32;32;1m$NETWORK.$HOST is up! \033[0m"
					    else
	                        echo -e "\033[32;31;1m$NETWORK.$HOST is down!\033[0m"
						fi
																										
done
