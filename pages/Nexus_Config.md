## Setting up Sonatype Nexus

We are now going to install [Sonatype Nexus](https://www.sonatype.com/nexus-repository-oss).  The Nexus will be used for our external container repository, as well as serving as an artifact repository for maven, npm, or any other application development repositories that you might need.

Nexus requires Java, so let's install that now:


    yum -y install java-1.8.0-openjdk.x86_64

Now, we'll install Nexus:


    mkdir /usr/local/nexus
    cd /usr/local/nexus
    wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
    tar -xzvf latest-unix.tar.gz
    ln -s nexus-3.14.0-04 nexus-3

Add a user for Nexus:


    groupadd nexus
    useradd -g nexus nexus
    chown -R nexus:nexus /usr/local/nexus

Enable firewall access:

    firewall-cmd --add-port=8081/tcp --permanent
    firewall-cmd --add-port=8443/tcp --permanent
    firewall-cmd --add-port=5000/tcp --permanent
    firewall-cmd --add-port=5001/tcp --permanent
    firewall-cmd --reload

Create a service reference for Nexus so the OS can start and stop it:

    cat <<EOF > /etc/systemd/system/nexus.service
    [Unit]
    Description=nexus service
    After=network.target

    [Service]
    Type=forking
    LimitNOFILE=65536
    ExecStart=/usr/local/nexus/nexus-3/bin/nexus start
    ExecStop=/usr/local/nexus/nexus-3/bin/nexus stop
    User=nexus
    Restart=on-abort
    
    [Install]
    WantedBy=multi-user.target
    EOF

Now, we will enable Nexus to auto-start at boot, but not start it yet:

    systemctl enable nexus

### Enabling TLS

Before we start Nexus, let's go ahead a set up TLS so that our connections are secure from prying eyes.

1. Generate a Java Key Store replacing the DNS entries with the entires relevant to your environment:  (Remember, in the DNS configuration we named our control plane server `ocp-controller01`.  If you used a different host name, you need to change it below)

        keytool -genkeypair -keystore nexus.jks -storepass password -alias your.domain.com -keyalg RSA -keysize 2048 -validity 5000 -keypass password -dname 'CN=*.your.domain.com OU=Sonatype, O=Sonatype, L=Unspecified, ST=Unspecified, C=US' -ext 'SAN=DNS:nexus.your.domain.com,DNS:clm.your.domain.com,DNS:repo.your.domain.com,DNS:ocp-controller01,DNS:ocp-controller01.your.domain.com'

1. Import the new keystore into the Nexus configuration:


        keytool -importkeystore -srckeystore nexus.jks -destkeystore /usr/local/nexus/nexus-3/etc/ssl/keystore.jks -deststoretype pkcs12


1. Modify the Nexus configuration for HTTPS:

        mkdir /usr/local/nexus/sonatype-work/nexus3/etc
        cat <<EOF >> /usr/local/nexus/sonatype-work/nexus3/etc/nexus.properties
        nexus-args=\${jetty.etc}/jetty.xml,\${jetty.etc}/jetty-https.xml,\${jetty.etc}/jetty-requestlog.xml
        application-port-ssl=8443
        EOF

Now we should be able to start Nexus and connect to it with a browser:

    systemctl start nexus

Now point your browser to `https://nexus.your.domain.com:8443`

The `?` in the top right hand corner of the Nexus screen will take you to their documentation.

# ToDo: How to set up Docker registry

If your control plane is now complete, then continue on to [setting up guest VMs](Provisioning_Hosts.md).  Otherwise, [go back to finish setting up your control plane server](Control_Plane.md)

