## Nginx Config & RPM Repo Synch

yum -y install nginx

systemctl enable nginx

systemctl start nginx

firewall-cmd --permanent --add-service=http

firewall-cmd --permanent --add-service=https

mkdir -p /usr/share/nginx/html/repos/{base,centosplus,extras,updates,mariadb}

LOCAL_REPOS="base centosplus extras updates epel mariadb"
##a loop to update repos one at a time 
for REPO in ${LOCAL_REPOS}; do
reposync -g -l -d -m --repoid=${REPO} --newest-only --download-metadata --download_path=/usr/share/nginx/html/repos/
createrepo /usr/share/nginx/html/repos/${REPO}/  
done
