#!/bin/bash

mkdir -p ~/bin/lab_bin

cat <<EOF > ~/bin/lab_bin/setLabEnv.sh
#!/bin/bash

export PATH=${PATH}:~/bin/lab_bin

export LAB_DOMAIN=${LAB_DOMAIN}
export LAB_NAMESERVER=${LAB_NAMESERVER}
export LAB_NETMASK=${LAB_NETMASK}
export LAB_GATEWAY=${LAB_GATEWAY}
export LAB_URL=http://${NGINX_HOST}.${LAB_DOMAIN}
EOF

cp bin/*.sh ~/bin/lab_bin
chmod 700 ~/bin/lab_bin/*.sh

mkdir lab_work

cp -rf ./kickstart lab_work 
cp -rf ./firstboot lab_work
cp -rf ./postinstall lab_work

cat ~/.ssh/id_rsa.pub > ./lab_work/postinstall/authorized_keys

for i in $(ls lab_work/kickstart)
do
   sed -i "" "s|%%LAB_URL%%|${LAB_URL}|g" ./lab_work/kickstart/${i}
   sed -i "" "s|%%LAB_PWD%%|${LAB_PWD}|g" ./lab_work/kickstart/${i}
done

for i in $(ls lab_work/firstboot)
do
   sed -i "" "s|%%LAB_URL%%|${LAB_URL}|g" ./lab_work/firstboot/${i}
   sed -i "" "s|%%LAB_DOMAIN%%|${LAB_DOMAIN}|g" ./lab_work/firstboot/${i}
   sed -i "" "s|%%DB_HOST%%|${DB_HOST}|g" ./lab_work/firstboot/${i}
done

sed -i "" "s|%%LAB_DOMAIN%%|${LAB_DOMAIN}|g" ./lab_work/postinstall/mariadb-server.cnf
sed -i "" "s|%%DB_HOST%%|${DB_HOST}|g" ./lab_work/postinstall/mariadb-server.cnf

scp -r ./lab_work/kickstart root@${NGINX_HOST}.${LAB_DOMAIN}:/usr/share/nginx/html
scp -r ./lab_work/firstboot root@${NGINX_HOST}.${LAB_DOMAIN}:/usr/share/nginx/html
scp -r ./lab_work/postinstall root@${NGINX_HOST}.${LAB_DOMAIN}:/usr/share/nginx/html

rm -rf ./lab_work
