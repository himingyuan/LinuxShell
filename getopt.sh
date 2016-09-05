#!/bin/bash

######################  proc defination  ########################
# ignore rule
ignore_init()
{
        # ignore password
        array_ignore_pwd_length=0
        if [ -f ./ignore_pwd ]; then
                while read IGNORE_PWD
                do
                        array_ignore_pwd[$array_ignore_pwd_length]=$IGNORE_PWD
                        let array_ignore_pwd_length=$array_ignore_pwd_length+1
                done < ./ignore_pwd
        fi

        # ignore ip address
        array_ignore_ip_length=0
        if [ -f ./ignore_ip ]; then
                while read IGNORE_IP
                do
                        array_ignore_ip[$array_ignore_ip_length]=$IGNORE_IP
                        let array_ignore_ip_length=$array_ignore_ip_length+1
                done < ./ignore_ip
        fi
}

show_version()
{
        echo "version: 1.0"
        echo "updated date: 2014-01-09"
}

show_usage()
{
        echo -e "`printf %-16s "Usage: $0"` [-h|--help]"
        echo -e "`printf %-16s ` [-v|-V|--version]"
        echo -e "`printf %-16s ` [-l|--iplist ... ]"
        echo -e "`printf %-16s ` [-c|--config ... ]"
        echo -e "`printf %-16s ` [-t|--sshtimeout ... ]"
        echo -e "`printf %-16s ` [-T|--fttimeout ... ]"
        echo -e "`printf %-16s ` [-L|--bwlimit ... ]"
        echo -e "`printf %-16s ` [-n|--ignore]"
        #echo "ignr_flag: 'ignr'-some ip will be ignored; otherwise-all ip will be handled"
}

# Default Parameters
myIFS=":::"     # 配置文件中的分隔符

TOOLDIR=/root/scripts
cd $TOOLDIR

IPLIST="iplist.txt"                     # IP列表，格式为IP 端口 用户名 密码
CONFIG_FILE="config.txt"                # 命令列表和文件传送配置列表，关键字为com:::和file:::
IGNRFLAG="noignr"                       # 如果置为ignr，则脚本会进行忽略条件的判断
SSHTIMEOUT=100                          # 远程命令执行相关操作的超时设定，单位为秒
SCPTIMEOUT=2000                         # 文件传送相关操作的超时设定，单位为秒
BWLIMIT=1024000                         # 文件传送的带宽限速，单位为kbit/s

# 入口参数分析
TEMP=`getopt -o hvVl:c:t:T:L:n --long help,version,iplist:,config:,sshtimeout:,fttimeout:,bwlimit:,ignore -- "$@" 2>/dev/null`

[ $? != 0 ] && echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage && exit 1

# 会将符合getopt参数规则的参数摆在前面，其他摆在后面，并在最后面添加--
eval set -- "$TEMP"

while :
do
        [ -z "$1" ] && break;
        case "$1" in
                -h|--help)
                        show_usage; exit 0
                        ;;
                -v|-V|--version)
                        show_version; exit 0
                        ;;
                -l|--iplist)
                        IPLIST=$2; shift 2
                        ;;
                -c|--config)
                        CONFIG_FILE=$2; shift 2
                        ;;
                -t|--sshtimeout)
                        SSHTIMEOUT=$2; shift 2
                        ;;
                -T|--fttimeout)
                        SCPTIMEOUT=$2; shift 2
                        ;;
                -L|--bwlimit)
                        BWLIMIT=$2; shift 2
                        ;;
                -n|--ignore)
                        IGNRFLAG="ignr"; shift
                        ;;
                --)
                        shift
                        ;;
                *)
                        echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage && exit 1
                        ;;
        esac
done

################  main  #######################
BEGINDATETIME=`date "+%F %T"`
[ ! -f $IPLIST ] && echo -e "\033[31mERROR: iplist \"$IPLIST\" not exists, please check! \033[0m\n" && exit 1

[ ! -f $CONFIG_FILE ] && echo -e "\033[31mERROR: config \"$CONFIG_FILE\" not exists, please check! \033[0m\n" && exit 1

echo
echo "You are using:"
echo -e "`printf %-16s "\"$CONFIG_FILE\""` ---- as your config"
echo -e "`printf %-16s "\"$IPLIST\""` ---- as your iplist"
echo -e "`printf %-16s "\"$SSHTIMEOUT\""` ---- as your ssh timeout"
echo -e "`printf %-16s "\"$SCPTIMEOUT\""` ---- as your scp timeout"
echo -e "`printf %-16s "\"$BWLIMIT\""` ---- as your bwlimit"
echo -e "`printf %-16s "\"$IGNRFLAG\""` ---- as your ignore flag"
echo

[ -f ipnologin.txt ] && rm -f ipnologin.txt
IPSEQ=0
while read IP PORT USER PASSWD PASSWD_2ND PASSWD_3RD PASSWD_4TH OTHERS
do
        [ -z "`echo $IP | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`" ] && continue
        [ "`python $TOOLDIR/ckssh.py $IP $PORT`" == 'no' ] && echo "$IP" >> ipnologin.txt && continue

        let IPSEQ=$IPSEQ+1

        # 如果启用了忽略，则进入忽略流程
        if [ $IGNRFLAG == "ignr" ]; then
                ignore_init
                ignored_flag=0

                i=0
                while [ $i -lt $array_ignore_pwd_length ]
                do
                        [ ${PASSWD}x == ${array_ignore_pwd[$i]}x ] && ignored_flag=1 && break
                        let i=$i+1
                done

                [ $ignored_flag -eq 1 ] && continue

                j=0
                while [ $j -lt $array_ignore_ip_length ]
                do
                        [ ${IP}x == ${array_ignore_ip[$j]}x ] && ignored_flag=1 && break
                        let j=$j+1
                done

                [ $ignored_flag -eq 1 ] && continue

        fi

        ####### Try password from here ####
        for PW in $PASSWD $PASSWD_2ND $PASSWD_3RD $PASSWD_4TH
        do
                PASSWD_USE=$PW
                $TOOLDIR/ssh.exp $IP $USER $PW $PORT true $SSHTIMEOUT
                [ $? -eq 0 ] && PASSWD_USE=$PW && break
        done

        # 针对一个$IP，执行配置文件中的一整套操作
        while read eachline
        do
                # 必须以com或file开头
                [ -z "`echo $eachline | grep -E '^com|^file'`" ] && continue

                myKEYWORD=`echo $eachline | awk -F"$myIFS" '{ print $1 }'`
                myCONFIGLINE=`echo $eachline | awk -F"$myIFS" '{ print $2 }'`

                # 对配置文件中的预定义的可扩展特殊字符串进行扩展
                # 关键字#IP#，用$IP进行替换
                if [ ! -z "`echo "$myCONFIGLINE" | grep '#IP#'`" ]; then
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#IP#/$IP/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                # 时间相关关键字，用当前时间进行替换
                if [ ! -z "`echo "$myCONFIGLINE" | grep '#YYYY#'`" ]; then
                        myYEAR=`date +%Y`
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#YYYY#/$myYEAR/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                if [ ! -z "`echo "$myCONFIGLINE" | grep '#MM#'`" ]; then
                        myMONTH=`date +%m`
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#MM#/$myMONTH/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                if [ ! -z "`echo "$myCONFIGLINE" | grep '#DD#'`" ]; then
                        myDATE=`date +%d`
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#DD#/$myDATE/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                if [ ! -z "`echo "$myCONFIGLINE" | grep '#hh#'`" ]; then
                        myHOUR=`date +%H`
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#hh#/$myHOUR/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                if [ ! -z "`echo "$myCONFIGLINE" | grep '#mm#'`" ]; then
                        myMINUTE=`date +%M`
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#mm#/$myMINUTE/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                if [ ! -z "`echo "$myCONFIGLINE" | grep '#ss#'`" ]; then
                        mySECOND=`date +%S`
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#ss#/$mySECOND/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                # IPSEQ关键字，用当前IP的序列号替换，从1开始
                if [ ! -z "`echo "$myCONFIGLINE" | grep '#IPSEQ#'`" ]; then
                        myCONFIGLINE_temp=`echo $myCONFIGLINE | sed "s/#IPSEQ#/$IPSEQ/g"`
                        myCONFIGLINE=$myCONFIGLINE_temp
                fi

                # 配置文件中有关键字file:::，就调用scp.exp进行文件传送
                if [ "$myKEYWORD"x == "file"x ]; then
                        SOURCEFILE=`echo $myCONFIGLINE | awk '{ print $1 }'`
                        DESTDIR=`echo $myCONFIGLINE | awk '{ print $2 }'`
                        DIRECTION=`echo $myCONFIGLINE | awk '{ print $3 }'`
                        $TOOLDIR/scp.exp $IP $USER $PASSWD_USE $PORT $SOURCEFILE $DESTDIR $DIRECTION $BWLIMIT $SCPTIMEOUT

                        [ $? -ne 0 ] && echo -e "\033[31mSCP Try Out All Password Failed\033[0m\n"

                # 配置文件中有关键字com:::，就调用ssh.exp进行远程命令执行
                elif [ "$myKEYWORD"x == "com"x ]; then
                        $TOOLDIR/ssh.exp $IP $USER $PASSWD_USE $PORT "${myCONFIGLINE}" $SSHTIMEOUT
                        [ $? -ne 0 ] && echo -e "\033[31mSSH Try Out All Password Failed\033[0m\n"

                else
                        echo "ERROR: configuration wrong! [$eachline] "
                        echo "       where KEYWORD should not be [$myKEYWORD], but 'com' or 'file'"
                        echo "       if you dont want to run it, you can comment it with '#'"
                        echo ""
                        exit
                fi

        done < $CONFIG_FILE

done < $IPLIST

ENDDATETIME=`date "+%F %T"`

echo "$BEGINDATETIME -- $ENDDATETIME"
echo "$0 $* --excutes over!"

exit 0
