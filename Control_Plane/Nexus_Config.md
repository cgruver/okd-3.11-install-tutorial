## Setting up Sonatype Nexus

yum -y install java-1.8.0-openjdk.x86_64

```
mkdir /usr/local/nexus
cd /usr/local/nexus
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -xzvf latest-unix.tar.gz
ln -s nexus-3.14.0-04 nexus-3
```

```
groupadd nexus
useradd -g nexus nexus
chown -R nexus:nexus /usr/local/nexus
```

```
firewall-cmd --add-port=8081/tcp --permanent
firewall-cmd --add-port=8443/tcp --permanent
firewall-cmd --add-port=5000/tcp --permanent
firewall-cmd --add-port=5001/tcp --permanent
firewall-cmd --reload
```

```
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
```

```
systemctl enable nexus
systemctl start nexus
```

#Enable TLS

```
keytool -genkeypair -keystore nexus.jks -storepass password -alias oscluster.clgcom.org -keyalg RSA -keysize 2048 -validity 5000 -keypass password -dname 'CN=*.oscluster.clgcom.org OU=Sonatype, O=Sonatype, L=Unspecified, ST=Unspecified, C=US' -ext 'SAN=DNS:nexus.oscluster.clgcom.org,DNS:clm.oscluster.clgcom.org,DNS:repo.oscluster.clgcom.org,DNS:osc-controller01,DNS:osc-controller01.oscluster.clgcom.org'
```

```
keytool -importkeystore -srckeystore nexus.jks -destkeystore /usr/local/nexus/nexus-3/etc/ssl/keystore.jks -deststoretype pkcs12
```

```
mkdir /usr/local/nexus/sonatype-work/nexus3/etc
cat <<EOF >> /usr/local/nexus/sonatype-work/nexus3/etc/nexus.properties
nexus-args=\${jetty.etc}/jetty.xml,\${jetty.etc}/jetty-https.xml,\${jetty.etc}/jetty-requestlog.xml
application-port-ssl=8443
EOF
```
