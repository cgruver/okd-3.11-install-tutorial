#!/bin/bash

DOMAIN=your.domain.com
NAMESERVER=10.10.11.10
NETMASK=255.255.255.0
GATEWAY=10.10.11.1
URL=http://ocp-controller01.your.domain.com

for i in "$@"
do
case $i in
    -i=*|--inventory=*)
    INVENTORY="${i#*=}"
    shift # past argument=value
    ;;
    -url=*|--install-url=*)
    URL="${i#*=}"
    shift
    ;;
    -gw=*|--gateway=*)
    GATEWAY="${i#*=}"
    shift # past argument with no value
    ;;
    -nm=*|--netmask=*)
    NETMASK="${i#*=}"
    shift # past argument with no value
    ;;
    -d=*|--domain=*)
    DOMAIN="${i#*=}"
    shift # past argument with no value
    ;;
    -dns=*|--nameserver=*)
    NAMESERVER="${i#*=}"
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

for VARS in $(cat ${INVENTORY} | grep -v "#")
do
	TYPE=$(echo ${VARS} | cut -d',' -f1)
	HOST_NODE=$(echo ${VARS} | cut -d',' -f2)
	HOSTNAME=$(echo ${VARS} | cut -d',' -f3)
	MEMORY=$(echo ${VARS} | cut -d',' -f4)
	CPU=$(echo ${VARS} | cut -d',' -f5)
	ROOT_VOL=$(echo ${VARS} | cut -d',' -f6)
	DATA_VOL=$(echo ${VARS} | cut -d',' -f7)
	BuildOscVm.sh -t=${TYPE} -n=${HOST_NODE} -url=${URL} -vm=${HOSTNAME} -m=${MEMORY} -c=${CPU} -gw=${GATEWAY} -nm=${NETMASK} -d=${DOMAIN} -dns=${NAMESERVER} -dl=${ROOT_VOL},${DATA_VOL} &
done

