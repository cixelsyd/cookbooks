Description
===========

https://github.com/cixelsyd/cookbooks/tree/master/cerberus

Installs/Configures cerberus firewall manager for Windows.  Supports 2003 and 2008.  The key thought behind Cerberus' modus operandi is simple: define the permitted ports and protocols in one databag and the permitted IP addresses / ranges in another.  Any IP inside the ip_permit databag would have access to all of the declared ports.

http://bit.ly/chefcerberus

Cerberus >= 1.0.0 handles a significant bug in (both architectures of) Windows 2008 advfirewall manager whereby the "remoteip=" string has a short character limit.  Instead of concatinating all the permitted ips onto one line, cerberus now writes a rule for every remoteip.  This is a bummer, actually, because the netsh advfirewall command takes an extremely long time to run on Windows 2008 i386.  An. Extremely. Long. Time.  Note, this slow behaviour seems to build over time, and regular reboots seem to mitigate the issue significantly.  This issue does not seem to impact Windows 2008 R2 x86_64.  If you can migrate your machines from Windows 2008 i386 to Windows 2008 R2 x86_64, this is highly recommended.

Updated to support opening http to facebook networks.

Requirements
============

Windows 2003 or 2008, a data bag to hold permitted ip addresses and a data bag to hold protocol details.  Also requires the twitter cookbook to tweet service status changes; this dependency can be broken and removed easily.

Attributes
==========

The Windows 2003 version uses a few attributes to point at the the "inf" file used for rule deployment; however, the vast majority of the information is stored inside data bags.

Usage
=====

Create two data bags and add the permitted ips to the first and the permitted ports to the second as such:

ip_permit (sample item below)
{
  "name": "data_bag_item_ip_permit_www",
  "raw_data": {
    "netmask": "/32",
    "comment": "example host description here",
    "fqdn": "www.smashrun.com",
    "ipaddress": "192.168.0.110",
    "id": "www",
    "owner": "Joe User"
  },
  "json_class": "Chef::DataBagItem",
  "data_bag": "ip_permit",
  "chef_type": "data_bag_item"
}

firewall_rules (sample item below)
{
  "name": "data_bag_item_firewall_rules_3389",
  "raw_data": {
    "name": "rdp",
    "protocol": "tcp",
    "id": "3389",
    "permit": "enabled",
    "description": "Remote Desktop (tcp 3389)"
  },
  "json_class": "Chef::DataBagItem",
  "data_bag": "firewall_rules",
  "chef_type": "data_bag_item"
}

Then add the cookbook to the runlist and watch it go!
