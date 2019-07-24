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
	HOST_NODE=$(echo ${VARS} | cut -d',' -f2)
	HOSTNAME=$(echo ${VARS} | cut -d',' -f3)
	ssh root@${HOST_NODE} "virsh destroy ${HOSTNAME}"
	ssh root@${HOST_NODE} "virsh undefine ${HOSTNAME} && virsh pool-destroy ${HOSTNAME} && rm -rf /VirtualMachines/${HOSTNAME}"
done

