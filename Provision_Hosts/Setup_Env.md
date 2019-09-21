## Setting up for Host OS provisioning:

Clone this repository if you have not done so already.

        git clone https://github.com/cgruver/okd-3.11-tutorial.git

Now we're going to set up your local environment for the automation I provided.

1. Create a local path for the shell scripts:

        mkdir -p ~/bin/lab_bin
    
1. Set some environment variables for your lab.  You will need to know the domain that you created during DNS setup, the IP address of your Name Server, your network mask, your network gateway, the hostname of your Nginx server, and if you set up PXE install, you will need the IP address of the HTTP server hosting your install repo. 

        LAB_DOMAIN=your.domain.com  # The Domain you created during DNS setup
        LAB_NAMESERVER=10.10.11.10  # The IP address of your DNS Server
        LAB_NETMASK=255.255.255.0   # The network mask of your lab network
        LAB_GATEWAY=10.10.11.1      # Your router IP address
        INSTALL_HOST_IP=10.10.11.1  # The IP of the host serving the install repo (your PXE server or your control plane server)
        INSTALL_ROOT=/usr/share/nginx/html/install
        REPO_HOST=ocp-controller01  # Your Control Plane server

1. Create a script to set your environment:

        cat <<EOF > ~/bin/lab_bin/setLabEnv.sh
        #!/bin/bash

        export PATH=${PATH}:~/bin/lab_bin
        export LAB_DOMAIN=${LAB_DOMAIN}
        export LAB_NAMESERVER=${LAB_NAMESERVER}
        export LAB_NETMASK=${LAB_NETMASK}
        export LAB_GATEWAY=${LAB_GATEWAY}
        export REPO_HOST=${REPO_HOST}
        export INSTALL_HOST_IP=${INSTALL_HOST_IP}
        export INSTALL_ROOT=${INSTALL_ROOT}
        export REPO_URL=http://${REPO_HOST}.${LAB_DOMAIN}
        export INSTALL_URL=http://${INSTALL_HOST_IP}/install
        EOF

    This script you just created will set your environment and PATH for guest VM provisioning.  Run this before you start provisioning VMs

        . ~/bin/lab_bin/setLabEnv.sh

    Or, add it to your shell profile, `.bash_profile`, or `.bashrc`, so that it is automatically run when you login.

1. Change directory into the git repository that you cloned:

        cd okd-3.11-tutorial/Provision_Hosts
    
1. Copy the provided shell scripts into your lab_bin directory:

        cp bin/*.sh ~/bin/lab_bin
        chmod 700 ~/bin/lab_bin/*.sh
    
1. Now, create a working directory for the kickstart templates:

        mkdir lab_work
        cp -rf ./html/kickstart lab_work 
        cp -rf ./html/firstboot lab_work
        cp -rf ./html/postinstall lab_work

1. Copy your SSH public key into an authorized_keys file to enable passwordless SSH from this system to your guest VMs:

        cat ~/.ssh/id_rsa.pub > ./lab_work/postinstall/authorized_keys
    
1. Create an encrypted root password string for your guest VMs:

        export LAB_PWD=$(openssl passwd -1 '<YourRootPasswordHere>')
    
1. Now you are going to use `sed` to populate the template files with the environment variables we set up earlier, and push the complete kickstart files to your Nginx server:
   
   __NOTE: If you are running this on a Mac, the `sed` command uses BSD syntax.  Add a set of empty `""` after the `-i` to satisfy the BSD syntax for `sed`.__

        for i in $(ls lab_work/kickstart)
        do
            sed -i "s|%%INSTALL_URL%%|${INSTALL_URL}|g" ./lab_work/kickstart/${i}
            sed -i "s|%%LAB_PWD%%|${LAB_PWD}|g" ./lab_work/kickstart/${i}
        done

        for i in $(ls lab_work/firstboot)
        do
           sed -i "s|%%INSTALL_URL%%|${INSTALL_URL}|g" ./lab_work/firstboot/${i}
           sed -i "s|%%REPO_URL%%|${REPO_URL}|g" ./lab_work/firstboot/${i}
           sed -i "s|%%LAB_DOMAIN%%|${LAB_DOMAIN}|g" ./lab_work/firstboot/${i}
           sed -i "s|%%DB_HOST%%|${DB_HOST}|g" ./lab_work/firstboot/${i}
        done

        sed -i "s|%%LAB_DOMAIN%%|${LAB_DOMAIN}|g" ./lab_work/postinstall/mariadb-server.cnf
        sed -i "s|%%DB_HOST%%|${DB_HOST}|g" ./lab_work/postinstall/mariadb-server.cnf
        sed -i "s|%%REPO_URL%%|${REPO_URL}|g" ./lab_work/postinstall/local-repos.repo

        scp -r ./lab_work/kickstart root@${INSTALL_HOST_IP}:${INSTALL_ROOT}
        scp -r ./lab_work/firstboot root@${INSTALL_HOST_IP}:${INSTALL_ROOT}
        scp -r ./lab_work/postinstall root@${INSTALL_HOST_IP}:${INSTALL_ROOT}

        rm -rf ./lab_work

We are now ready to [start provisioning guest VMs](README.md) or install a [Bare Metal Host](Install_Bare_Metal.md).
