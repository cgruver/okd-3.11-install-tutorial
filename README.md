## Building an OpenShift - OKD 3.11 Lab, Soup to Nuts

This project is a tutorial that will lead you through setting up an OpenShift - OKD 3.11 cluster.  However, this tutorial will cover much more than just installing OKD 3.11.  We are going to install and configure all aspects of the infrastructure that your OKD cluster is going to run on.

By the end of this tutorial, you will have set up the following components:

* KVM - LibVirt install on base CentOS
* Control Plane server with:
    * Bind - DNS provider
    * Nginx web server hosting all the RPMS for your environment
    * Sonatype Nexus:
        * Maven Dependencies
        * Container Registry
     * Golang build environment
     * OpenShift - OKD 3.11 RPMs and Container Images built from source code
* Automated provisioning of Guest VMs for your OKD cluster
* Finally, at least one OKD cluster - depending on your available compute resources

First: Clone this repository: `git clone https://github.com/cgruver/okd-3.11-tutorial.git`  

Next: __Follow the [Tutorial](https://cgruver.github.io/okd-3.11-tutorial/)__

### Note: Use the master branch.  I have added an okd-4 branch recently that I may write about.  I am working on a UPI deployment of OKD-4.  It is VERY WIP.
