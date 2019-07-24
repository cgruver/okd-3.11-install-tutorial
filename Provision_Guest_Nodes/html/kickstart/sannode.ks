#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
#graphical
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Root password
rootpw --iscrypted $6$5x50zyIqz7MGrwQL$Su72Fdz8hX6p1mmc2YUDz0OL0XTIlHbmS.Qa0U/C.FnRj4osgJHj08NRgK0griyhJxk5BX7RWaT3By1aI5jF20
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
# Partition clearing information
#clearpart --none --initlabel
clearpart --all 
zerombr
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=sda --size=1024
part pv.157 --fstype="lvmpv" --ondisk=sda --size=1024 --grow --maxsize=2000000
volgroup centos --pesize=4096 pv.157
logvol swap  --fstype="swap" --size=2047 --name=swap --vgname=centos
logvol /  --fstype="xfs" --grow --maxsize=2000000 --size=1024 --name=root --vgname=centos
#part /bricks/brick1 --fstype="xfs" --ondisk=sdb --size=1024 --grow --maxsize=2000000
#repo --name=centos-updates --mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates

%packages
@^minimal
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

eula --agreed

%post
curl -o /root/firstboot.sh http://osc-controller01.oscluster.clgcom.org/kickstart/sannode.fb
chmod 750 /root/firstboot.sh
echo "@reboot root /bin/bash /root/firstboot.sh" >> /etc/crontab
mv /etc/sysconfig/selinux /root/selinux
cat <<EOF > /etc/sysconfig/selinux
SELINUX=disabled
SELINUXTYPE=targeted
EOF
%end

reboot
