Description
===========

Installs deltacopy, the rsync daemon for Windows 2003 & 2008: http://www.aboutmyip.com/files/?C=M;O=D

Configures deltacopy, the rsync daemon for Windows 2003 & 2008: http://www.aboutmyip.com/files/DeltaCopyManual.pdf

Requirements
============

Requires cookbooks cerberus (which requires twitter) and windows.  Cerberus is required inside my particular installation to manage Windows 200{3,8} firewall rules: hermes uses the same ip_permit data bag setup to configure the hosts allow statement for the rsync daemon config file.  The windows cookbook is required in order to unzip the downloaded installer. 

A more streamlined setup without the cerberus dependency would be easy: simply remove the dependency from metadata.rb, remove the section inside the deltacopy.rb recipe that searches ip_permit and builds the ip_permit array, and then remove the "hosts allow = <% @ip_permit.each do |ip| -%><%= ip['ipaddress'] %><%= ip['netmask']%>,<% end -%>" line from the deltacd.conf.erb template.

Removing the windows dependency would be possible if the installer was unzipped and placed on the target servers in some other fashion - you do have 7z.exe installed, right?  Then just remove the windows_zipfile provider statement from the deltacopy.rb recipe.

An encrypted data bag holds the simple daemon password information (overkill, because rsync stores the password in plaintext on all servers); this could easily be changed to a straight-up attribute with little security impact.

Attributes
==========

The attributes mostly refer to file names and are pretty straightforward.  Since the default msi is used, these are not really tune-able.  The templates are really the only interesting items here.

Usage
=====

I have not rebuilt or changed the default installer in any fashion; however, I have extracted the msi from the exe file.  The primary reason for this is that I can not seem to control the destination install location by submitting commandline switches to the installer exe... even though the exe reports that functionality exists.  The simplest thing (but also a bummer for all those who love the simple beautity of remote_file->unattended_install) is to simply extract the msi from the exe (numerous methods exist, the easiest one for me with this was to run the exe once with the "local cache" switch to write the msi to the root of the drive and then quit the installer) and store that in a conventient network location.

Add the cookbook to your run list.  With Windows 2003 Server, the deltas.exe binary needs to be run by hand once the package has been installed in order to stop the service and then restart it.  From there, all works as expected.  With Windows 2008, everything seems to work well.