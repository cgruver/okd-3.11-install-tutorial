## Set up the OKD Build Environment

1. Install GO RPM repository:

        rpm --import https://mirror.go-repo.io/centos/RPM-GPG-KEY-GO-REPO
        curl -s https://mirror.go-repo.io/centos/go-repo.repo | tee /etc/yum.repos.d/go-repo.repo
        yum -y update

1. Install development tools:

        yum -y install docker git golang zip krb5-devel bsdtar bc jq tito createrepo libassuan-devel

1. Install Ansible 2.6. Note: The OKD 3.11 Ansible installer does not work with Ansible 2.7 or greater:

        yum -y remove ansible  # Just in case you installed 2.7 or greater.
        yum -y install python2-pip.noarch
        pip install --upgrade pip
        pip install ansible==2.6.14

1. Set up your environment:

        cat <<EOF >> .bashrc
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
        export OS_OUTPUT_GOPATH=1
        EOF
        source .bashrc

1. Create the necessary source path:

        mkdir $HOME/go
        mkdir -p $GOPATH/src/github.com/openshift

1. Install the image builder

        go get -u github.com/openshift/imagebuilder/cmd/imagebuilder

1. Enable Docker:

        systemctl enable docker
        systemctl start docker

We are now ready to [build OpenShift](OKD_Build.md).
