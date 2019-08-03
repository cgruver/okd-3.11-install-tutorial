## Nginx Config & RPM Repository Synch
We are going to install the Nginx HTTP server and configure it to serve up all of the RPM packages that we need to build our guest VMs.

We'll use the reposync and createrepo utilities to copy RPM repository contents from remote mirrors into our Nginx server.

Install the EPEL repository and the RPM repository utilities:

    yum -y install epel-release
    yum -y install createrepo

If you look at the contents of `/etc/yum.repos.d`, you should see files called `CentOS-Base.repo` and `epel.repo`.  These files contain the specifications for the repositories that we are going to synchronize.  `base, updates, extras, centosplus, and epel`

We need to open firewall ports for HTTP/S so that we can access our Nginx server:

    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload

Install and start Nginx:

    yum -y install nginx
    systemctl enable nginx
    systemctl start nginx

Create directories to hold all of the RPMs:

    mkdir -p /usr/share/nginx/html/repos/{base,centosplus,extras,updates}

Now, synch the repositories into the directories we just created:  (This will take a while)

    LOCAL_REPOS="base centosplus extras updates epel"
    for REPO in ${LOCAL_REPOS}; do
    reposync -g -l -d -m --repoid=${REPO} --newest-only --download-metadata --download_path=/usr/share/nginx/html/repos/
    createrepo /usr/share/nginx/html/repos/${REPO}/  
    done

Our Nginx server is now ready to serve up RPMs for our guest VM installations.

To refresh your RPM repositories, run this script again, or better yet, create a cron job to run it periodically.

    LOCAL_REPOS="base centosplus extras updates epel"
    for REPO in ${LOCAL_REPOS}; do
    reposync -g -l -d -m --repoid=${REPO} --newest-only --download-metadata --download_path=/usr/share/nginx/html/repos/
    createrepo /usr/share/nginx/html/repos/${REPO}/  
    done

Now, continue to [Sonatype Setup](Nexus_Config.md) or return to [Control Plane Setup](README.md)
