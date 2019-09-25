## Minimal CentOS Install

I use the CentOS Minimal ISO:

    wget https://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-Minimal.iso

__This tutorial assumes that you are comfortable installing a Linux OS.__

You can either install via USB Key, or if you are adventurous, (which I assume you are since you are reading this), you can skip this section and instead jump to: 

[Setting Up a PXE Server](PXE_Setup.md).  

If you go this route, you will setup an unattended PXE install of your KVM hosts.

__Continue with USB install:__

I use [balenaEtcher](https://www.balena.io/etcher/) to create a bootable USB key from a CentOS ISO ISO.

You will have to attach monitor, mouse, and keyboard to your NUC for the install.  After the install, these machines will be headless.  So, no need for a complicated KVM setup...  The other, older meaning of KVM...  not confusing at all.

### Install CentOS:

* Network:
    * Configure the network interface with a fixed IP address
        * Set the system hostname
* Storage:
    * Allocate 50GB for the / filesystem
    * Do not create a /home filesystem (no users on this system)
    * Allocate the remaining disk space for the VM guest filesystem
        * I put my KVM guests in /VirtualMachines 

After the installation completes, ensure that you can ssh to your host.

    ssh root@10.10.11.10  Substitute the IP of your new host

Create an SSH keypair if you don't already have one:

    ssh-keygen  # Take all the defaults

Enable passwordless SSH:

    ssh-copy-id root@10.10.11.10  Substitute the IP of your new host


Shutdown the host and disconnect the keyboard, mouse, and display.  Your host is now headless.  

Power the host back on, and continue to either [Control Plane Setup](Control_Plane.md) or to [KVM Setup](KVM_Config.md)
