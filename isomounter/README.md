Description
===========

Download and install Magic Disc from their site to mount iso files to your windows machine.  Magic Disc is freeware.  Their binary "miso.exe" is downloaded as well to enable commandline functionality.

http://www.magiciso.com/tutorials/miso-magicdisc-history.htm

http://searchwindowsserver.techtarget.com/tip/How-to-install-and-manage-virtual-CD-DVDs

Requirements
============

Looks like the driver signing requirements with Windows 2008 have broken Magic Disk (they do not sign their driver).  This is unfortunate; however, I have disabled the driver signing checks to hack around this.  I do not really like this solution; however, I do enjoy mounting DVD ISOs.

The sequence is basically that disabling the driver signing requires a reboot, and then once the machine reboots and chef runs again, Magic Disk should be installed properly.

Of course, it is certainly worth noting that mucking about with your windows boot configuration could potentially do serious damage to your machine... but since you have already automated all the things, you could rebuild a new one in minutes, right?


Attributes
==========

Most of the attributes simply refer to the version of Magic Disc.

Usage
=====

Command line usage:

miso.exe NULL -sdrv 0
Disable all virtual Drives.

miso.exe NULL -vlist
List all of the present virtual CD/DVD driver

miso.exe NULL -mnt f: e:\en_sql_server_2008_r2_standard_x86_x64_ia64_dvd_521546.iso
Mount the MSSQL iso located inside the root of the e:\ drive to virtual drive f:

miso NULL -umnt f:
Unmount virtual drive f:
