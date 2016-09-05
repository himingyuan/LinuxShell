#!/bin/bash
####正则测试
channel=$1
jd=$2
list="a b c d e f"
list1="json jar test"
if [[ " $list " =~ " $channel " ]];then
	echo "y"
else
	echo "n"
fi 
