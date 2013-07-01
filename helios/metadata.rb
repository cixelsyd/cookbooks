maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures helios, a basic windows x509 certificate import utility"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.2"

depends          "powershell", ">= 1.0.6"

%w{ windows }.each do |os|
  supports os
end