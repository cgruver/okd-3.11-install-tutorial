## Re-Install your NUC host

I have included a very dangerous script in this project.  If you follow all of the setup instructions, it will be installed in `/root/bin/rebuildhost.sh` of your host.

The script is a quick and dirty way to brick your hosts so that when it reboots, it will force a Network Install.

The script will destroy your boot partitions and wipe the MBR in the installed SSD drives.

Destroy boot partitions:

    umount /boot/efi
    umount /boot
    wipefs -a /dev/sda2
    wipefs -a /dev/sda1

Wipe MBR:

    dd if=/dev/zero of=/dev/sda bs=512 count=1
    dd if=/dev/zero of=/dev/sdb bs=512 count=1

Reboot:

    shutdown -r now

That's it!  Your host is now a Brick.  If your PXE environment is set up properly, then in a few minutes you will have a fresh OS install.
