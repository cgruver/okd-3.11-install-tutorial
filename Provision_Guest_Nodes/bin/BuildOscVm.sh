#!/bin/bash

for i in "$@"
do
case $i in
    -t=*|--type=*)
    TYPE="${i#*=}"
    shift 
    ;;
    -n=*|--hostnode=*)
    NODE="${i#*=}"
    shift 
    ;;
    -url=*|--install-url=*)
    LAB_URL="${i#*=}"
    shift
    ;;
    -vm=*|--vmhostname=*)
    HOSTNAME="${i#*=}"
    shift 
    ;;
    -m=*|--memory=*)
    MEMORY="${i#*=}"
    shift 
    ;;
    -c=*|--cpu=*)
    CPU="${i#*=}"
    shift 
    ;;
    -gw=*|--gateway=*)
    LAB_GATEWAY="${i#*=}"
    shift 
    ;;
    -nm=*|--netmask=*)
    LAB_NETMASK="${i#*=}"
    shift 
    ;;
    -d=*|--domain=*)
    LAB_DOMAIN="${i#*=}"
    shift 
    ;;
    -dns=*|--nameserver=*)
    LAB_NAMESERVER="${i#*=}"
    shift 
    ;;
    -dl=*|--disklist=*)
    DISK_LIST="${i#*=}"
    shift 
    ;;
    *)
          # unknown option
    ;;
esac
done

D1_SIZE=$(echo $DISK_LIST | cut -d"," -f1)
D2_SIZE=$(echo $DISK_LIST | cut -d"," -f2)

DISK_LIST="--disk size=${D1_SIZE},path=/VirtualMachines/${HOSTNAME}/rootvol,boot_order=1,bus=sata --disk size=${D2_SIZE},path=/VirtualMachines/${HOSTNAME}/dockervol,bus=sata"

KS="${LAB_URL}/kickstart"

case $TYPE in
	DEV)
	KS="${KS}/devnode.ks"
   DISK_LIST="--disk size=${D1_SIZE},path=/VirtualMachines/${HOSTNAME}/rootvol,boot_order=1,bus=sata"
	;;
	ROUTER)
	KS="${KS}/rtenode.ks"
   DISK_LIST="--disk size=${D1_SIZE},path=/VirtualMachines/${HOSTNAME}/rootvol,boot_order=1,bus=sata"
	;;
	MASTER)
	KS="${KS}/infranode.ks"
	;;
	INFRA)
	KS="${KS}/infranode.ks"
	;;
	APP)
	KS="${KS}/appnode.ks"
	;;
	SAN)
	KS="${KS}/sannode.ks"
	DISK_LIST="--disk size=${D1_SIZE},path=/VirtualMachines/${HOSTNAME}/rootvol,boot_order=1,bus=sata --disk size=${D2_SIZE},path=/VirtualMachines/${HOSTNAME}/glustervol,bus=sata"
	;;
	DB)
	KS="${KS}/dbnode.ks"
	DISK_LIST="--disk size=${D1_SIZE},path=/VirtualMachines/${HOSTNAME}/rootvol,boot_order=1,bus=sata --disk size=${D2_SIZE},path=/VirtualMachines/${HOSTNAME}/datavol,bus=sata"
	;;
esac

IP=$(ssh root@${NODE} "dig ${HOSTNAME}.${LAB_DOMAIN} +short")
ssh root@${NODE}.${LAB_DOMAIN} "mkdir -p /VirtualMachines/${HOSTNAME}"
ssh root@${NODE}.${LAB_DOMAIN} "virt-install --name ${HOSTNAME} --memory ${MEMORY} --vcpus ${CPU} --location ${LAB_URL}/centos7.5 ${DISK_LIST} --extra-args=\"inst.ks=${KS} ip=${IP}::${LAB_GATEWAY}:${LAB_NETMASK}:${HOSTNAME}.${LAB_DOMAIN}:eth0:none nameserver=${LAB_NAMESERVER} console=tty0 console=ttyS0,115200n8\" --network bridge=br1 --graphics none --noautoconsole --os-variant centos7.0 --wait=-1"
