#!/bin/bash
/usr/bin/expect <<EOF
set time 3
spawn ssh root@192.168.65.211
expect "*password:"
send "123456\r"
expect "*#"
send "mkdir /opt/a\r"
expect 
EOF
