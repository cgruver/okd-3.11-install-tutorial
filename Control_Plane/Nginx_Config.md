## Nginx Config & RPM Repository Synch
We are going to install the Nginx HTTP server and configure it to serve up all of the RPM packages that we need to build our guest VMs.

We'll use the reposync and createrepo utilities to copy RPM repository contents from remote mirrors into our Nginx server.

We are also going to copy the CentOS minimal install ISO into our Nginx server. 

Install the EPEL repository and the RPM repository utilities:

    yum -y install epel-release
    yum -y install centos-release-gluster6
    yum -y install createrepo

If you look at the contents of `/etc/yum.repos.d`, you should see files called `CentOS-Base.repo` and `epel.repo`.  These files contain the specifications for the repositories that we are going to synchronize.  `base, updates, extras, centosplus, and epel`

Now, let's add repositories for `KVM, and MariaDB`.  Both are included in the repositories that are part of the CentOS distribution, but they include versions that are too old for some things I use my lab for.  If you are going to experiment with Galera Cluster in MariaDB, or OpenShift 4.X on OpenStack, then you want these newer versions.

    echo <<EOF > /etc/yum.repos.d/kvm-common.repo
    [kvm-common]
    name=CentOS KVM Common
    baseurl=http://mirror.centos.org/centos/7/virt/x86_64/kvm-common/
    gpgcheck=0
    enabled=1
    EOF

    cat <<EOF > /etc/yum.repos.d/MariaDB.repo
    [mariadb]
    name = MariaDB
    baseurl = http://yum.mariadb.org/10.4/centos7-amd64
    enabled=1
    gpgcheck=0
    EOF


We need to open firewall ports for HTTP/S so that we can access our Nginx server:

    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload

Install and start Nginx:

    yum -y install nginx
    systemctl enable nginx
    systemctl start nginx

Create directories to hold all of the RPMs:

    mkdir -p /usr/share/nginx/html/repos/{base,centosplus,extras,updates,mariadb,kvm-common,centos-gluster6}

Now, synch the repositories into the directories we just created:  (This will take a while)

    LOCAL_REPOS="base centosplus extras updates epel mariadb kvm-common centos-gluster6"
    for REPO in ${LOCAL_REPOS}
    do
        reposync -g -l -d -m --repoid=${REPO} --newest-only --download-metadata --download_path=/usr/share/nginx/html/repos/
        createrepo /usr/share/nginx/html/repos/${REPO}/  
    done

Our Nginx server is now ready to serve up RPMs for our guest VM installations.

To refresh your RPM repositories, run this script again, or better yet, create a cron job to run it periodically.

    LOCAL_REPOS="base centosplus extras updates epel mariadb kvm-common centos-gluster6"
    for REPO in ${LOCAL_REPOS}
    do
        reposync -g -l -d -m --repoid=${REPO} --newest-only --download-metadata --download_path=/usr/share/nginx/html/repos/
        createrepo /usr/share/nginx/html/repos/${REPO}/  
    done

Next, we need to set up the Nginx server to serve up the CentOS installation files for our guest VMs

    mkdir -p /usr/share/nginx/html/install/centos
    wget https://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-Minimal.iso
    mkdir /tmp/centos-iso-mount
    mount -o loop CentOS-7-x86_64-Minimal.iso /tmp/centos-iso-mount
    rsync -av /tmp/centos-iso-mount/ /usr/share/nginx/html/centos/
    umount /tmp/centos-iso-mount
    rmdir /tmp/centos-iso-mount
    rm CentOS-7-x86_64-Minimal.iso

Now, continue to [Sonatype Setup](Nexus_Config.md) or return to [Control Plane Setup](README.md)
