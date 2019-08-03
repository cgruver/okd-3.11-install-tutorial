## Provisioning Guest VM Nodes

Now it's finally time to start provisioning some guest VMs for our OKD cluster.

I have provided some shell scripts and kickstart files to assist with your deployments.  In a further iteration, we'll replace a lot of this with PXE and Ansible.  I started this project before learning Ansible, so I rolled my own automation.

First, setup your environment for guest provisioning here: [Setup For Guest](Setup_Env.md)


Now you can begin setting up guest VMs:

1. Set your environment:

        ~/bin/lab_bin/setLabEnv.sh

1. Create a working directory:

        mkdir -p ~/okd-lab/guest-inventory
        cd ~/okd-lab/guest-inventory

1. Create an inventory file for your OKD lab deployment:

        vi my_lab

    Add content appropriate for your lab setup.  Let's assume that you have one NUC6i7KYK with 64GB of RAM.  The following example will deploy a cluster with one Master node, one Infra node, and two Compute nodes.

        #TYPE,HOST_NODE,HOSTNAME,MEMORY,CPU,ROOT_VOL,DATA_VOL
        MASTER,kvmhost01,okd-master01,16384,4,50,50
        INFRA,kvmhost01,okd-infranode01,28672,4,50,50
        APP,kvmhost01,okd-appnode01,8192,4,50,50
        APP,kvmhost01,okd-appnode02,8192,4,50,50

    Remember, the node hostnames must be in your DNS server before you start provisioning.  That is how the guest VMs get their IP address.

1. Provision some guest VMs!

        DeployVms.sh -i=my_lab

    If all goes according to plan, you should have guest VMs self-provisioning now.  This step will take a few minutes.  Your new guests will install the minimal CentOS image, reboot, run their firstboot script, then reboot one more time.

1. To test ssh connectivity to your new guest VMs.  I have provided a helper script to execute a command against all of the guests in an inventory file.

        oscexec.sh -i=my_lab -c="uname -a"
    
    You should see an output for each of your guests similar to:

        Linux <GUEST_HOSTNAME_HERE> 3.10.0-957.21.3.el7.x86_64 #1 SMP Tue Jun 18 16:35:19 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

1. Now it's time to set up our [OpenShift Build](../OKD_Install/README.md)
