#!/bin/sh
########This script is used for check system port.
########
input_list=$@
function check_port ()
{
	port_list=` netstat -lnt | awk 'NR>2{sub(".*:","", $4); print $4}'|sort -n|uniq`
	echo "$port_list">./Port.txt
	cat Port.txt|tr ' ' '\n'>Port1.txt
	echo "$input_list">./port.txt
	cat port.txt|tr ' ' '\n'>port1.txt
	for i in `cat port1.txt`
	do
		result=`grep $i Port1.txt`
		grep $i Port1.txt>/dev/null
		if [ $? -eq 1 ];then
			echo -e  "\033[32;31;1mport $i is closed.\033[0m"
		else
			  if [ $result -eq $i ];then
			echo -e  "\033[32;32;1mport $i is open.\033[0m"
			  else
			echo -e  "\033[32;31;1mport $i is closed.\033[0m"
			  fi
		fi
	done
	rm -rf  *ort*.txt
}
if [ $# -eq 0 ];then
	echo -e  "\033[32;34;1mUseage:you can run this script as ./check_port.sh 22 80 8080 ......\033[0m"
else
	check_port
fi
