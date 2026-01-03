#!/bin/sh
#
PATH=/bin:/usr/sbin:/usr/bin
export PATH
# 
# jumpconfig.sh 
# 
# Current Rev. 1.0
# 
# 10-01-03 Begining revision history.
#
# Rev 1.0 10-01-03
#
# Changed format of jumpconfig.sh output so that is is more usable
# Added whoami to beginning of script to assure it is run as root
# Added /path_to_image/Solaris_*/Tools/Boot/etc/inet/hosts
#       /path_to_image/Solaris_*/Tools/Boot/etc/inet/netmasks
#       /path_to_image/Solaris_*/Tools/Boot/etc/nsswitch.conf
#       /path_to_image/Solaris_*/Tools/Boot/etc/resolv.conf
#       /path_to_image/Solaris_*/Tools/Boot/etc/path_to_inst
# Added netstat -rn
# Added 'rpcinfo -b 100026 1' to locate other rpc.bootparmd
# Collecting contents of install_config directory
#

if [ `/usr/ucb/whoami` != root ]; then
	echo ""
        echo "You must be root to run this script"
	echo ""
	exit
fi

PATH=/usr/sbin:$PATH 
DIR=`uname -n`.`date +%m%d%y%H%M%S`
ARCH=`uname -m`
PLATFORM=`uname -i`
mkdir $DIR

# Collect client hostname
echo "Please enter the client name of the system you are jumpstarting: \c"
read JSCLIENTSUNW

echo "== Jumpstart configuration collected for client $JSCLIENTSUNW ==" > $DIR/output

# Collect nsswitch.conf settings
cp /etc/nsswitch.conf $DIR
echo "======= Nsswitch.conf File  /etc/nsswitch.conf ======" >> $DIR/output
cat /etc/nsswitch.conf >> $DIR/output
echo "################" >> $DIR/output
HOSTSNSSW=`grep '^hosts:' /etc/nsswitch.conf | nawk '{print $2}'`
/usr/bin/mkdir /tmp/SunWorkScriptDir
if [ "$HOSTSNSSW" = "files" ] 
then
        echo "hosts is set to files"
        echo "======= Hosts Info  /etc/hosts ============" >> $DIR/output 
	cat /etc/hosts >> $DIR/output
        echo "################" >> $DIR/output 
        cp /etc/hosts $DIR/local_etc_hosts
elif [ "$HOSTSNSSW" = "nis" ] 
then
        echo "hosts is set to nis"
	echo "======= Hosts Info  NIS ==========" >> $DIR/output
	ypcat hosts >> $DIR/output
	echo "################" >> $DIR/output
        ypcat hosts > $DIR/ypcat_hosts.out
else 
   if [ "$HOSTSNSSW" = "nisplus" ] 
then
        echo "======= Hosts Info - NIS+ ==========" >> $DIR/output
        echo "hosts is set to nis+"
        niscat hosts > $DIR/niscat_hosts.out
	niscat hosts >> $DIR/output
	echo "################" >> $DIR/output
   fi
fi
BPARAMSNSSW=`grep '^bootparams:' /etc/nsswitch.conf | nawk '{print $2}'`
if [ "$BPARAMSNSSW" = "files" ]
then
        echo "bootparams is set to files"
        cp /etc/bootparams $DIR/local_etc_bootparams
        echo "======= Bootparams Info  /etc/bootparams ======" >> $DIR/output
        cat /etc/bootparams >> $DIR/output 
        echo "################" >> $DIR/output 
elif [ "$BPARAMSNSSW" = "nis" ]
then
        echo "bootparams is set to nis"
        echo "======= Bootparams Info  NIS ========" >> $DIR/output 
	ypcat bootparams >> $DIR/output
	echo "################" >> $DIR/output
        ypcat bootparams > $DIR/ypcat_bootparams.out
else
   if [ "$BPARAMSNSSW" = "nisplus" ]
then
        echo "bootparams is set to nis+"
        echo "======= Bootparams Info - NIS+ ========" >> $DIR/output
	niscat bootparams > $DIR/output
        echo "################" >> $DIR/output
        niscat bootparams > $DIR/niscat_bootparams.out
   fi
fi
ETHERSNSSW=`grep '^ethers:' /etc/nsswitch.conf | nawk '{print $2}'`
if [ "$ETHERSNSSW" = "files" ]
then
        echo "ethers is set to files"
        echo "======= Ethers Info  /etc/ethers =======" >> $DIR/output 
        cat /etc/ethers >> $DIR/output
        echo "################" >> $DIR/output
        cp /etc/ethers $DIR/local_etc_ethers
elif [ "$ETHERSNSSW" = "nis" ]
then
        echo "ethers is set to nis"
        echo "======= Ethers Info  NIS ===========" >> $DIR/output 
        ypcat ethers >> $DIR/output
        echo "################" >> $DIR/output
        ypcat ethers > $DIR/ypcat_ethers.out
else
   if [ "$ETHERSNSSW" = "nisplus" ]
then
        echo "ethers is set to nis+"
        echo "======= Ethers Info - NIS+ =======" >> $DIR/output 
        niscat ethers >> $DIR/output
        echo "################" >> $DIR/output
        niscat ethers > $DIR/niscat_ethers.out
   fi
fi
 
# Collect bootparams, in case files in not first in nsswitch.conf
cp /etc/bootparams $DIR/etc_bootparams
echo "======= Bootparams entry  /etc/bootparams ========" >> $DIR/output
cat /etc/bootparams >> $DIR/output
echo "################" >> $DIR/output

# Collect share data
echo "======= Share Output ===========" >> $DIR/output 
/usr/sbin/share > $DIR/share.out
/usr/sbin/share >> $DIR/output
echo "################" >> $DIR/output

# Collect netmasks info
cat /etc/bootparams  | grep ${JSCLIENTSUNW} > /tmp/SunWorkScript
/usr/bin/nawk '{print $2}' /tmp/SunWorkScript > /tmp/SunWorkScript.100
JSINETMAS=`/usr/bin/nawk -F: '{print $2}' /tmp/SunWorkScript.100`
/usr/bin/nawk -F= '{print $3}' /tmp/SunWorkScript > /tmp/SunWorkScript.200
JSSERVERRM=`/usr/bin/nawk -F:  '{print $1}' /tmp/SunWorkScript.200`

# Collect Jumpstart server's netmask
cp /etc/netmasks $DIR/etc_netmasks
echo "======= Netmasks Info =============" >> $DIR/output 
cat /etc/netmasks >> $DIR/output
echo "################" >> $DIR/output

# Collect jumpstart image config files, in case corrupted
# Only collecting link status as they cannot be copied.
mkdir $DIR/jumpstart_config_files
ls -al ${JSINETMAS}/etc/inet/hosts >>  $DIR/jumpstart_config_files/etc_inet_hosts
ls -al ${JSINETMAS}/etc/inet/netmasks >> $DIR/jumpstart_config_files/etc_inet_netmasks
ls -al ${JSINETMAS}/etc/nsswitch.conf >> $DIR/jumpstart_config_files/etc_nsswitch_conf
ls -al ${JSINETMAS}/etc/resolv.conf >> $DIR/jumpstart_config_files/etc_resolve_conf

# Collect jumpstart image's path_to_inst
cp ${JSINETMAS}/etc/path_to_inst $DIR/jumpstart_config_files

# Collecting jumpstart images netmask
cp ${JSINETMAS}/netmask $DIR/jumpstart_images_netmask
echo "======= Jumpstart Servers /etc/netmasks ===========" >> $DIR/output 
cat ${JSINETMAS}/netmask >> $DIR/output
echo "################" >> $DIR/output 

# Collect permissions of the Boot directory of image
ls -al ${JSINETMAS} >> $DIR/contents_of_boot_directory

# Collect ifconfig data
echo "======= ifconfig -a output =============" >> $DIR/output 
/usr/sbin/ifconfig -a >> $DIR/output
echo "################" >> $DIR/output
ifconfig -a > $DIR/ifconfig_a.out

# Collect netstat -rn
echo "======= netstat -rn output =============" >> $DIR/output 
netstat -rn >> $DIR/output
echo "################" >> $DIR/output
netstat -rn > $DIR/netstat_rn.out

# Collect rpc, rarp, nfs Daemon Status
echo "======= rpc, rarp, nfs Daemons =========" >> $DIR/output 
ps -ef|egrep 'rpc|rarpd|nfs' > $DIR/rpc_rarp_nfs_status.out
ps -ef|egrep 'rpc|rarpd|nfs' >> $DIR/output
echo "################" >> $DIR/output

# Collect rpcinfo output
echo "Collecting rpcinfo data... this may take a moment."
echo "======= rpcinfo -b 100026 output =========" >> $DIR/output
rpcinfo -b 100026 1  > $DIR/rpcinfo_b.out
cat $DIR/rpcinfo_b.out >> $DIR/output

# Collect sysidcfg
echo "################" >> $DIR/output
echo "Collecting clients sysidcfg..."
/usr/bin/nawk -F: '{print $5}' /tmp/SunWorkScript > /tmp/SunWorkScript.0
SYSIDCFG=`/usr/bin/nawk '{print $1}' /tmp/SunWorkScript.0`
/usr/bin/nawk -F: '{print $4}' /tmp/SunWorkScript > /tmp/SunWorkScript.400
CONFIGJSHOST=`/usr/bin/nawk -F= '{print $2}' /tmp/SunWorkScript.400`
JSLOCALHN=`/usr/bin/hostname`
if [ "$CONFIGJSHOST" = "$JSLOCALHN" ]
then
	cp ${SYSIDCFG}/sysidcfg $DIR/sysidcfg
        echo "======= Clients local sysidcfg file =======" >> $DIR/output 
        cat ${SYSIDCFG}/sysidcfg >> $DIR/output 

else
	/usr/sbin/mount ${CONFIGJSHOST}:${SYSIDCFG} /tmp/SunWorkScriptDir
	cp /tmp/SunWorkScriptDir/sysidcfg $DIR/sysidcfg
        echo "======= Clients remote sysidcfg file =========" >> $DIR/output 
        cat /tmp/SunWorkScriptDir/sysidcfg >> $DIR/output
	umount /tmp/SunWorkScriptDir
fi

# Collect install_config directory
echo "################" >> $DIR/output
echo "Collecting clients rules.ok directory..."
/usr/bin/nawk -F: '{print $6}' /tmp/SunWorkScript > /tmp/SunWorkScript.0
RULES=`/usr/bin/nawk '{print $1}' /tmp/SunWorkScript.0`
if [ "$CONFIGJSHOST" = "$JSLOCALHN" ]
then
	mkdir $DIR/rules_contents
        cp ${RULES}/* $DIR/rules_contents
        echo "======= Clients local rules.ok file =======" >> $DIR/output 
        cat ${RULES}/rules.ok >> $DIR/output 

else
        /usr/sbin/mount ${CONFIGJSHOST}:${RULES} /tmp/SunWorkScriptDir
        cp /tmp/SunWorkScriptDir/* $DIR/rules_contents
        echo "======= Clients remote rules.ok file ========" >> $DIR/output 
        cat /tmp/SunWorkScriptDir/rules.ok >> $DIR/output 
        umount /tmp/SunWorkScriptDir
fi

# Collect dfshares
echo "################" >> $DIR/output
echo "======= Dfshares output from config server =====" >> $DIR/output 
/usr/sbin/dfshares ${CONFIGJSHOST} >> $DIR/output 
echo "################" >> $DIR/output 
echo "======= Dfshares output from install server ======" >> $DIR/output 
/usr/sbin/dfshares ${JSSERVERRM} >> $DIR/output 
/usr/sbin/dfshares ${CONFIGJSHOST} > $DIR/dfshares_config_server.out 
/usr/sbin/dfshares ${JSSERVERRM} > $DIR/dfshares_install_server.out
rmdir /tmp/SunWorkScriptDir
echo "################" >> $DIR/output

# Collect tftpboot directory
echo "============== tftpboot ===========" >> $DIR/output
ls -al /tftpboot >> $DIR/output
ls -al /tftpboot > $DIR/tftpboot_dir.out

# Collect jumpstart server config
echo "################" >> $DIR/output
echo "============== Server Configuration ==========" >> $DIR/output
/usr/platform/sun4u/sbin/prtdiag -v >> $DIR/prtdiag_v.out
/usr/platform/sun4u/sbin/prtdiag -v >> $DIR/output

# Cleaning up
/usr/bin/rm /tmp/SunWorkScr*

# Creating outfile
tar cvf $DIR.tar $DIR 2>&1 >/dev/null
compress $DIR.tar
rm -rf $DIR
echo "Please return by e-mail the $DIR.tar.Z file."
