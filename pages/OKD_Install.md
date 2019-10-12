## OKD 3.11 Installation

We are now going to use Ansible to install our OKD cluster.

I have provided an example Ansible inventory file for you to use.  Assuming that you built the guest VMs according to the example, you will build an OKD cluster with one Master node, one Infra node, and two Compute nodes.

The provided Ansible inventory file follows that model.  Modify it to suit your particular cluster.

1. Create a working area for your deployment.

       mkdir ~/OKD_Install

1. Copy the inventory.3.11.ini file from this repo into `~/OKD_Install`

       cp OKD_Install/inventory.3.11.ini ~/OKD_Install
       cd ~/OKD_Install

1. I created it as a template for you to apply your `$LAB_DOMAIN` to.

       sed -i "" "s|%%LAB_DOMAIN%%|${LAB_DOMAIN}|g" inventory.3.11.ini
    
1. Clone the OpenShift Ansible project:

       git clone https://github.com/openshift/openshift-ansible.git
       cd openshift-ansible
       git fetch
       git checkout release-3.11
       cd ..

1. We're now ready to deploy!!!

       ansible-playbook -i inventory.3.11.ini openshift-ansible/playbooks/prerequisites.yml
       ansible-playbook -i iinventory.3.11.ini openshift-ansible/playbooks/deploy_cluster.yml

    This will take a while for each step to complete...

1. Create an admin account in your new cluster:

       ssh root@okd-master01
       htpasswd -b /etc/origin/master/htpasswd admin <YOUR_ADMIN_PASSWORD>
       oc adm policy add-cluster-role-to-user cluster-admin admin
       exit

1. Log in to your new OKD cluster:

       oc login -u admin https://console.infra.${LAB_DOMAIN}:8443

1. Point your browser to `https://console.infra.${LAB_DOMAIN}:8443`

## You should now be up and running with a brand new OKD 3.11 cluster that you built from scratch!!!

# Go Cloud Native!
