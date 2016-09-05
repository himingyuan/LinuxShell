#!/bin/bash
#########每分钟运行一次
while true
do
  date=$(date +%F-%T)
  echo "$date!">>date.log
  sleep 1
done
