maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures Cerberus firewall manager for Windows 2003 and 2008"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.4"

depends           "twitter", ">= 1.0.1"

%w{ windows }.each do |os|
  supports os
end