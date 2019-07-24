#!/bin/bash

stopVM() {
	INVENTORY=$1
	TYPE=$2
	for VARS in $(cat ${INVENTORY} | grep -v "#" | grep ${TYPE})
	do
		TYPE=$(echo ${VARS} | cut -d',' -f1)
		HOSTNAME=$(echo ${VARS} | cut -d',' -f3)
		case ${TYPE} in
			INFRA)
			#ssh root@${HOSTNAME} "systemctl stop origin-node.service"
			ssh root@${HOSTNAME} "shutdown -h now"
         sleep 10
			;;
			APP)
			#ssh root@${HOSTNAME} "systemctl stop origin-node.service"
			ssh root@${HOSTNAME} "shutdown -h now"
         sleep 10
			;;
			MASTER)
			#ssh root@${HOSTNAME} "systemctl stop origin-node.service"
			#ssh root@${HOSTNAME} "systemctl stop origin-master-api.service"
			#ssh root@${HOSTNAME} "systemctl stop origin-master-controllers.service"
			ssh root@${HOSTNAME} "shutdown -h now"
         sleep 10
			;;
			SAN)
			#ssh root@${HOSTNAME} "systemctl stop glusterd"
			#ssh root@${HOSTNAME} "systemctl stop gluster-blockd"
			ssh root@${HOSTNAME} "shutdown -h now"
         sleep 10
			;;
			DB)
			ssh root@${HOSTNAME} "systemctl stop mariadb"
			ssh root@${HOSTNAME} "shutdown -h now"
         sleep 10
			;;
		esac
	done
}

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

stopVM "${INVENTORY}" "APP"
sleep 10
stopVM "${INVENTORY}" "INFRA"
sleep 10
stopVM "${INVENTORY}" "MASTER"
sleep 10
stopVM "${INVENTORY}" "DB"
sleep 10
stopVM "${INVENTORY}" "SAN"

