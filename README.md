## Building an OpenShift - OKD 3.11 Lab, Soup to Nuts

This project is essentially a tutorial that will lead you thorugh setting up an OpenShift - OKD 3.11 cluster.  However, this tutorial will cover much more than just installing OKD 3.11.  We are going to install and configure all aspects of the infrastructure that your OKD cluster is going to run on.

By the end of this tutorial, you will have set up the following components:

* KVM - LibVirt install on base CentOS
* Control Plane servier with:
  * Bind - DNS provider
  * Nginx web server hosting all the RPMS for your environment
  * Sonatype Nexus:
    * Maven Dependencies
    * Container Registry
  * Golang build environment
  * OpenShift - OKD 3.11 RPMs and Container Images build from source code
* Automated provisioning of Guest VMs for your OKD cluster
* Finally, at least one OKD cluster - depending on your available compute resources

### Setting Up your Control Plane Server:
1. [Base OS Install](CentOS_Install.md)
2. [Control Plane Setup](Control_Plane/README.md)
3. [KVM Setup](KVM_COnfig.md)
4. [VM Guest Provisioning](Provision_Guest_Nodes/README.md)


### Setting up your KVM Hosts

[DNS Configuration](DNS_Config/README.md)

