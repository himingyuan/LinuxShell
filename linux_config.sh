#!/bin/bash
#formate the system. still creating editing----------------------------------------------------------------------------------
########Determine whether the root user
[ $(id -u) != "0" ]  && echo "run as root." && exit 1
########information
printf "
\033[34m#####################################################################################
#         This script can do these things:  					    #
#					1)CONFIGURE YOUR EPEL REPO.                 #
#					2)DOWNLOAD SOME USUAL TOOLS.                #
#					3)                                          #
#					4)                                          #                                         #
#####################################################################################
\033[0m"
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
echo "		********Epel source is configured success.**********"
}
#####download some tools
download()
{
yum install -y vim wget telnet zlib zlib-devel openssl openssl-devel python-setuptools python-pip java lrzsz 
}
