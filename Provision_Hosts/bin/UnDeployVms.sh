#!/bin/bash

for i in "$@"
do
case $i in
    -i=*|--inventory=*)
    INVENTORY="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

for VARS in $(cat ${INVENTORY} | grep -v "#")
do
	NODE=$(echo ${VARS} | cut -d',' -f2)
	HOSTNAME=$(echo ${VARS} | cut -d',' -f3)
    ssh root@${NODE}.${LAB_DOMAIN} "virsh destroy ${HOSTNAME}"
    ssh root@${NODE}.${LAB_DOMAIN} "virsh undefine ${HOSTNAME}"
    ssh root@${NODE}.${LAB_DOMAIN} "virsh pool-destroy ${HOSTNAME}"
    ssh root@${NODE}.${LAB_DOMAIN} "virsh pool-undefine ${HOSTNAME}"
    ssh root@${NODE}.${LAB_DOMAIN} "rm -rf /VirtualMachines/${HOSTNAME}"
done