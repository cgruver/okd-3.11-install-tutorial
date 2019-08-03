## Provisioning Guest VM Nodes

Create an encrypted root password string:

    export ROOT_PWD=$(openssl passwd -1 YourRootPasswordHere)
