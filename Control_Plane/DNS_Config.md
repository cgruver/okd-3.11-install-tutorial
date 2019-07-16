## DNS Configuration

First step; install the necessary packages:

`# yum -y install bind bind-utils`

Now, we need to configure some files.  For this intial exercise, we are going to use static IP addresses for our OKD node machines.  In a future iteration, we'll show you how to set up DHCP with dynamic dns.

We need to configure named.

`# cd /etc/named`

`# vi /etc/named.conf`

`systemctl enable named`
`systemctl start named`

`firewall-cmd --permanent --add-service=dns`

`firewall-cmd --reload`