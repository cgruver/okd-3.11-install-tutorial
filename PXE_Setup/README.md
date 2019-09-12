## Unattended Host OS install with PXE & Kickstart

We are going to set up some automation that will allow us to install and configure the OS on a bare-metal system without any intervention from a keyboard, mouse, or monitor.  We will be using the following tools:

* DHCP Server - configured for PXE boot
* TFTP Server - to serve up the PXE boot images & configuration
* HTTP Server - to serve up the OS installation & configuration files

You have a couple of options here:

1. Set up the [GL-AR750S-Ext](https://www.gl-inet.com/products/gl-ar750s/) travel router as your installation server.
2. Add PXE Boot capabilities to your [Control Plane Server](../Control_Plane/README.md)

We are going to set up UEFI booting since some of the newest NUCs have removed Legacy Boot from their BIOS.

If you are going to use the `GL-AR750S-Ext`, then go here: [Set Up GL-AR750S-Ext](GL-AR750S-Ext.md).  This is by far the most fun option.  It also adds the benefit of being able to also reinstall your Control Plane OS without keyboard & monitor.

If you are going to set up PXE on the Control Plane server, then go here: [Control Plane Server](../Control_Plane/README.md) and follow the optional PXE Setup instructions.

Remeber the `Choose Your Own Adventure` books from the 90's?  No, you probably don't...
