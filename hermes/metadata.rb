maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures deltacopy - the rsync daemon for Windows"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"

depends           "cerberus", ">= 0.0.2"

%w{ windows }.each do |os|
  supports os
end