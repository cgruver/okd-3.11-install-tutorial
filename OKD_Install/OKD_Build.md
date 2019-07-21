## Set up the OKD Build Environment

rpm --import https://mirror.go-repo.io/centos/RPM-GPG-KEY-GO-REPO
curl -s https://mirror.go-repo.io/centos/go-repo.repo | tee /etc/yum.repos.d/go-repo.repo
yum -y update

yum -y install python2-pip.noarch
pip install --upgrade pip
#pip install ansible==2.6.6
pip install ansible==2.6.14

cat <<EOF >> .bashrc
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export OS_OUTPUT_GOPATH=1
EOF
source .bashrc

mkdir $HOME/go
mkdir -p $GOPATH/src/github.com/openshift

go get -u github.com/openshift/imagebuilder/cmd/imagebuilder

cd $GOPATH/src/github.com/openshift

#Build Openshift
git clone https://github.com/openshift/origin.git
cd origin
git checkout release-3.11
