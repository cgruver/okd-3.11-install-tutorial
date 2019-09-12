## Installing or reinstalling a NUC via PXE

So, at this point we should have set up our installation environment.  Make sure you have completed these steps:

1. [PXE Setup](../PXE_Setup/README.md)
1. [Installation Environment Setup](Setup_Env.md)

The installation on a bare metal host will work like this:

1. The host will power on and find no bootable OS
1. The host will attempt a network boot by requesting a DHCP address and PXE boot info
   * The DHCP server will issue an IP address and direct the host to the PXE boot file on the TFTP boot server
1. The host will retrieve the `BOOTX64.EFI` and `grub.cfg` files from the TFTP boot server
1. The host will begin booting:
   1. The host will retrieve the `vmlinuz`, and `initrd` files from the TFTP server
   1. The host will load the kernel and init-ram
   1. The host will retrieve the kickstart file
1. The kickstart file has a pre-execution phase that does a couple of things:
   1. It identifies whether or not the system has 1 or 2 SSDs installed and creates the appropriate partition information.
   1. It identifies the active NIC, extracts its MAC address, and then retrieves a file named after the MAC address from the install server.  This file contains environment variables that will be injected into kickstart to set up the host's network configuration.

        The logic looks like:

            for i in $(ls /sys/class/net)
            do
            if [ $(cat /sys/class/net/${i}/operstate) == "up" ]
            then
                NET_IF=${i}
            fi
            done
            j=$(cat /sys/class/net/${NET_IF}/address)
            NET_MAC=${j//:}  # Strip out the : characters
            curl -o /tmp/net-vars http://10.11.11.1/hostconfig/${NET_MAC}
            source /tmp/net-vars
            cat << EOF > /tmp/net-info
            network  --bootproto=static --device=${NET_IF} --gateway=${GATEWAY} --ip=${IP} --nameserver=${NAME_SERVER} --netmask=${NETMASK} --ipv6=auto --activate
            network  --hostname=${HOST_NAME}
            EOF
1. The host should now begin and unattended install.
1. The host will reboot and run the firstboot.sh script.
1. The host is now ready to use!

There are a couple of things that we need to put in place to get started.

First we need to flip the NUC over and get the MAC address for the wired NIC, and then create a file with the MAC address minus the ":" characters.

Assuming your MAC is: `1C:69:7A:02:B6:C2` you will create a file named `1c697a02b6c2` and populate it with something like this: (There is an example file in this project under `./Provision_Hosts/html/hostconfig/1c697a02b6c2`)

    export GATEWAY=10.11.11.1
    export IP=10.11.11.210
    export NAME_SERVER=10.11.11.10
    export NETMASK=255.255.255.0
    export HOST_NAME=kvm-host01.your.domain.org

Now, push that file to your install HTTP server:

    scp 1c697a02b6c2 root@<YOUR_INSTALL_SERVER>:/path/to/html/hostconfig

Finally, make sure that you have created DNS `A` and `PTR` records.  [DNS Setup](../Control_Plane/DNS_Config.md)

We are now ready to plug in the NUC and boot it up.

__Caution:__  This is the point at which you might have to attach a keyboard and monitor to your NUC.  We need to ensure that the BIOS is set up to attempt a Network Boot with UEFI, not legacy.  You also need to ensure that `Secure Boot` is disabled in the BIOS.

__Take this opportunity to apply the latest BIOS to your NUC__

You won't need the keyboard or mouse again, until it's time for another BIOS update...  Eventually we'll figure out how to push those from the OS too.  ;-)

The last thing that I've prepared for you is the ability to reinstall your OS.  Check it out here: [OS Re-install](ReInstall_Bare_Metal.md)
