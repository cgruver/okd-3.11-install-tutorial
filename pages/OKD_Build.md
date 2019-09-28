## Building OpenShift from Source code:

First, we need to set up some tooling for our [OKD Build Environment](OKD_Build_Env_Setup.md)

Now let's build OpenSHift from source!

If you haven't set your lab environment since building the control plane, then source the lab environment:

    . ~/bin/lab_bin/setLabEnv.sh

1. Clone the Git repo:

       cd $GOPATH/src/github.com/openshift
       git clone https://github.com/openshift/origin.git
       cd origin
       git checkout release-3.11

1. Delete any cached Docker images: __Warning: this deletes all docker images from you local system.__

       docker system prune --all --force

1. Build OpenShift:

       hack/env hack/build-base-images.sh
       hack/env make release

1. Copy the OpenShift RPMs to your Nginx server:

       ssh root@${REPO_HOST} "rm -rf /usr/share/nginx/html/repos/ocp"
       ssh root@${REPO_HOST} "mkdir -p /usr/share/nginx/html/repos/ocp"
       scp -r $GOPATH/src/github.com/openshift/origin/_output/local/releases/rpms/* root@${REPO_HOST}:/usr/share/nginx/html/repos/ocp
       ssh root@${REPO_HOST} "createrepo /usr/share/nginx/html/repos/ocp"

1. Create a yum repo file for the OpenShift RPMs

       cat <<EOF > /tmp/openshift.repo 
       [local-openshift]
       name=CentOS OpenShift Origin
       baseurl=${REPO_URL}/repos/ocp/
       gpgcheck=0
       enabled=1
       EOF

       scp /tmp/openshift.repo root@${INSTALL_HOST_IP}:${INSTALL_ROOT}/postinstall
       rm /tmp/openshift.repo


1. Build Ansible Service Broker:

       cd $GOPATH/src/github.com/openshift
       git clone https://github.com/openshift/ansible-service-broker.git
       cd ansible-service-broker
       git checkout release-1.3
       export ORG=openshift
       export TAG=v3.11
       export REGISTRY="nexus.${LAB_DOMAIN}:5001"
       make build
       make build-image

1. Build Metrics:

       cd $GOPATH/src/github.com/openshift
       export OS_TAG=v3.11.0
       export PREFIX="nexus.${LAB_DOMAIN}:5001/openshift/origin-"
       git clone --recurse-submodules https://github.com/openshift/origin-metrics.git
       cd origin-metrics/
       git checkout release-3.11
       git submodule init
       git submodule update
       cd hack
       ./build-images.sh --version=v3.11.0

2. Build Logging:

       cd $GOPATH/src/github.com/openshift
       git clone --recurse-submodules https://github.com/openshift/origin-aggregated-logging.git
       cd origin-aggregated-logging
       git checkout release-3.11
       git submodule init
       git submodule update

       export OS_TAG=v3.11.0
       export PREFIX="nexus.${LAB_DOMAIN}:5001/openshift/origin-"
       make

3. Push Images to Nexus Registry

       docker login -u admin nexus.${LAB_DOMAIN}:5001

       docker push nexus.${LAB_DOMAIN}:5001/openshift/origin-ansible-service-broker:v3.11

       for i in $(docker images | grep -v docker | grep openshift | grep latest | cut -d" " -f 1) 
       do 
        docker tag ${i} nexus.${LAB_DOMAIN}:5001/${i}:v3.11
        docker tag ${i} nexus.${LAB_DOMAIN}:5001/${i}:v3.11.0
       done

       for i in $(docker images | grep nexus | cut -d" " -f 1) 
       do 
        docker push ${i}:v3.11
        docker push ${i}:v3.11.0
       done

4. We are now ready to install an OKD 3.11 cluster!

    [Install OKD 3.11](OKD_Install.md)

### MacBook Users: Build the `oc` command line tool from source:

You will need HomeBrew installed.

    brew update
    brew install golang
    brew install coreutils

    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    export OS_OUTPUT_GOPATH=1
    mkdir -p $GOPATH/src/github.com/openshift
    cd $GOPATH/src/github.com/openshift
    git clone https://github.com/openshift/origin.git
    cd origin
    git checkout release-3.11

    export CGO_ENABLED=1
    make build WHAT=cmd/oc

When finished, copy `./_output/local/bin/darwin/amd64/oc` to somewhere in your PATH.

