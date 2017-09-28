#!/bin/bash

SYSINFO=`head -n 1 /etc/issue`
IFS=$'\n'
UPTIME=`uptime`
D_UP=${UPTIME:1}
MYGROUPS=`groups`
DATE=`date`
KERNEL=`uname -a`
CPWD=`pwd`
ME=`whoami`
CPU=`arch`

printf "<=== SYSTEM ===>\n"
echo "  Distro info:	"$SYSINFO""
printf "  Kernel:\t"$KERNEL"\n"
printf "  Uptime:\t"$D_UP"\n"
free -mot | awk '
/Mem/{print "  Memory:\tTotal: " $2 "Mb\tUsed: " $3 "Mb\tFree: " $4 "Mb"}
/Swap/{print "  Swap:\t\tTotal: " $2 "Mb\tUsed: " $3 "Mb\tFree: " $4 "Mb"}'
printf "  Architecture:\t"$CPU"\n"
cat /proc/cpuinfo | grep "model name\|processor" | awk '
/processor/{printf "  Processor:\t" $3 " : " }
/model\ name/{
i=4
while(i<=NF){
	printf $i
	if(i<NF){
		printf " "
	}
	i++
}
printf "\n"
}'
printf "  Date:\t\t"$DATE"\n"
printf "\n<=== DISK USAGE===>\n"
printf "  DISK DETAILS\n"
df -hP | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ printf "Filesystem: " $1 "     Percent Used: " $5"\n"}'
printf "\n<=== Currently Mounted Filesystems ===>\n"
mount  | grep -Ev 'type (proc|sysfs|tmpfs|devpts|binfmt_misc) '
printf "\n<=== FSTAB ===>\n"
cat /etc/fstab | grep ext4 | cut -d$'\t' -f5 | awk '{ printf "Mountpoint: "$2"	Device: "$1" 	Filesystem: "$3"\n"}'
printf "\n<=== NETWORK ===>\n"
printf "  Hostname:\t"$HOSTNAME"\n"
ip -o addr show eth0 | awk '/inet /{print "  IP (" $2 "):\t" $4}'
/sbin/route -n | awk '/^0.0.0.0/{ printf "  Gateway:\t"$2"\n" }'
cat /etc/resolv.conf | awk '/^nameserver/{ printf "  Name Server:\t" $2 "\n"}'
printf "\n<=== NETSTAT ===>\n"
netstat -an | grep -Ev '(STREAM|DGRAM|Type|sockets) '
printf "\n<=== Running Processes ===>\n"
ps awfux |  grep -Ev '(\[)'
printf "\n<=== CRONTAB (root) ===>\n"
crontab -u root -l
printf "\n<=== IPTABLES ===>\n"
iptables -L
