maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures reginjector to push registry changes to Windows machines"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.4"

%w{ windows }.each do |os|
  supports os
end