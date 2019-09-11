## Setting up Nested Virtualization

Nested virtualization is a pretty cool feature in KVM.  It allows you to enable a Guest VM on a physical host to act as a Hypervisor with guest VMs of its own.

First, let's add a new RPM repo.  CentOS ships with an older version of QEMU & Libvirt.  We want the latest GA release.

    cat <<EOF > /etc/yum.repos.d/kvm-common.repo
    [kvm-common]
    name=CentOS Epel
    baseurl=http://mirror.centos.org/centos/7/virt/x86_64/kvm-common/
    gpgcheck=0
    enabled=1
    EOF

    yum clean all

Install KVM, if you haven't already.

    yum install libvirt libvirt-devel libvirt-daemon-kvm qemu-kvm

If you have already installed, then just update.

    yum update

Now, let's enable nested KVM

    modprobe -r kvm_intel
    modprobe kvm_intel nested=1

To make the setting survive a reboot, edit `/etc/modprobe.d/kvm.conf`, and add:

    options kvm_intel nested=1

#### That's it!

Now, when you create a guest that you want to act as a nested hypervisor, you need to enable `host_passthrough` for the CPU.

If you are using virt-install to create a VM, add the following to your install command:

    --cpu host-passthrough,match=exact

If you have a pre-existing guest VM, you can modify it to enable nested KVM as so:

    virsh edit <name-of-guest-vm>

Find the CPU mode section.  It will look something like:

    <cpu mode='custom' match='exact' check='partial'>
      <model fallback='allow'>Broadwell-noTSX-IBRS</model>
    </cpu>

Change it to look like:

    <cpu mode='host-passthrough' match='exact' check='partial'>
    </cpu>

