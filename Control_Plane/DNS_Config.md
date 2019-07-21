## DNS Configuration

First step; install the necessary packages:

`# yum -y install bind bind-utils`

Now, we need to configure some files.  For this intial exercise, we are going to use static IP addresses for our OKD node machines.  In a future iteration, we'll show you how to set up DHCP with dynamic dns.

This tutorial includes pre-configured files for you to modify for your specific installation.  These files will go into your `/etc` directory.  You will need to modify them for your specific setup.
```
/etc/named.conf
/etc/named/named.conf.local
/etc/named/zones/db.10.10.11
/etc/named/zones/db.your.domain.com
```

* The first file, `/etc/named.conf`, will configure the base functionality of your DNS server.  Read the comments in the file for futher direction.  You need to modify it to suit your own network.  __Note: If you are also running docker on your control plane server, you will need to include the Docker network interface in your ACL and in the "listen-on" section.__

* The second file is `/etc/named/named.conf.local`.  You will need to replace `your.domain.com` with your own domain, and `10.10.11` with your own network.  You can also create more zones if needed.

  ```
  zone "your.domain.com" {
      type master;
      file "/etc/named/zones/db.your.domain.com";
  };

  zone "11.10.10.in-addr.arpa" {
      type master;
      file "/etc/named/zones/db.10.10.11";
  };
  ```

* In the next files, those under `/etc/named/zones` you will need to rename the files to reflect the changes you make to `/etc/named/named.conf.local`

  ```
  /etc/named/zones/db.your.domain.com
  /etc/named/zones/db.10.10.11
  ```

  These two files define the A records and Pointer, (reverse lookup), records for your hosts.

  Let's start with the A records, (forward lookup zone).  Rename the file, `/etc/named/zones/db.your.domain.com`, to reflect your local domain.  Then edit it to reflect the appropriate A records for your setup.

  In the example file, there are some entries to take note of:
  1. The KVM hosts are named `kvmhost01`, `kvmhost02`, etc...  Modify this to reflect the number of KVM hosts that your lab setup with have.
  1. The control plane server is `ocp-controller01`.  If your control plane is also one of your KVM hosts, then you do not need a separate A record for this.
  1. The Sonatype Nexus server gets it's own alias A record, `nexus.your.domain.com`.  This is not strictly necessary, but I find it useful.  For your lab, make sure that this A record reflects the IP address of the server where you have installed Nexus.
  1. These example files contain references for two OpenShift clusters, a Production Cluster, and a Development cluster.  The production cluser has three each of master, infrastructure, and application (compute) noddes. The development cluster has one each of master, infrastructure, and application nodes.

     There are also records for four "SAN" nodes which I use to host a GlusterFS implementation, as well as records for three "DB" hosts which I use to host a MariaDB Galera cluster.  More on these later.

     __Remove superflouous entries from these files as needed.__
  1. There are two wildcard records that OpenShift needs.
     * `*.prd-infra.your.domain.com`
     * `*.prd-apps.your.domain.com`
   
     The "infra" record is for your OpenShift console and other Infrastructure interfaces and APIs.  The "apps" record will be for all of the applications that you deploy into your OpenShift cluster.  The names of the wildcard records are arbitrary.  I have chosen prd-infra, and prd-apps to reflect the infrastruture and application interfaces for my "production" OpenShift cluster.

     These wildcard A records need to point to the entry point for your OpenShift cluster.  If you build a cluster with three master nodes and three infrastruture nodes, you will need a load balancer in front of the cluster.  In this case, your wildcard A records will point to the IP address of your load balancer.  Never fear, I will show you how to deploy a load balancer.  
     
     If you are building a simpler cluster, with only one master node and one infrastructure node, then the wildcard records can simply point to the IP address of your nodes.  In this case `prd-infra` will point to your master node IP and `prd-apps` will point to your infrastructure node.  I realize this is slightly confusing.  Master is "infra" and Infra is "apps".  This is really a reflection of the architecture of OpenShift itself.  The "Master" nodes are hosting the infrastructure that manages the OpenShift cluster itself.  The "Infrastructure" nodes are hosting the infrastructure that supports your applications.  This is an oversimplification, but it will suffice for now.
* When you have completed all of your configuration changes, you can test the configuration with the following command:

  ```
  named-checkconf
  ```

  If the output is clean, then you are ready to fire it up!

### Starting DNS

Now that we are done with the configuration let's enable DNS and start it up.

```
firewall-cmd --permanent --add-service=dns
firewall-cmd --reload
systemctl enable named
systemctl start named
```

You can now test DNS resolution.  Try some `pings` or `dig` commands.

### __Hugely Helpful Tip:__
__If you are using a MacBook for your workstation, you can enable DNS resolution to your lab by creating a file in the `/etc/resolver` directory on your Mac.__

```
sudo bash
<enter your password>
vi /etc/resolver/your.domain.com
```

Name the file `your.domain.com` after the domain that you created for your lab.  Enter something like this example, modified for your DNS server's IP:

```
nameserver 10.10.11.10
```

Save the file.

Your MacBook should now query your new DNS server for entries in your new domain.  __Note:__ If your MacBook is on a different network and is routed to your Lab network, then the `acl` entry in your DNS configuration must allow your external network to query.  Otherwise, you will bang your head wondering why it does not work...  __The ACL is very powerful.  Use it.  Just like you are using firewalld.  Right?  I know you did not disable it when you installed your host...__

### On to the next...

Now that we have DNS configured, continue on to [Nginx Setup](Nginx_Config.md), or return to the [Control Plane](README.md)

