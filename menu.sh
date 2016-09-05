#!/bin/bash
#######add epel source
add_epel_source()
{
cat>/etc/yum.repos.d/epel.repo<<EOF
[epel]
name=epel
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-\$releasever&arch=\$basearch
enabled=1
gpgcheck=0
EOF
echo -e "\033[32m\t\t\t\tEpel source is configured success.\t\t\t\t\033[0m"
}
#####download some tools
download()
{
yum install -y vim wget telnet zlib zlib-devel openssl openssl-devel python-setuptools python-pip java
}
#####menu
menu()
{
echo -e "Select your choice:"
printf '\033[32m%100s\n\033[0m' | tr ' ' =
echo -e "\t${CMSG}1${CEND}.Add epel source."
echo -e "\t${CMSG}2${CEND}.Download basic packages."
echo -e "\t${CMSG}q${CEND}.Exit."
printf '\033[32m%100s\n\033[0m' | tr ' ' =
	read -p "Enter your choice number:" Number
}
	menu
case $Number in
	1)
	  add_epel_source
	  menu
	;;
	2)
	  download
	  menu
	;;
	q)
	  exit 0
	;;
	*)
	  echo "Error input!!!Try again"
	  exit 1
	;;
	esac

