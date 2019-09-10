## Unattended Host OS install with PXE & Kickstart

We are going to setup some automation that will allow us to install and configure the OS on a bare-metal system without any intervention from a keyboard, mouse, or monitor.  We will be using the following tools:

* DHCP Server - configured for PXE boot
* TFTP Server - to serve up the PXE boot images & configuration
* HTTP Server - to serve up the OS installation & configuration files

I am going to assume that you are using the [GL-AR750S-Ext](https://www.gl-inet.com/products/gl-ar750s/) travel router.  If so, we are going to set it up as our installation server.

At this point, we need a micro-sd card that is formatted with an EXT file-system.  I used ext4.

    mkfs.ext4 /dev/sdc1 <replace with the device representing your sdcard>

Insert the SD card into the router.  It will mount at `/mnt/sda1`, or `/mnt/sda` if you did not create a partition, but formatted the whole card.

You will need to enable root ssh access to your router.  The best way to do this is by adding an SSH key.  If you don't already have an ssh key, create one: (Take the defaults for all of the prompts, don't set a key password)

    ssh-keygen
    <Enter>
    <Enter>
    <Enter>

1. Login to your router with a browser: `https://<router IP>`
1. Expand the `MORE SETTINGS` menu on the left, and select `Advanced`
1. Login to the Advanced Administration console
1. Expand the `System` menu at the top of the screen, and select `Administration`
   1. Ensure that the Dropbear Instance `Interface` is set to `unspecified` and that the `Port` is `22`
   1. Ensure that the following are __NOT__ checked:
      * `Password authentication`
      * `Allow root logins with password`
      * `Gateway ports`
   1. Paste your public SSH key into the `SSH-Keys` section at the bottom of the page
      * Your public SSH key is likely in the file `$HOME/.ssh/id_rsa.pub`
   2. Click `Save & Apply`

Now that we have enabled SSH access to the router, we will login and complete our setup from the command-line.

First we need to set up some file paths and populate them with boot & install files:

    ssh root@<router IP>
    mkdir -p /mnt/sda1/tftpboot/networkboot
    mkdir -p /mnt/sda1/install/centos
    exit

Download the CentOS minimal install image from: [CentOS Minimal Install](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso)

Now, we will enable the tftp server and instruct the DHCP server to send PXE boot info:

    ssh root@<router IP>
    uci set dhcp.@dnsmasq[0].enable_tftp=1
    uci set dhcp.@dnsmasq[0].tftp_root=/mnt/sda1/tftpboot
    uci set dhcp.@dnsmasq[0].dhcp_boot=BOOTX64.EFI
    uci commit dhcp
    /etc/init.d/dnsmasq restart
    exit


