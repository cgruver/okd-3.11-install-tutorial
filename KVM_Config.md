## Installing KVM packages

1. Install some common tools that are useful on all of our hosts:

        yum -y install wget git net-tools bind-utils bash-completion nfs-utils rsync

1. Install the KVM packages:

        yum -y install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install

1. Update the OS:

        yum -y update

1. Reboot:

        shutdown -r now

### Set up bridged network for your guest VMs

We are going to manually edit the network config files to set up bridged networking.  This is also possible with `nmcli` or `nmtui`.  We'll add instructions for that in a later iteration.

1. We are going to name our bridge device `br1`.

        cd /etc/sysconfig/network-scripts
        vi ifcfg-br1

    Here is an example file:

        TYPE=Bridge
        PROXY_METHOD=none
        BROWSER_ONLY=no
        BOOTPROTO=static
        DEFROUTE=yes
        IPV4_FAILURE_FATAL=yes
        IPV6INIT=no
        IPV6_AUTOCONF=no
        IPV6_DEFROUTE=no
        IPV6_FAILURE_FATAL=no
        IPV6_ADDR_GEN_MODE=stable-privacy
        NAME=br1
        DEVICE=br1
        ONBOOT=yes
        IPADDR=10.20.30.10 
        PREFIX=24
        GATEWAY=10.20.30.1
        DNS1=10.20.30.5
        DOMAIN=your.domain.org
        ZONE=public
        NM_CONTROLLED=no

    Replace `IPADDR, PREFIX, GATEWAY, DNS1, and DOMAIN` with the information from the NIC that you configured during the installation.

1. Now we need to modify the configuration for your physical NIC to use the bridge interface.

    Assuming that your NIC is eno1:

    `cp ifcfg-en01 sav.ifcfg-eno1.sav` --Just in case we have to put it back.

    `vi ifcfg-eno1`

        TYPE=Ethernet
        PROXY_METHOD=none
        BROWSER_ONLY=no
        BOOTPROTO=none
        IPV4_FAILURE_FATAL=no
        IPV6INIT=no
        IPV6_AUTOCONF=no
        IPV6_DEFROUTE=no
        IPV6_FAILURE_FATAL=no
        IPV6_ADDR_GEN_MODE=stable-privacy
        NAME=eno1
        DEVICE=eno1
        ONBOOT=yes
        BRIDGE=br1
        NM_CONTROLLED=no
   
    Notice that all of the IP configuration data has been moved to the ifcfg-br1 file.

1. Now comes the fun part.  Remeber the keyboard and display that you used to install the base OS?  You might have them handy at this point because we are going to do something a little reckless.  Don't worry, we'll show you how to do this is a safer and automated way.  But for now, we're going to restart our network services in order to apply our new configuration.

       systemctl restart network

    If your configuration files are correct, you will retain control of the ssh session when the `systemctl` command completes.  If not, well that's where we need to attach a keyboard and display to gain console access so we can fix our mistake in the config files.

### Start KMV

    systemctl enable libvirtd
    systemctl start libvirtd

### Your host is now ready for Guest VMs to move in.

If this particular host is also going to host your control-plane, go back now and complete the [Control Plane](Control_Plane/README.md) setup.  Otherwise, continue to [KVM Guest Provisioning](Provision_Guest_Nodes/README.md).
