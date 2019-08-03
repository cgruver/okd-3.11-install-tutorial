## Setting up the control plane

The control plane is generically what I call the system that hosts utilities in support of the rest of the lab.  It is also where I have my OpenShift build environment installed.

The control plane hosts:

* Nginx for serving up RPMs and install files to KVM guests.
* A DNS server for the lab ecosystem.
* Sonatype Nexus for Maven Artifacts and Container Images.

You can build your control plane on a separate host, or you can install all of the components on one of you KVM hosts.  If you use a separate host, which I recommend, it can be a separate physical machine, or it can be a KVM guest on one of your hosts.  If your control plane server is going to be a KVM guest, you need to [set up KVM](../KVM_Config.md) on your hosts first.  Then, [provision a basic KVM Guest](../Provision_Guest_Nodes/Provision_BaseOS.md). 

I use an Intel NUC8i3BEK for my control plane.  The little box with 32GB of RAM is perfect for this purpose, and also very portable for throwing in a bag to take my dev environment with me.  My OpenShift build environment is also installed on the control plane server.

First, let's install some useful packages:

    yum -y install wget git net-tools bind-utils bash-completion nfs-utils rsync

Now, step through each of the tasks below:

1. [DNS Setup](DNS_Config.md)
1. [Nginx Setup & RPM Repo sync](Nginx_Config.md)
1. [Sonatype Nexus Setup](Nexus_Config.md)

When you are done configuring your control plane server, continue on to [setting up guest VMs](../Provision_Guest_Nodes/README.md).




