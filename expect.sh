#!/bin/bash
/usr/bin/expect -c "
set timeout 10
spawn ssh root@192.168.65.213
expect "password:" {exp_send "123456"\r;}
expect "*#" {exp_send "exit"\r;}
interact"
