#!/bin/sh
############This script is used for check system kernel version.
function check_kernel()
{
	first_num=`uname -r|awk -F '.' '{print$1}'`
	second_num=`uname -r|awk -F '.' '{print$2}'`
	third_num=`uname -r|awk -F '.' '{print$3}'|awk -F'-' '{print$1}'`
	echo "Enter your requirement kernel number (like 2.6.9):"
	read req_num
	echo $req_num>version.txt
	first=`cat version.txt|awk -F '.' '{print$1}'`
	second=`cat version.txt|awk -F '.' '{print$2}'`
	third=`cat version.txt|awk -F '.' '{print$3}'`
	if [ $first_num -gt $first ];then
		echo -e "\033[33;32;1mkernel version is meet the requirement.\033[0m"
	elif [ $first_num -eq $first ];then
		if [ $second_num -gt $second ];then
			echo -e "\033[33;32;1mkernel version is meet the requirement.\033[0m"
		elif [ $second_num -eq $second ];then
			if [ $third_num -ge $third ];then
				echo -e "\033[33;32;1mkernel version is meet the requirement.\033[0m"
			else
				echo -e  "\033[33;31;1mkernel version is not  meet the requirement.\033[0m"
			fi
		else
			echo -e  "\033[33;31;1mkernel version is not  meet the requirement.\033[0m"
		fi
	else
		echo -e  "\033[33;31;1mkernel version is not  meet the requirement.\033[0m"
		
	fi			
	rm -f version.txt
}
check_kernel
